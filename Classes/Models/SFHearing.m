//
//  SFHearing.m
//  Congress
//
//  Created by Jeremy Carbaugh on 7/30/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFHearing.h"
#import "SFCommittee.h"
#import "SFBill.h"
#import "SFBillService.h"
#import <ISO8601DateFormatter.h>

@implementation SFHearing

static NSMutableArray *_collection = nil;

#pragma mark - MTLModel Versioning

+ (NSUInteger)modelVersion {
    return 1;
}

#pragma mark - MTLModel Transformers

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"committee": @"committee_id",
             @"type": @"hearing_type",
             @"occursAt": @"occurs_at",
             @"session": @"congress",
             @"inDC": @"dc",
             @"parentCommittee": @"parent_committee",
             @"billIds": @"bill_ids",
            };
}

+ (NSValueTransformer *)inDCJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer *)urlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)occursAtJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^id(id obj) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        return [formatter dateFromString:obj];
    }];
}

+ (NSValueTransformer *)committeeJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^id(id obj) {
        NSString *committeeId = [obj valueForKey:@"committee_id"];
        SFCommittee *committee = [SFCommittee existingObjectWithRemoteID:committeeId];
        if (committee == nil) {
            committee = [SFCommittee objectWithJSONDictionary:obj];
        }
        return committee;
    }];
}

//+ (NSValueTransformer *)billsJSONTransformer
//{
//    return [MTLValueTransformer transformerWithBlock:^id(id obj) {
//        NSMutableArray *bills = [NSMutableArray array];
//        return bills;
//    }];
//}

#pragma mark - public

- (NSString *)fauxId
{
    return [NSString stringWithFormat:@"%@%@%@", self.description, self.url, self.occursAt];
}

- (NSArray *)bills
{
    [SFBillService billsWithIds:[self billsIds] completionBlock:^(NSArray *resultsArray) {
        // huh
    }];
    return nil;
}

#pragma mark - SynchronizedObject protocol methods

+ (NSString *)__remoteIdentifierKey
{
    return @"fauxId";
}

+ (NSMutableArray *)collection;
{
    if (_collection == nil) {
        _collection = [NSMutableArray array];
    }
    return _collection;
}

@end
