//
//  SNFAppDelegate.m
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2012 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "SNFAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation SNFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	
	// audio stuff
	OSStatus audioErr = noErr;
	audioErr = AudioSessionInitialize(NULL,
									  kCFRunLoopDefaultMode,
									  NULL,
									  (__bridge void *)(self));
	if (audioErr) {
		NSLog (@"Couldn't initialize audio session, %ld", audioErr);
	}
	int audioCategory = kAudioSessionCategory_RecordAudio;
	UInt32 propSize = sizeof(audioCategory);
	audioErr = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
									   propSize,
									   &audioCategory);
	if (audioErr) {
		NSLog (@"Couldn't set record category, %ld", audioErr);
	}
	
//	int audioMode = kAudioSessionMode_Measurement;
	int audioMode = kAudioSessionMode_VideoRecording;
	propSize = sizeof (audioMode);
	audioErr = AudioSessionSetProperty(kAudioSessionProperty_Mode,
									   propSize,
									   &audioMode);
	if (audioErr) {
		NSLog (@"Couldn't set mode, %ld", audioErr);
	}

	NSDictionary *audioRouteDict = nil;
	propSize = sizeof (audioRouteDict);
	audioErr = AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription,
									   &propSize,
									   &audioRouteDict);
	NSLog (@"routes: %@", audioRouteDict);
	if (audioErr) {
		NSLog (@"Couldn't get route, %ld", audioErr);
	}

	
	[[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
		NSLog (@"audio permission %@", granted ? @"granted" : @"not granted");
	}];
	
	NSError *avErr = nil;
	[[AVAudioSession sharedInstance] setActive:YES error:&avErr];

	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
