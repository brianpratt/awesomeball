//
//  CustomBallViewController.m
//  AwesomeBall
//
//  Created by Brian Pratt on 2/26/09.
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
//  CustomBallViewController controls the view presented to the user when
//  customizing a ball. The user can choose a built-in ball image or their
//  own image and can customize some of the ball parameters.

#import "CustomBallViewController.h"
#import "UserDefaults.h"

#define kBallImagePickerViewHeight 216.0
#define kNavigationBarHeight 44.0


@implementation CustomBallViewController

@synthesize bottomView;
@synthesize radiusSlider;
@synthesize massSlider;
@synthesize bounceSlider;
@synthesize pickerNavigationBar;
@synthesize ballImagePickerView;
@synthesize ballImagePickerController;
@synthesize currentBallIndex;

// Default values for non-4-inch display
float kSelfViewHeight = 460.0;


- (void) showAlert:(NSString*)title withMessage:(NSString*)message
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		ballTypes = [BallTypes singleton];
		
        if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0) {
            // Override default values for 4-inch display
            kSelfViewHeight = 548.0;
        }
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.bottomView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	// Load saved customBallIndex
	self.currentBallIndex = [UserDefaults customBallIndex];
	
	// Set the sliders to the correct positions
	unsigned customBallIndex = [ballTypes customBallIndex];
	[self.radiusSlider setValue:[ballTypes radiusOfBallAtIndex:customBallIndex]];
	[self.massSlider setValue:[ballTypes massOfBallAtIndex:customBallIndex]];
	[self.bounceSlider setValue:[ballTypes bounceOfBallAtIndex:customBallIndex]];
	
	// Set up BallImagePickerController
    BallImagePickerController *aBallImagePickerController = [[BallImagePickerController alloc] init];
	[aBallImagePickerController setDelegate:self];
	self.ballImagePickerController = aBallImagePickerController;
	
	// Set up the BallImagePickerView
	UIPickerView *aBallImagePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, kSelfViewHeight-kBallImagePickerViewHeight, 320.0, kBallImagePickerViewHeight)];
	aBallImagePickerView.showsSelectionIndicator = YES;
	aBallImagePickerView.delegate = ballImagePickerController;
	aBallImagePickerView.dataSource = ballImagePickerController;
	self.ballImagePickerView = aBallImagePickerView;
	
    // Set up the Picker navigation bar
    UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, kSelfViewHeight-kBallImagePickerViewHeight-kNavigationBarHeight, 320.0, kNavigationBarHeight)];
    aNavigationBar.barStyle = UIBarStyleBlackOpaque;
    self.pickerNavigationBar = aNavigationBar;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeBallImagePickerView)];
	NSString *selectBallImageTitle = NSLocalizedString(@"Select Ball Image:", @"Select Ball Image title");
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:selectBallImageTitle];
    navigationItem.rightBarButtonItem = buttonItem;
    [pickerNavigationBar pushNavigationItem:navigationItem animated:NO];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark ----- Memory/Dealloc -----


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	//[self showAlert:@"Memory Warning" withMessage:@"Your iPhone is low on memory. Please reboot your phone to free up memory. (CBVC)"];
}





#pragma mark ----- Accessor Methods -----


- (void)setDelegate:(id)aDelegate {
	// The delegate will be the SettingsViewController
	delegate = aDelegate;
}


#pragma mark ----- IBAction Methods -----


- (IBAction) done:(id)sender {
	// Make sure delegate has the latest update
	[delegate setBallTypeIndex:[ballTypes customBallIndex]];
	
	// Save Custom Ball Settings
	[UserDefaults setCustomBallIndex:self.currentBallIndex];
	[UserDefaults saveCustomBallParameters];
	
	[delegate removeCustomBallView];
}

- (IBAction) chooseCustomBallImage:(id)sender {
	// User wants to use one of their own images for the custom ball
	// Notify the delagate, which handles custom images
	
	// Start up image picker
	[delegate chooseCustomBallImage];
}

