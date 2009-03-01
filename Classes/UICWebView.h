//
//  SNWebView.h
//  hookWebViewSample
//
//  Created by sonson on 08/11/07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICWebView : UIWebView {
}
#pragma mark -
#pragma mark Hook
+ (void)installHook;
static id webViewcreateWebViewWithRequestIMP(id self, SEL _cmd, id sender, id request);
+ (void)installNewWindowDelegateHook;
+ (void)installTouchEventHook;
+ (BOOL)checkRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
#pragma mark -
#pragma mark PrivateDelegate?
- (void)scrollerWillStartDragging:(id)scroller;
- (void)scrollerDidEndDragging:(id)scroller willSmoothScroll:(BOOL)flag;
- (void)scrollerWillStartSmoothScrolling:(id)scroller;
- (void)scrollerDidEndSmoothScrolling:(id)scroller;
- (void)webView:(UIWebView *)sender willClickElement:(id)element;
#pragma mark -
#pragma mark Original method for call delegate method
- (void)hookedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
#pragma mark -
#pragma mark Original method
- (void)setupPolicyDelegate:(id)delegate;
@end
