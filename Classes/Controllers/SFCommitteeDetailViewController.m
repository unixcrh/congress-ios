//
//  SFCommitteeDetailViewController.m
//  Congress
//
//  Created by Jeremy Carbaugh on 7/22/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFCommitteeDetailViewController.h"
#import "SFCommitteeDetailView.h"
#import "SFCommitteeService.h"
#import "SFCalloutView.h"

@interface SFCommitteeDetailViewController ()

@end

@implementation SFCommitteeDetailViewController {
    SFCommitteeDetailView *_detailView;
    SFCommittee *_committee;
    SSLoadingView *_loadingView;
}

@synthesize nameLabel = _nameLabel;
@synthesize committeeTableController = _committeeTableController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.screenName = @"Committee Detail Screen";
        self.restorationIdentifier = NSStringFromClass(self.class);
        [self _init];
    }
    return self;
}

- (void)loadView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _detailView = [[SFCommitteeDetailView alloc] initWithFrame:bounds];
    [_detailView setBackgroundColor:[UIColor primaryBackgroundColor]];
    [_detailView.favoriteButton addTarget:self action:@selector(handleFavoriteButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [_detailView.callButton addTarget:self action:@selector(handleCallButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [_detailView.websiteButton addTarget:self action:@selector(handleWebsiteButtonPress) forControlEvents:UIControlEventTouchUpInside];
    
    _loadingView = [[SSLoadingView alloc] initWithFrame:bounds];
    [_loadingView setBackgroundColor:[UIColor primaryBackgroundColor]];
    [_detailView addSubview:_loadingView];

    self.view = _detailView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - private

- (void)_init
{
    _committeeTableController = [[SFCommitteesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [_committeeTableController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

#pragma mark - public

- (void)updateWithCommittee:(SFCommittee *)committee
{
    _committee = committee;
    
    [_detailView.prefixNameLabel setText:[committee prefixName]];
    [_detailView.primaryNameLabel setText:[committee primaryName]];
    [_detailView.primaryNameLabel setAccessibilityLabel:@"Name"];
    [_detailView.primaryNameLabel setAccessibilityValue:[NSString stringWithFormat:@"%@ %@", committee.prefixName, committee.primaryName]];
    
    _detailView.favoriteButton.selected = committee.persist;
    [_detailView.favoriteButton setAccessibilityLabel:@"Follow committee"];
    [_detailView.favoriteButton setAccessibilityValue:committee.persist ? @"Following" : @"Not Following"];
    [_detailView.favoriteButton setAccessibilityHint:@"Follow this committee to see the lastest updates in the Following section."];
    
    if (!_committee.phone) {
        [_detailView.callButton setHidden:YES];
    }
    
    if (!_committee.url) {
        [_detailView.websiteButton setHidden:YES];
    }
    
    if ([committee isSubcommittee]) {
        [_detailView.noSubcommitteesLabel setText:[NSString stringWithFormat:@"Under the %@.", _committee.parentCommittee.name]];
    }
    else {
        [SFCommitteeService subcommitteesForCommittee:_committee.committeeId completionBlock:^(NSArray *subcommittees) {
            if ([subcommittees count] > 0) {
                [_committeeTableController setItems:subcommittees];
                [_committeeTableController setSectionTitleGenerator:subcommitteeSectionGenerator];
                [_committeeTableController setSortIntoSectionsBlock:subcommitteeSectionSorter];
                [_committeeTableController sortItemsIntoSectionsAndReload];
                _detailView.subcommitteeListView = _committeeTableController.view;
                [self addChildViewController:_committeeTableController];
            }
            else {
                [_detailView.noSubcommitteesLabel setText:@"There are no subcommittees for this committee."];
            }
            [_detailView setNeedsLayout];
        }];
    }
    
    [_loadingView removeFromSuperview];
    [self.view setNeedsLayout];
}

- (void)handleFavoriteButtonPress
{
    _committee.persist = !_committee.persist;
    [_detailView.favoriteButton setSelected:_committee.persist];
    [_detailView.favoriteButton setAccessibilityValue:_committee.persist ? @"Following" : @"Not Following"];
    
    if (_committee.persist) {
        [[[GAI sharedInstance] defaultTracker] send:
         [[GAIDictionaryBuilder createEventWithCategory:@"Committee"
                                                 action:@"Favorite"
                                                  label:[NSString stringWithFormat:@"%@ %@", _committee.prefixName, _committee.primaryName]
                                                  value:nil] build]];
    }
#if CONFIGURATION_Beta
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@avorited committee", (_committee.persist ? @"F" : @"Unf")]];
#endif
}

- (void)handleCallButtonPress
{
    NSString *callButtonTitle = [NSString stringWithFormat:@"Call %@", _committee.phone];
    UIActionSheet *callActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:callButtonTitle, nil];
    callActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [callActionSheet showInView:self.view];
#if CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"Pressed call committee button"];
#endif
}

-(void)handleWebsiteButtonPress
{
    BOOL urlOpened = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_committee.url]];
    if (urlOpened) {
        [[[GAI sharedInstance] defaultTracker] send:
         [[GAIDictionaryBuilder createEventWithCategory:@"Social Media"
                                                 action:@"Web Site"
                                                  label:[NSString stringWithFormat:@"%@ %@", _committee.prefixName, _committee.primaryName]
                                                  value:nil] build]];
    } else {
        NSLog(@"Unable to open _legislator.website: %@", _committee.url);
    }
#if CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"Pressed legislator website button"];
#endif
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSURL *phoneURL = [NSURL URLWithFormat:@"tel:%@", _committee.phone];
    if (buttonIndex == 0) {
        BOOL urlOpened = [[UIApplication sharedApplication] openURL:phoneURL];
        if (urlOpened) {
            [[[GAI sharedInstance] defaultTracker] send:
             [[GAIDictionaryBuilder createEventWithCategory:@"Committee"
                                                     action:@"Call"
                                                      label:[NSString stringWithFormat:@"%@ %@", _committee.prefixName, _committee.primaryName]
                                                      value:nil] build]];
        } else {
            NSLog(@"Unable to open phone url %@", [phoneURL absoluteString]);
        }
    }
}

@end
