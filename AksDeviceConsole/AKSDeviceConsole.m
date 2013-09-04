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
	recognizer.minimumPressDuration = 1;
	recognizer.numberOfTouchesRequired = 1;
	[APPDELEGATE.window addGestureRecognizer:recognizer];
}

- (void)showConsole {
	if (textView == nil) {
		CGRect bounds = [[UIScreen mainScreen] bounds];
		CGRect viewRectTextView = CGRectMake(15,bounds.size.height - bounds.size.height/3 - 60 ,bounds.size.width-30,bounds.size.height/3);

		textView = [[UITextView alloc]initWithFrame:viewRectTextView];
		[textView setBackgroundColor:[UIColor whiteColor]];
		textView.layer.borderWidth = 1;
		textView.layer.masksToBounds = TRUE;
		textView.layer.cornerRadius  = 4;
		[textView setEditable:NO];

		[APPDELEGATE.window addSubview:textView];
		[APPDELEGATE.window bringSubviewToFront:textView];

		UISwipeGestureRecognizer * recogniser = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideWithAnimation)];
		[recogniser setDirection:UISwipeGestureRecognizerDirectionLeft];
		[textView addGestureRecognizer:recogniser];

		[self fadeInThisView:[[NSArray alloc]initWithObjects:textView, nil] duration:0.40];
		[self setUpToGetLogData];
		[self scrollToLast];
	}
}

- (void)hideWithAnimation {
	[self moveThisViewTowardsLeft:[[NSArray alloc]initWithObjects:textView, nil] duration:0.30];
	[self fadeOutThisView:[[NSArray alloc]initWithObjects:textView, nil] duration:0.40];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    [self hideConsole];
	});
}

- (void)hideConsole {
	[textView removeFromSuperview];
	[NSNotificationCenter.defaultCenter removeObserver:self];
	textView  = nil;
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
		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self scrollToLast];
		});
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

- (void)moveThisViewTowardsLeft:(NSArray *)views duration:(float)dur;
{
	for (int i = 0; i  < views.count; i++) {
		UIView *view = [views objectAtIndex:i];

		[UIView animateWithDuration:dur animations: ^
         {
			 [view setFrame:CGRectMake(view.frame.origin.x - [[UIScreen mainScreen]bounds].size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
         }

		                 completion: ^(BOOL finished)
         {
         }];
	}
}


@end
