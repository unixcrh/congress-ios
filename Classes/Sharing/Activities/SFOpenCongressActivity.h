//
//  SFOpenCongressActivity.h
//  Congress
//
//  Created by Jeremy Carbaugh on 8/27/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFActivity.h"
#import "SFBill.h"
#import "SFCommittee.h"
#import "SFLegislator.h"

@interface SFOpenCongressActivity : SFActivity

@property (nonatomic, strong) NSURL *url;

+ (id)activityForBill:(SFBill *)bill;
+ (id)activityForBillText:(SFBill *)bill;
+ (id)activityForLegislator:(SFLegislator *)legislator;

@end
