//
//  SFImageButton.m
//  Congress
//
//  Created by Daniel Cloud on 4/1/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFImageButton.h"

@implementation SFImageButton

static CGFloat const minimumDimension = 44.0f;

+(id)button
{
    return [[self alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fitSize = [super sizeThatFits:size];
    fitSize.width = fitSize.width < minimumDimension ? minimumDimension : fitSize.width;
    fitSize.height = fitSize.height < minimumDimension ? minimumDimension : fitSize.height;
    return fitSize;
}

- (CGSize)contentSize
{
    return self.imageView.size;
}

- (CGFloat)horizontalPadding
{
    return (self.width - self.contentSize.width)/2;
}

- (CGFloat)verticalPadding
{
    return (self.height - self.contentSize.height)/2;
}

@end