- (IBAction) chooseBuiltInBallImage:(id)sender {
	// User wants to pick a built-in image for the custom ball.
	// Bring in the BallImagePicker
		
	// Pop-up the BallImagePickerView
	if (!self.ballImagePickerView.superview) {
		
		[self.view addSubview:ballImagePickerView];
        [self.view addSubview:pickerNavigationBar];
		
		// Move these subviews off the screen
		pickerNavigationBar.frame = CGRectMake(0.0, kSelfViewHeight, 320.0, kNavigationBarHeight);
		ballImagePickerView.frame = CGRectMake(0.0, kSelfViewHeight+kNavigationBarHeight, 320.0, kBallImagePickerViewHeight);
		
		// Slide them in for a nice effect
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		ballImagePickerView.frame = CGRectMake(0.0, kSelfViewHeight-kBallImagePickerViewHeight, 320.0, kBallImagePickerViewHeight);
		pickerNavigationBar.frame = CGRectMake(0.0, kSelfViewHeight-kBallImagePickerViewHeight-kNavigationBarHeight, 320.0, kNavigationBarHeight);
		
		[UIView commitAnimations];
		
	}
	
	// Make sure the picker selects the ball that was previously selected
	[self.ballImagePickerView selectRow:self.currentBallIndex inComponent:0 animated:NO];
	// Make sure the ball that is selected in the picker is the one displayed
	[self setCustomBallImageAndSoundsToBallIndex:self.currentBallIndex];
	
	// Save User Preference
	[UserDefaults setShouldUseCustomBallIndex:YES];
	
}

- (IBAction) radiusSliderAction:(id)sender {
	// Grab the value of the slider
	UISlider* slider = (UISlider *)sender;
	CGFloat radius = [slider value];
	
	// Set the custom ball radius
	[ballTypes setCustomBallRadius:radius];
	
	// Inform the delegate (SettingsViewController) of the update
	[delegate setCustomBallSize:radius];
	
}

- (IBAction) massSliderAction:(id)sender {
	// Grab the value of the slider
	UISlider* slider = (UISlider *)sender;
	CGFloat mass = [slider value];
	
	// Set the custom ball mass
	[ballTypes setCustomBallMass:mass];
	
	// Inform delegate of update?
	
}

- (IBAction) bounceSliderAction:(id)sender {
	// Grab the value of the slider
	UISlider* slider = (UISlider *)sender;
	CGFloat bounce = [slider value];
	
	// Set the custom ball bounce
	[ballTypes setCustomBallBounce:bounce];
	
	// Inform the delegate (SettingsViewController) of the update
	[delegate setCustomBallBounce:bounce];
	
}


#pragma mark ----- BallImagePickerControllerDelegate Methods -----

- (void) setCustomBallImageAndSoundsToBallIndex:(unsigned) index {
	// Called by the BallImagePicker when the user selects a built-in image for the custom ball
	
	// Inform the SettingsViewController of the selection so it can update the GLPreView in real time
	[delegate setCustomBallImageAndSoundsToBallIndex:index];
	
	self.currentBallIndex = index;
}


#pragma mark ----- Helper Methods -----

- (void) removeBallImagePickerView {
	// Remove the BallImagePickerView from the foreground
	// Slide it off the screen
	
	// Move these subviews off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// For each SubView, schedule the view to be removed from the superview a little after the animation has finished
	
	// Remove the navigation bar
	if (self.pickerNavigationBar.superview) {
		self.pickerNavigationBar.frame = CGRectMake(0.0, kSelfViewHeight, 320.0, kNavigationBarHeight);
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.pickerNavigationBar selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	}
	
	// Remove the BallPicker View
	if (self.ballImagePickerView.superview) {
		self.ballImagePickerView.frame = CGRectMake(0.0, kSelfViewHeight+kNavigationBarHeight, 320.0, kBallImagePickerViewHeight);
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.ballImagePickerView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	}
	
	[UIView commitAnimations];
	
}


@end
