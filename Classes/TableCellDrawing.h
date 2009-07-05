//
//  TableCellDrawing.h
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/07/06.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

void drawRoundedRectPath(CGRect rect, BOOL topRound, BOOL bottomRound, BOOL topTriangle);
void drawRoundedRectBackgroundGradient(CGRect rect, CGGradientRef gradient, BOOL topRound, BOOL bottomRound, BOOL topTriangle);
CGGradientRef createTwoColorsGradient(int r1, int g1, int b1, int r2, int g2, int b2);
