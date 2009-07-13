//
//  SNWebView.m
//  hookWebViewSample
//
//  Created by sonson on 08/11/07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UICWebView.h"
#import <objc/runtime.h>

const char* kUIWebDocumentView= "UIWebDocumentView";
const char* kUIScroller= "UIScroller";
const char* kUIWebViewWebViewDelegate = "UIWebViewWebViewDelegate";

#pragma mark -
#pragma mark UICWebViewDelegate

@interface NSObject (UICWebViewDelegate)
- (void)touchesBegan:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
- (void)touchesMoved:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
- (void)touchesCancelled:(NSSet*)touches inWebView:(UIWebView*)sender withEvent:(UIEvent*)event;
- (void)scrollerWillStartDragging:(id)scroller;
- (void)scrollerDidEndDragging:(id)scroller willSmoothScroll:(BOOL)flag;
- (void)scrollerWillStartSmoothScrolling:(id)scroller;
- (void)scrollerDidEndSmoothScrolling:(id)scroller;
- (void)willClickElementHrefURL:(NSString*)hrefURL textContent:(NSString*)textContent attributes:(NSDictionary*)attributes inWebView:(UIWebView*)sender;
- (void)webView:(UIWebView*)sender decidePolicyForMIMEType:(NSString*)type request:(NSURLRequest*)request frame:(id)frame decisionListener:(id)listener;
- (void)webView:(UIWebView*)sender decidePolicyForNavigationAction:(NSDictionary*)info request:(NSURLRequest*)request frame:(id)frame decisionListener:(id)listener;
- (void)webView:(UIWebView*)sender decidePolicyForNewWindowAction:(NSDictionary*)info request:(NSURLRequest*)request newFrameName:(id)frame decisionListener:(id)listener;
@end

#pragma mark -
#pragma mark UIView (private)

@interface UICWebView (private)
- (void)hookedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)hookedTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

#pragma mark -
#pragma mark UIView (__TapHook)

@implementation UIView (__TapHook)

- (void)__replacedTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if( [self respondsToSelector:@selector(__replacedTouchesBegan:withEvent:)] )
		[self __replacedTouchesBegan:touches withEvent:event];		// call @selector(touchesBegan:withEvent:)
	if( [self.superview.superview isMemberOfClass:[UICWebView class]] ) {
		[(UICWebView*)self.superview.superview hookedTouchesBegan:touches withEvent:event];
	}
}
- (void)__replacedTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	if( [self respondsToSelector:@selector(__replacedTouchesEnded:withEvent:)] )
		[self __replacedTouchesMoved:touches withEvent:event];		// call @selector(touchesMoved:withEvent:)
	if( [self.superview.superview isMemberOfClass:[UICWebView class]] ) {
		[(UICWebView*)self.superview.superview hookedTouchesMoved:touches withEvent:event];
	}
}

- (void)__replacedTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if( [self respondsToSelector:@selector(__replacedTouchesEnded:withEvent:)] )
		[self __replacedTouchesEnded:touches withEvent:event];		// call @selector(touchesEnded:withEvent:)
	if( [self.superview.superview isMemberOfClass:[UICWebView class]] ) {
		[(UICWebView*)self.superview.superview hookedTouchesEnded:touches withEvent:event];
	}
}

- (void)__replacedTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	if( [self respondsToSelector:@selector(__replacedTouchesCancelled:withEvent:)] )
		[self __replacedTouchesCancelled:touches withEvent:event];	// call @selector(touchesCancelled:withEvent:)
	if( [self.superview.superview isMemberOfClass:[UICWebView class]] ) {
		[(UICWebView*)self.superview.superview hookedTouchesCancelled:touches withEvent:event];
	}
}

@end

#pragma mark -
#pragma mark Static valiables for UICWebView

static BOOL isAlreaddHookInstalled = NO;
NSDictionary* AppleSchemeDictionary = nil;
NSDictionary* AppleLinkDictionary = nil;

@implementation UICWebView

#pragma mark -
#pragma mark Class method setup hookmethod for UIWebDocumentView

