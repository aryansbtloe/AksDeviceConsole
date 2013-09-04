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

- (void)viewDidLoad
{
    [super viewDidLoad];
	[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(printTestData) userInfo:nil repeats:YES];
}
-(void)printTestData{
	NSLog(@"\n\n\n\n\n\n\n\n\n\n\n______________ON DEVICE CONSOLE__________");
	NSLog(@"all your device console text can be seen using this control");
	NSLog(@"so enjoy smart coding");
	NSLog(@"USAGE:");
	NSLog(@"just do a three seconds touch gesture from any where of your application.");
	NSLog(@"and console will popup automatically.");
	NSLog(@"Just write       [AKSDeviceConsole startService]      in application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions\n\n\n\n\n\n\n\n\n");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
