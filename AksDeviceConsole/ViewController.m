//
//  ViewController.m
//  AksDeviceConsole
//
//  Created by Alok on 02/09/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(printTestData) userInfo:nil repeats:YES];
}

- (void)printTestData {
	NSLog(@"\n______________ON DEVICE CONSOLE__________");
	NSLog(@"all your device console text can be seen using this control");
	NSLog(@"swipe left and right to hide and show the console.");
	NSLog(@"Just write [AKSDeviceConsole startService] in didFinishLaunchingWithOptions\n");
	NSLog(@"Enjoy easy debugging\n");
}

@end
