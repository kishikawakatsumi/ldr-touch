//
//  NetworkActivityManager.m
//  LDRTouch
//
//  Created by Kishikawa Katsumi on 10/06/26.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "NetworkActivityManager.h"

static NetworkActivityManager *sharedInstance;

@implementation NetworkActivityManager

+ (NetworkActivityManager *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[NetworkActivityManager alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        networkStack = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)pushActivity {
    LOG_CURRENT_METHOD;
    if ([networkStack count] == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    NSObject *obj = [[NSObject alloc] init];
    [networkStack addObject:obj];
    [obj release];
}

- (void)popActivity {
    LOG_CURRENT_METHOD;
    if ([networkStack count] > 0) {
        [networkStack removeLastObject];
    }
    if ([networkStack count] == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