+ (void)initialize {
	AppleSchemeDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
							  @"mailto",	@"mailto",
							  @"tel",		@"tel",
							  @"sms",		@"sms",
							  nil] retain];
	AppleLinkDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
							@"maps.google.com",		@"maps.google.com",
							@"www.youtube.com",		@"www.youtube.com",
							@"phobos.apple.com",	@"phobos.apple.com",
							nil] retain];
}

#pragma mark -
#pragma mark Hook

+ (void)installHook {
	LOG_CURRENT_METHOD;
	if( isAlreaddHookInstalled )
		return;
	isAlreaddHookInstalled = YES;
	[self installTouchEventHook];
	[self installNewWindowDelegateHook];
}

// method to be added into UIWebViewWebViewDelegate
static id webViewcreateWebViewWithRequestIMP(id self, SEL _cmd, id sender, id request) {
	return [sender retain];
}

+ (void)installNewWindowDelegateHook {
	Class klass = objc_getClass( kUIWebViewWebViewDelegate );
	
	if( klass == nil )
		return;		// unfortunately, UIWebViewWebViewDelegate has gone...
	
	class_addMethod( klass, @selector(webView:createWebViewWithRequest:), (IMP)webViewcreateWebViewWithRequestIMP, "@@:@@" );
}

+ (void)installTouchEventHook {
	Class klass = objc_getClass( kUIWebDocumentView );
	
	if( klass == nil )
		return;		// if there is no UIWebDocumentView in the future.
	
	// replace touch began event
	method_exchangeImplementations(
								   class_getInstanceMethod(klass, @selector(touchesBegan:withEvent:)), 
								   class_getInstanceMethod(klass, @selector(__replacedTouchesBegan:withEvent:)) );
	
	// replace touch moved event
	method_exchangeImplementations(
								   class_getInstanceMethod(klass, @selector(touchesMoved:withEvent:)), 
								   class_getInstanceMethod(klass, @selector(__replacedTouchesMoved:withEvent:))
								   );
	
	// replace touch ended event
	method_exchangeImplementations(
								   class_getInstanceMethod(klass, @selector(touchesEnded:withEvent:)), 
								   class_getInstanceMethod(klass, @selector(__replacedTouchesEnded:withEvent:))
								   );
	
	// replace touch cancelled event
	method_exchangeImplementations(
								   class_getInstanceMethod(klass, @selector(touchesCancelled:withEvent:)), 
								   class_getInstanceMethod(klass, @selector(__replacedTouchesCancelled:withEvent:))
								   );
}

+ (BOOL)checkRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// for help to treat Apple's schemes.
	if( navigationType == UIWebViewNavigationTypeLinkClicked ) {
		NSString* scheme = [[request URL] scheme];
		LOG( @"%@,%@", scheme, [[request URL] host] );
		if( [AppleSchemeDictionary objectForKey:scheme] ) {
			[[UIApplication sharedApplication] openURL:[request URL]];
			return NO;
		}
		else if( [scheme isEqualToString:@"http"] ) {
			if( [AppleLinkDictionary objectForKey:[[request URL] host]] ) {
				[[UIApplication sharedApplication] openURL:[request URL]];
				return NO;
			}
		}
	}
	return YES;
}

#pragma mark -
#pragma mark PrivateDelegate?

- (void)scrollerWillStartDragging:(id)scroller {
	if( [self.delegate respondsToSelector:@selector(scrollerWillStartDragging:)] )
		[(NSObject*)self.delegate scrollerWillStartDragging:scroller];
}

- (void)scrollerDidEndDragging:(id)scroller willSmoothScroll:(BOOL)flag {
	if( [self.delegate respondsToSelector:@selector(scrollerDidEndDragging:willSmoothScroll:)] )
		[(NSObject*)self.delegate scrollerDidEndDragging:scroller willSmoothScroll:flag];
}

- (void)scrollerWillStartSmoothScrolling:(id)scroller {
	if( [self.delegate respondsToSelector:@selector(scrollerWillStartSmoothScrolling:)] )
		[(NSObject*)self.delegate scrollerWillStartSmoothScrolling:scroller];
}

