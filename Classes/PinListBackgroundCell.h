//
//  PinListBackgroundCell.h
//  LDRTouch
//
//  Created by KISHIKAWA Katsumi on 09/03/02.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinListCell.h"

@interface PinListBackgroundCell : UITableViewCell {
	PinListCell *cell;
}

@property (nonatomic, assign) PinListCell *cell;

@end
