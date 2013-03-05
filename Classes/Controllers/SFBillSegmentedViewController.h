//
//  SFBillSegmentedViewController.h
//  Congress
//
//  Created by Daniel Cloud on 12/4/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFShareableViewController.h"
#import "SFFavoriting.h"

@class SFBill;

@interface SFBillSegmentedViewController : SFShareableViewController <SFFavoriting>

@property (nonatomic, strong, setter=setBill:) SFBill *bill;
@property (nonatomic, strong) UIBarButtonItem *favoriteButton;

@end