- (void)scrollerDidEndSmoothScrolling:(id)scroller {
	if( [self.delegate respondsToSelector:@selector(scrollerDidEndSmoothScrolling:)] )
		[(NSObject*)self.delegate scrollerDidEndSmoothScrolling:scroller];
}

- (void)webView:(UIWebView *)sender willClickElement:(id)element {
	LOG_CURRENT_METHOD;
	NSString *nodeName = nil, *hrefURL = nil, *textContent = nil;
	id attributes = nil;
	BOOL hasAttributes = NO;
	NSMutableDictionary *attributesDict = [NSMutableDictionary dictionary];
	int length = 0;
	
	// get element text info
	if( [element respondsToSelector:@selector( nodeName )] )
		nodeName = objc_msgSend( element, @selector( nodeName ) );
	if( [element respondsToSelector:@selector( hrefURL )] )
		hrefURL = objc_msgSend( element, @selector( hrefURL ) );
	if( [element respondsToSelector:@selector( textContent )] )
		textContent = objc_msgSend( element, @selector( textContent ) );
	
	// check if this element has any attributes
	if( [element respondsToSelector:@selector( hasAttributes )] )
		hasAttributes = ((BOOL (*)(id, SEL))objc_msgSend)( element, @selector( hasAttributes ) );
	if( [element respondsToSelector:@selector( attributes )] )
		attributes = objc_msgSend( element, @selector( attributes ) );
	if( [attributes respondsToSelector:@selector( length )] )
		length = ((int (*)(id, SEL))objc_msgSend)( attributes, @selector( length ) );
	
	if( hasAttributes ) {
		int i = 0;
		for( i = 0; i < length; i++ ) {
			id item = nil;
			NSString *name = nil;
			NSString *value = nil;
			if( ![attributes respondsToSelector:@selector( item: )] )
				break;
			item = objc_msgSend( attributes, @selector( item: ), i );
			if( ![item respondsToSelector:@selector( name )] )
				break;
			if( ![item respondsToSelector:@selector( value )] )
				break;
			name = objc_msgSend( item, @selector( name ) );
			value = objc_msgSend( item, @selector( value ) );
			if( name && value )
				[attributesDict setObject:value forKey:name];
		}
	}
	if( [self.delegate respondsToSelector:@selector(willClickElementHrefURL:textContent:attributes:inWebView:)] )
		[(NSObject*)self.delegate willClickElementHrefURL:hrefURL textContent:textContent attributes:attributesDict inWebView:self];
}

#pragma mark -
#pragma mark Original method for call delegate method

- (void)hookedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if( [self.delegate respondsToSelector:@selector(touchesBegan:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesBegan:touches inWebView:self withEvent:event];
}

- (void)hookedTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if( [self.delegate respondsToSelector:@selector(touchesMoved:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesMoved:touches inWebView:self withEvent:event];
}

- (void)hookedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if( [self.delegate respondsToSelector:@selector(touchesEnded:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesEnded:touches inWebView:self withEvent:event];
}

- (void)hookedTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if( [self.delegate respondsToSelector:@selector(touchesCancelled:inWebView:withEvent:)] )
		[(NSObject*)self.delegate touchesCancelled:touches inWebView:self withEvent:event];
}

#pragma mark -
#pragma mark Original method

- (void)setupPolicyDelegate:(id)delegate {
	id webDocumentView;		// UIWebDocumentView
	id webView;				// WebView
	webDocumentView = objc_msgSend( self, @selector(_documentView) );
	object_getInstanceVariable( webDocumentView, "_webView", (void**)&webView );
	objc_msgSend( webView, @selector(setPolicyDelegate:), delegate );
}

#pragma mark -
#pragma mark Override UIWebView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[UICWebView installHook];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	LOG_CURRENT_METHOD;
    if (self = [super initWithCoder:coder]) {
		[UICWebView installHook];
    }
    return self;
}

@end
