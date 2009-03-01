//
//  FeedListBackgroundCell.h
//  LDRTouch
//
//  Created by KISHIKAWA Katsumi on 09/03/02.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedListCell.h"

@interface FeedListBackgroundCell : UITableViewCell {
	FeedListCell *cell;
}

@property (nonatomic, assign) FeedListCell *cell;

@end
