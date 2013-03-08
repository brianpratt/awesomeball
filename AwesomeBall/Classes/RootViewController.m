//
//  RootViewController.m
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
//  RootViewController is the main View Controller. It owns the GLViewController (the OpenGL ball view)
//  and the SettingsViewController, where all the settings are kept.

#import "RootViewController.h"
#import "TextureLoader.h"
#import "GLView.h"
#import "UserDefaults.h"

static RootViewController * singleton;


// A class extension to declare private methods and variables
@interface RootViewController ()

- (void)loadSettingsViewController;

@end


@implementation RootViewController

@synthesize	settingsViewController;
@synthesize glViewController;
@synthesize hasReceivedMemoryWarning;
@synthesize imageView;


+ (RootViewController *) getSingleton {
	return singleton;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    //NSLog(@"rootviewcontroller initWithNibName");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		hasReceivedMemoryWarning = NO;
		singleton = self;
    }
    return self;
}

- (void) showAlert:(NSString*)title withMessage:(NSString*)message
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor blackColor];
	//NSLog(@"rootviewcontroller viewDidLoad");

    [super viewDidLoad];
	// Set up GLView
	if (!glViewController) {
		GLViewController *viewController = [[GLViewController alloc] initWithNibName: nil bundle:nil];
		
		self.glViewController = viewController;
		
		// Set this as the delegate
		[self.glViewController setDelegate:self];
		
		[self.view addSubview:self.glViewController.view];
	}
	//NSLog(@"exiting rootviewcontroller viewDidLoad");
	
}


#pragma mark ----- Toggle View Methods -----


- (void)loadSettingsViewController {
    // Load the Settings View and Controller into memory
    SettingsViewController *viewController = nil;
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0)
        viewController = [[SettingsViewController alloc] initWithNibName:@"SettingsView-568h" bundle:nil];
    else
        viewController = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
	// Not behind the Status Bar, so shift down by 20px
    CGRect newframe = settingsViewController.view.frame;
    newframe.origin.y = 20.0;
	settingsViewController.view.frame = newframe;
    self.settingsViewController = viewController;
	
	// Set this object as the delegate
	[self.settingsViewController setDelegate:self];
	
}

- (void)toggleView {    
    /*
     This method is called when the Main View is double-tapped or the Done button is pressed on the Settings View.
     It flips the displayed view from the GL view to the flipside view and vice-versa.
     */
    if (settingsViewController == nil) {
        [self loadSettingsViewController];
    }
	// Make sure SettingsView hasn't shifted down... (happens after a memory warning)
	// (Not behind the Status Bar, so shift down by 20px)
    CGRect newframe = settingsViewController.view.frame;
    newframe.origin.y = 20.0;
	settingsViewController.view.frame = newframe;
	
	// Special case: Hi-Res graphics state was toggled. Need to re-load the GLView
	if ([glViewController.view superview] == nil && [UserDefaults enableHiResGraphicsChanged]) {
		[glViewController reloadGLView];
		
		// Responded to change. Reset status.
		[UserDefaults setEnableHiResGraphicsChanged: NO];
	}
	
	static float animationDuration = 1.0;
    
    UIView *glView = glViewController.view;
    UIView *settingsView = settingsViewController.view;
        
    if ([glView superview] != nil) {
		// GLView is on top. Switch to SettingsView.
		// Set up flip animation
		[UIView beginAnimations:@"showSettingsView" context:NULL];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationStopped:finished:context:)];
		
		// Notify ViewControllers of what is going to happen.
        [settingsViewController viewWillAppear:YES];
        [glViewController viewWillDisappear:YES];
        [glView removeFromSuperview];
        [self.view addSubview:settingsView];
    } else {
		// SettingsView is on top. Switch to GLView.
		// Set up flip animation
		[UIView beginAnimations:@"showGLView" context:NULL];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationStopped:finished:context:)];
		
		// unload all textures before swapping
		[EAGLContext setCurrentContext: [GLPreView getStaticContext]];
		[TextureLoader releaseAll];
		[EAGLContext setCurrentContext: [GLView getStaticContext]];
		
		// Notify ViewControllers of what is going to happen.
        [glViewController viewWillAppear:YES];
        [settingsViewController viewWillDisappear:YES];
        [settingsView removeFromSuperview];
        [self.view addSubview:glView];
    }
    [UIView commitAnimations];
}

- (void) animationStopped: (NSString *)animationID finished: (BOOL) finished context: (void *) context {
	// Animation callback to let the respective ViewControllers know when the animation has finished.
	if ([animationID isEqualToString:@"showSettingsView"]) {
        [glViewController viewDidDisappear:YES];
        [settingsViewController viewDidAppear:YES];
	}
	else if ([animationID isEqualToString:@"showGLView"]) {
        [settingsViewController viewDidDisappear:YES];
		[glViewController viewDidAppear:YES];
	}
}


#pragma mark ----- Memory/Dealloc Methods -----

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	//[self showAlert:@"Memory Warning" withMessage:@"Your iPhone is low on memory. For best performance, please reboot your phone to free up some memory."];
	if (!self.hasReceivedMemoryWarning) {
		//NSString *memoryWarningTitle = NSLocalizedString(@"Memory Warning", @"Memory Warning Message Title");
		//NSString *memoryWarningMessage = NSLocalizedString(@"Memory Warning Message Body", @"Memory Warning Message Body");
		//[self showAlert:memoryWarningTitle withMessage:memoryWarningMessage];
	}
	// Keep track of any memory warnings during this session. Others will use this information to keep memory usage
	// down at the cost of performance.
	self.hasReceivedMemoryWarning = YES;
}



@end
