//
//  FeedBackgroundCell.h
//  LDRTouch
//
//  Created by KISHIKAWA Katsumi on 09/03/02.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedCell.h"

@interface FeedBackgroundCell : UITableViewCell {
	FeedCell *cell;
}

@property (nonatomic, assign) FeedCell *cell;

@end
