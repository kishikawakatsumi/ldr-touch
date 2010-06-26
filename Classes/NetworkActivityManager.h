//
//  NetworkActivityManager.h
//  LDRTouch
//
//  Created by Kishikawa Katsumi on 10/06/26.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityManager : NSObject {
    NSMutableArray *networkStack;
}

+ (NetworkActivityManager *)sharedInstance;
- (void)pushActivity;
- (void)popActivity;

@end
