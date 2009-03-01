//
//  Colors.m
//  LDRTouch
//
//  Created by KISHIKAWA Katsumi on 09/03/02.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "Colors.h"

static UIColor *whiteColor = NULL;
static UIColor *blackColor = NULL;
static UIColor *grayColor = NULL;
static UIColor *blueColor = NULL;
static UIColor *redColor = NULL;

@implementation Colors

+ (void)initialize {
	whiteColor = [[UIColor whiteColor] retain];
	blackColor = [[UIColor blackColor] retain];
	grayColor = [[UIColor grayColor] retain];
	redColor = [[UIColor colorWithRed:0.8f green:0.2f blue:0.2f alpha:1.0f] retain];
	blueColor = [[UIColor colorWithRed:0.2f green:0.4f blue:0.8f alpha:1.0f] retain];
}

+ (UIColor *)whiteColor {
	return whiteColor;
}

+ (UIColor *)blackColor {
	return blackColor;
}

+ (UIColor *)grayColor {
	return grayColor;
}
	
+ (UIColor *)redColor {
	return redColor;
}

+ (UIColor *)blueColor {
	return blueColor;
}

@end
