//
//  SFBillDetailViewController.m
//  Congress
//
//  Created by Daniel Cloud on 12/4/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import "SFBillDetailViewController.h"
#import "SFBillDetailView.h"
#import "SFBill.h"
#import "SFLegislator.h"
#import "SFLegislatorDetailViewController.h"
#import "SFCongressURLService.h"

@implementation SFBillDetailViewController
{
    SFBillDetailView *_billDetailView;
}

@synthesize bill = _bill;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self _initialize];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors

-(void)setBill:(SFBill *)bill
{
    _bill = bill;
    [self updateBillView];
}

#pragma mark - Private

-(void)_initialize{
    _billDetailView = [[SFBillDetailView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = _billDetailView;
    [_billDetailView.linkOutButton addTarget:self action:@selector(handleLinkOutPress) forControlEvents:UIControlEventTouchUpInside];
    [_billDetailView.sponsorButton addTarget:self action:@selector(handleSponsorPress) forControlEvents:UIControlEventTouchUpInside];
}


- (void)updateBillView
{
    self.title = _bill.displayName;

    _billDetailView.titleLabel.text = self.bill.officialTitle;
    NSString *dateDescr = @"Introduced on: ";
    if (_bill.introducedOn) {
        NSString *dateString = [_bill.introducedOn stringWithMediumDateOnly];
        if (dateString != nil) {
            dateDescr = [dateDescr stringByAppendingString:dateString];
        }
    }
    _billDetailView.dateLabel.text = dateDescr;
    if (_bill.sponsor != nil)
    {
        [_billDetailView.sponsorButton setTitle:_bill.sponsor.fullName forState:UIControlStateNormal];
    }
    _billDetailView.summary.text = _bill.shortSummary ? _bill.shortSummary : @"No summary available";

    [self.view layoutSubviews];
}

- (void)handleLinkOutPress
{
    BOOL urlOpened = [[UIApplication sharedApplication] openURL:self.bill.shareURL];
    if (!urlOpened) {
        NSLog(@"Unable to open phone url %@", [self.bill.shareURL absoluteString]);
    }
}

- (void)handleSponsorPress
{
    SFLegislatorDetailViewController *detailViewController = [[SFLegislatorDetailViewController alloc] initWithNibName:nil bundle:nil];
    detailViewController.legislator = self.bill.sponsor;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
