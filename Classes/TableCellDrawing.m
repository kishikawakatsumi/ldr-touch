//
//  TableCellDrawing.m
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/07/06.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "TableCellDrawing.h"

void drawRoundedRectPath(CGRect rect, BOOL topRound, BOOL bottomRound, BOOL topTriangle) {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat roundSize = 8.0;
	
	CGFloat x = rect.origin.x - 0.5;
	CGFloat y = rect.origin.y - 0.5;
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	
	CGContextBeginPath (context);
	
	CGContextMoveToPoint(context,   x + w/2, y + 0);
	if (topRound) {
		CGContextAddArcToPoint(context, x + w, y + 0, x + w,   y + h/2, roundSize);
	} else {
		CGContextAddLineToPoint(context, x + w, y + 0);
	}
	if (bottomRound) {
		CGContextAddArcToPoint(context, x + w, y + h, x + w/2, y + h, roundSize);
		CGContextAddArcToPoint(context, x + 0, y + h, x + 0,   y + h/2, roundSize);
	} else {
		CGContextAddLineToPoint(context, x + w, y + h);
		CGContextAddLineToPoint(context, x + 0, y + h);
	}
	if (topRound) {
		CGContextAddArcToPoint(context, x + 0, y + 0, x + w/2, y + 0, roundSize);
	} else {
		CGContextAddLineToPoint(context, x + 0, y + 0);
	}
	
	if (topTriangle) {
		CGContextAddLineToPoint(context, x + 27, y);
		CGContextAddLineToPoint(context, x + 32, y - 4);
		CGContextAddLineToPoint(context, x + 37, y);
	}
	
	CGContextClosePath(context);
}

void drawRoundedRectBackgroundGradient(CGRect rect, CGGradientRef gradient, BOOL topRound, BOOL bottomRound, BOOL topTriangle) {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBStrokeColor(context, 0.5f, 0.5f, 0.5f, 1.0f);
	CGContextSetLineWidth(context, 0.5f);
	
	drawRoundedRectPath(rect, topRound, bottomRound, topTriangle);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0,rect.size.height), 
								kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
	
	drawRoundedRectPath(rect, topRound, bottomRound, topTriangle);
	CGContextStrokePath(context);
}

CGGradientRef createTwoColorsGradient(int r1, int g1, int b1, int r2, int g2, int b2) {
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[4 * 2];
	
	colors[0] = (float)r1 / 255.0f;
	colors[1] = (float)g1 / 255.0f;
	colors[2] = (float)b1 / 255.0f;
	colors[3] = 1.0f;
	colors[4] = (float)r2 / 255.0f;
	colors[5] = (float)g2 / 255.0f;
	colors[6] = (float)b2 / 255.0f;
	colors[7] = 1.0f;
	
	CGGradientRef ret = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	CGColorSpaceRelease(rgb);
	return ret;
}
