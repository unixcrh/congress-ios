//
//  SFFavoriting.h
//  Congress
//
//  Created by Daniel Cloud on 3/5/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFFavoriteButton;

@protocol SFFavoriting <NSObject>

@required

- (void)handleFavoriteButtonPress;

@end
