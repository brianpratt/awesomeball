//
//  AwesomeBallAppDelegate.m
//  AwesomeBall
//
//  Created by Jonathan Johnson on 2/13/09.
//  Copyright 2009-2013 Jonathan Johnson and Brian Pratt. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
//    in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
//  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
//  AwesomeBallAppDelegate loads the Awesome Ball app

#import "AwesomeBallAppDelegate.h"
#import "RootViewController.h"
#import "UserDefaults.h"
#import "BallTypes.h"

static UIApplication * theApplication;


@implementation AwesomeBallAppDelegate

@synthesize window;
@synthesize rootViewController;

+ (UIApplication *) theApplication {
	return theApplication;
}


- (void) loadSavedSettings {
	
	// Load saved custom ball parameters and image
	BallTypes * ballTypes = [BallTypes singleton];
	if ([UserDefaults shouldUseCustomBallIndex]) {
		unsigned index = [UserDefaults customBallIndex];
		// Update ball image in BallTypes
		[ballTypes setCustomBallImageFile:[ballTypes imageFileForBallAtIndex:index]];
		// Also update bounce sound
		[ballTypes setCustomBallSounds:index];
	}
	else {
		// Check for a saved custom image
		UIImage * customImage = [UserDefaults customBallImage];
		if (customImage != nil)
			[ballTypes useCustomBallImage];
	}
	[ballTypes setCustomBallRadius:[UserDefaults customBallRadius]];
	[ballTypes setCustomBallMass:[UserDefaults customBallMass]];
	[ballTypes setCustomBallBounce:[UserDefaults customBallBounce]];

}



- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	theApplication = application;
	
	// Behind the Status bar
	window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	// Load saved settings
	[self loadSavedSettings];

	// Launch RootViewController
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0)
        rootViewController = [[RootViewController alloc] initWithNibName: @"RootViewController-568h" bundle: [NSBundle mainBundle]];
    else
        rootViewController = [[RootViewController alloc] initWithNibName: @"RootViewController" bundle: [NSBundle mainBundle]];
	
	[window addSubview: rootViewController.view];
	[window makeKeyAndVisible];

}


- (void)applicationWillResignActive:(UIApplication *)application {
	[UserDefaults forceSynchronization];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {
	[UserDefaults forceSynchronization];
	
}



@end
