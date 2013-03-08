//
//  GLViewController.m
//  AwesomeBall
//
//  Created by Brian Pratt on 2/18/09.
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
//  GLViewController owns the OpenGL view. It handles the loading and unloading
//  of that view.

#import "GLViewController.h"
#import "GLView.h"
#import "UserDefaults.h"
#import "GLWalls.h"
#import "FreePlay.h"
#import "RootViewController.h"
#import "AwesomeBallAppDelegate.h"

static GLViewController * singleton;


@implementation GLViewController

@synthesize glView;
@synthesize settingsButton;
@synthesize m_gameType;


+ (GLViewController *) getSingleton {
	return singleton;
}


- (void) showAlert:(NSString*)title withMessage:(NSString*)message
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		singleton = self;
		if (!self.view)
			[self loadView];
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// Custom initialization
	if (!glView) {
		glView = [[GLView alloc] initWithFrame: [[UIScreen mainScreen] bounds]]; // Entire application screen

		// for now the only game type is free play -- we'll add more and a menu later on
		if (!m_gameType)
			m_gameType = [[FreePlay alloc] initWithGLView: glView];
		glView.m_gameType = m_gameType;

		[m_gameType setupGLView: glView.bounds];
		
		// Load user settings
		[m_gameType setCameraFollowsBall:[UserDefaults cameraFollowsBall]];
		
		
		glView.m_animationInterval = 1.0 / 30.0;
		[glView startAnimation];
		
		// Enable Multi-touch
		glView.multipleTouchEnabled = YES;
        
        // Add button to switch to settings view
        [self addSettingsButton];
	}
	self.view = glView;
	
}

- (void) reloadGLView {
	// Re-load the GLView
	// This is required if you need to change the graphics scale (for Retina display support)
	
	self.view = nil; // Release old glView
	
	glView = [[GLView alloc] initWithFrame: [[UIScreen mainScreen] bounds]]; // Entire application screen
	glView.m_gameType = m_gameType;
	
	[m_gameType setGLView: glView];
	[m_gameType setupGLView: glView.bounds];
	
	glView.m_animationInterval = 1.0 / 30.0;
	
	// Enable Multi-touch
	glView.multipleTouchEnabled = YES;
    
    // Add button to switch to settings view
    [self addSettingsButton];
	
	self.view = glView;
	
}

- (void)addSettingsButton {
    // Create button to switch to settings view
    UIImage *buttonImage = [UIImage imageNamed:@"gear.png"];
    settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(glView.frame.size.width-50.0, glView.frame.size.height-50.0, 50.0, 50.0);
    settingsButton.contentMode = UIViewContentModeCenter;
    [settingsButton setImage:buttonImage forState:UIControlStateNormal];
    [settingsButton setAlpha:0.25];
    [settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // Add as a subview of the GLView
    [glView addSubview:settingsButton];
}

- (void) settingsButtonPressed:(id)sender {
	// User wants to go to the SettingsView
	[delegate toggleView];
}

#pragma mark ----- View Appearing/Disappearing Methods -----

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	//////////
	// Apply settings before switching to the GLView
	// TODO: Could hold the custom UIImages in memory until they are used, then dump them (for faster load times, but higher temporary memory usage)
	
	[EAGLContext setCurrentContext: [GLView getStaticContext]];

	// Let the game type make any changes it needs to first
	[m_gameType viewWillAppear:animated];
	
	// General Settings
	if ([UserDefaults cameraFollowsBallChanged]) {
		[m_gameType setCameraFollowsBall:[UserDefaults cameraFollowsBall]];
		// Register this change as having been applied
		[UserDefaults setCameraFollowsBallChanged: NO];
	}
	
	// Environment Settings
	if ([UserDefaults customWallImagesChanged]) {
		[m_gameType.m_walls loadImagesForWalls: YES andFloor: NO];
		// Mark this change as having been applied
		[UserDefaults setCustomWallImagesChanged: NO];
	}
	if ([UserDefaults customFloorImageChanged]) {
		[m_gameType.m_walls loadImagesForWalls: NO andFloor: YES];
		// Mark this change as having been applied
		[UserDefaults setCustomFloorImageChanged: NO];
	}
	// Show or hide the status bar based on the UserDefaults value
	[[AwesomeBallAppDelegate theApplication] setStatusBarHidden: [UserDefaults hideStatusBar]];
	
	// Ball Settings
	if ([UserDefaults ballTypeChanged] || [UserDefaults customBallParametersChanged] || [UserDefaults customBallImageChanged]) {
		[m_gameType setBallTypeIndex:[UserDefaults ballIndex] reloadCustomImage: [UserDefaults customBallImageChanged]];
			
		// Register these changes as having been applied
		[UserDefaults setBallTypeChanged: NO];
		[UserDefaults setCustomBallParametersChanged: NO];
		[UserDefaults setCustomBallImageChanged: NO];
	}
	
	
	//////////
	// Re-start animation
	[glView startAnimation];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[glView stopAnimation];
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark ----- Accessor Methods -----


- (void) setDelegate:(id)newDelegate {
	delegate = newDelegate;
}


#pragma mark ----- Touch Methods -----

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[m_gameType touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[m_gameType touchesMoved: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[m_gameType touchesEnded: touches withEvent: event];
	
	UITouch * touch = [touches anyObject];
	
	if ([touch tapCount] == 2) {
		//Double tap.
		//NSLog(@"\tDouble tap");
		// Flip to Settings View
		[delegate toggleView];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[m_gameType touchesCancelled: touches withEvent: event];
}



#pragma mark ----- Memory/Dealloc -----


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	//[self showAlert:@"Memory Warning" withMessage:@"Your iPhone is low on memory. Please reboot your phone to free up memory. (GLVC)"];
}



@end
