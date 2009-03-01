//
//  PinListBackgroundCell.m
//  LDRTouch
//
//  Created by KISHIKAWA Katsumi on 09/03/02.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "PinListBackgroundCell.h"

@implementation PinListBackgroundCell

@synthesize cell;

- (void)drawRect:(CGRect)rect {
    [cell drawSelectedBackgroundRect:rect];
}

- (void)dealloc {
    [super dealloc];
}

@end
