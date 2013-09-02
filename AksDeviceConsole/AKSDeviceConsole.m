//
//  Betify
//
//  Created by Alok on 2/09/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "AKSDeviceConsole.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define AKS_LOG_FILE_PATH [[AKSDeviceConsole documentsDirectory] stringByAppendingPathComponent:@"ns.log"]
#define APPDELEGATE                                     ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AKSDeviceConsole () {
	UIView *holderView;
	UITextView *textView;
}
@end

@implementation AKSDeviceConsole

+ (id)sharedInstance {
	static id __sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    __sharedInstance = [[AKSDeviceConsole alloc]init];
	});
	return __sharedInstance;
}

+ (NSMutableString *)documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}

- (id)init {
	if (self = [super init]) {
		[self initialSetup];
	}
	return self;
}

- (void)initialSetup {
	[self resetLogData];
	[self addGestureRecogniser];
}

+ (void)startService {
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
	    [AKSDeviceConsole sharedInstance];
	});
}

- (void)resetLogData {
	[NSFileManager.defaultManager removeItemAtPath:AKS_LOG_FILE_PATH error:nil];
	freopen([AKS_LOG_FILE_PATH fileSystemRepresentation], "a", stderr);
}

- (void)addGestureRecogniser {
	UILongPressGestureRecognizer *recognizer = [UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(showConsole)];
	recognizer.minimumPressDuration = 3;
	recognizer.numberOfTouchesRequired = 1;
	[APPDELEGATE.window addGestureRecognizer:recognizer];
}

- (void)showConsole {
	if (holderView == nil) {
		holderView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
		[holderView setBackgroundColor:[UIColor clearColor]];

		UIView *viewForFadeEffect = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
		[viewForFadeEffect setBackgroundColor:[UIColor blackColor]];
		viewForFadeEffect.layer.opacity = 0.7;

		UIButton *closeButton = [[UIButton alloc]init];
		[closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
		[closeButton addTarget:self action:@selector(hideWithAnimation) forControlEvents:UIControlEventTouchUpInside];

		CGRect viewRect = CGRectInset([[UIScreen mainScreen] bounds], 5, 44);;

		textView = [[UITextView alloc]initWithFrame:viewRect];
		[textView setBackgroundColor:[UIColor whiteColor]];
		textView.layer.borderWidth = 2;
		textView.layer.masksToBounds = TRUE;
		textView.layer.cornerRadius  = 4;
		[textView setEditable:NO];

		[closeButton setFrame:CGRectMake(viewRect.origin.x + viewRect.size.width - 31, viewRect.origin.y + viewRect.size.height - 31, 29, 29)];

		[holderView addSubview:viewForFadeEffect];
		[holderView addSubview:textView];
		[holderView addSubview:closeButton];
		[APPDELEGATE.window addSubview:holderView];
		[APPDELEGATE.window bringSubviewToFront:holderView];

		[self fadeInThisView:[[NSArray alloc]initWithObjects:holderView, nil] duration:0.75];

		[self setUpToGetLogData];
		[self scrollToLast];
	}
}

- (void)hideWithAnimation {
	[self fadeOutThisView:[[NSArray alloc]initWithObjects:holderView, nil] duration:0.5];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    [self hideConsole];
	});
}

- (void)hideConsole {
	[holderView removeFromSuperview];
	[NSNotificationCenter.defaultCenter removeObserver:self];
	holderView  = nil;
}

- (void)scrollToLast {
	NSRange txtOutputRange;
	txtOutputRange.location = textView.text.length;
	txtOutputRange.length = 0;
	textView.editable = YES;
	[textView scrollRangeToVisible:txtOutputRange];
	[textView setSelectedRange:txtOutputRange];
	textView.editable = NO;
}

- (void)setUpToGetLogData {
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:AKS_LOG_FILE_PATH];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(getData:) name:@"NSFileHandleReadCompletionNotification" object:fileHandle];
	[fileHandle readInBackgroundAndNotify];
}

- (void)getData:(NSNotification *)notification {
	NSData *data = notification.userInfo[NSFileHandleNotificationDataItem];
	if (data.length) {
		NSString *string = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
		textView.editable = YES;
		textView.text = [textView.text stringByAppendingString:string];
		textView.editable = NO;
		[self scrollToLast];
		[notification.object readInBackgroundAndNotify];
	}
	else {
		[self performSelector:@selector(refreshLog:) withObject:notification afterDelay:1.0];
	}
}

- (void)refreshLog:(NSNotification *)notification {
	[notification.object readInBackgroundAndNotify];
}


- (void)fadeInThisView:(NSArray *)views duration:(float)dur;
{
	for (int i = 0; i  < views.count; i++) {
		UIView *view = [views objectAtIndex:i];

		view.alpha = 0;
		view.hidden = NO;

		[UIView animateWithDuration:dur animations: ^
         {
             view.alpha = 1;
         }];
	}
}


- (void)fadeOutThisView:(NSArray *)views duration:(float)dur;
{
	for (int i = 0; i  < views.count; i++) {
		UIView *view = [views objectAtIndex:i];

		[UIView animateWithDuration:dur animations: ^
         {
             view.alpha = 0;
         }

		                 completion: ^(BOOL finished)
         {
             view.hidden = YES;
         }];
	}
}

@end
