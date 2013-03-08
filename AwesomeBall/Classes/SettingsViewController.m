//
//  SettingsViewController.m
//  AwesomeBall
//
//  Created by Brian Pratt on 2/17/09.
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
//  SettingsViewController is a beast of a class that handles all of the 
//  settings available to the user including custom images, ball type, 
//  custom ball settings. Most of the settings are stored using the
//  UserDefaults class, but are set here.

#import "SettingsViewController.h"
#import "UserDefaults.h"
#import "TextureLoader.h"
#import "RootViewController.h"
#import "AwesomeBallAppDelegate.h"
#import "ImageManipulation.h"

#define kScrollViewContentHeight 614.0
#define kBallPickerViewHeight 216.0
#define kNavigationBarHeight 44.0
#define kGLPreViewHeight (kSettingsViewHeight-kBallPickerViewHeight-kNavigationBarHeight)
#define kCustomBallSubViewHeight 216.0


static inline double radians (double degrees) {return degrees * M_PI/180;}

static SettingsViewController * singleton;


// A class extension to declare private methods and variables
@interface SettingsViewController ()

- (void) updateVersionLabel;
- (void) updateBounceCountView;

@end


@implementation SettingsViewController

@synthesize scrollView;
@synthesize selectBallButton;
@synthesize cameraFollowsBallSwitch;
@synthesize settingsLabel;
@synthesize noTouchBackground;
@synthesize pickerNavigationBar;
@synthesize ballPickerController;
@synthesize ballPickerView;
@synthesize customBallViewController;
@synthesize glBallPreView;
@synthesize creditsView;
@synthesize creditsTextView;
@synthesize bounceCountLabel;
@synthesize versionLabel;
@synthesize currentBallIndex;
@synthesize infoButton;

// Internal Enumeration
typedef enum kImageTypeEnum {
	kImageTypeBall,
	kImageTypeWall,
	kImageTypeFloor
} kImageType;
// Global variable
kImageType nextImageType;

// Default values for non-4-inch display
float kSettingsViewHeight = 460.0;
float kHighScoresViewHeight = 460.0;
float kCustomBallViewHeight = 460.0;
// Image aspect ratios
// These must be inverses of each other
// These are expected to match the aspect ratio of the box
float kWideImageAspectRatio = (3.0/2.0); // 3:2
float kTallImageAspectRatio = (2.0/3.0);


+ (SettingsViewController *) getSingleton {
	return singleton;
}

#pragma mark ----- AlertView Methods -----

- (void) showAlert:(NSString*)title withMessage:(NSString*)message
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Callback for the reset bounce count alert view
	NSString* bounceCountTitle = NSLocalizedString(@"Reset Bounce Count", @"Reset Bounce Count title");
	// Callbacks for the hi-res graphics toggle alert views
	NSString* disableHiResGraphicsTitle = NSLocalizedString(@"Disable Hi-Res Graphics", @"Disable Hi-Res Graphics title");
	NSString* enableHiResGraphicsTitle = NSLocalizedString(@"Enable Hi-Res Graphics", @"Enable Hi-Res Graphics title");
	
	NSString* yes = NSLocalizedString(@"Yes", @"Yes button");
    
    NSString* alertViewTitle = [alertView title];
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
	
	// Make sure this is the bounce count alert view that is being responded to
	if ([alertViewTitle isEqualToString:bounceCountTitle] && [buttonTitle isEqualToString:yes]) {
		// The user clicked "yes"
		// Reset the bounce count
		[UserDefaults resetTotalBounceCount];
		[self updateBounceCountView];
	}
	else if ([alertViewTitle isEqualToString:enableHiResGraphicsTitle] && [buttonTitle isEqualToString:yes]) {
		// Enable Hi-res graphics
		[UserDefaults setEnableHiResGraphics: YES];
		
		// Update label
		[self updateVersionLabel];
		
		NSString* hiResGraphicsEnabledTitle = NSLocalizedString(@"Hi-Res Graphics Enabled!", @"Hi-Res Graphics Enabled title");
		NSString* hiResGraphicsEnabledMessage = NSLocalizedString(@"Disable this feature if Awesome Ball lags too much for your taste.\n\n(Shake your device in the Settings screen to disable)\n\nFor best results, re-create your custom images now.", @"Hi-Res Graphics Enabled message");
		[self showAlert:hiResGraphicsEnabledTitle withMessage:hiResGraphicsEnabledMessage];
	}
	else if ([alertViewTitle isEqualToString:disableHiResGraphicsTitle] && [buttonTitle isEqualToString:yes]) {
		// Disable Hi-res graphics
		[UserDefaults setEnableHiResGraphics: NO];
		
		// Update label
		[self updateVersionLabel];
		
		NSString* hiResGraphicsEnabledTitle = NSLocalizedString(@"Hi-Res Graphics Disabled", @"Hi-Res Graphics Disabled title");
		NSString* hiResGraphicsEnabledMessage = NSLocalizedString(@"Hi-Res graphics disabled for now.\n\n(Shake your device in the Settings screen to re-enable)", @"Hi-Res Graphics Disabled message");
		[self showAlert:hiResGraphicsEnabledTitle withMessage:hiResGraphicsEnabledMessage];
	}

}


#pragma mark ----- View Loading Methods -----


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		ballTypes = [BallTypes singleton];
		singleton = self;
        
        if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0) {
            // Override values for 4-inch display
            kSettingsViewHeight = 548.0;
            kHighScoresViewHeight = 548.0;
            kCustomBallViewHeight = 548.0;
            // Image aspect ratios
            // These must be inverses of each other
            // These are expected to match the aspect ratio of the box
            kWideImageAspectRatio = (16.0/9.0); // 16:9
            kTallImageAspectRatio = (9.0/16.0);
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
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	// Set the size of the scroll view manually:
	scrollView.frame = CGRectMake(0, 0, 320, kSettingsViewHeight);
	scrollView.contentSize = CGSizeMake(320, kScrollViewContentHeight);
	
	// Init current ball index to saved ball
	self.currentBallIndex = [UserDefaults ballIndex];
	
	// Load saved settings
	[cameraFollowsBallSwitch setOn:[UserDefaults cameraFollowsBall] animated:NO];
	
	// Update version label
	[self updateVersionLabel];
	
}

- (void)loadBallPickerController {
	// Loads the BallPickerView into memory
	
	// Set up BallPickerController
    BallPickerController *aBallPickerController = [[BallPickerController alloc] init];
	[aBallPickerController setDelegate:self];
	self.ballPickerController = aBallPickerController;
	
	// Set up the BallPickerView
	UIPickerView *aBallPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, kSettingsViewHeight-kBallPickerViewHeight, 320.0, kBallPickerViewHeight)];
	aBallPickerView.showsSelectionIndicator = YES;
	aBallPickerView.delegate = ballPickerController;
	aBallPickerView.dataSource = ballPickerController;
	self.ballPickerView = aBallPickerView;
	
    // Set up the Picker navigation bar
    UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, kSettingsViewHeight-kBallPickerViewHeight-kNavigationBarHeight, 320.0, kNavigationBarHeight)];
    aNavigationBar.barStyle = UIBarStyleBlackOpaque;
    self.pickerNavigationBar = aNavigationBar;
    //UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeAllPickerViews)];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishBallSelection)];
	NSString *ballPickerTitle = NSLocalizedString(@"Select Ball:", @"Ball Picker title");
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:ballPickerTitle];
    navigationItem.rightBarButtonItem = buttonItem;
    [pickerNavigationBar pushNavigationItem:navigationItem animated:NO];
	
}

- (void)loadCustomBallViewController {
	// Loads the CustomBallView into memory
    
    CustomBallViewController *viewController = nil;
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0)
        viewController = [[CustomBallViewController alloc] initWithNibName:@"CustomBallView-568h" bundle:nil];
    else
        viewController = [[CustomBallViewController alloc] initWithNibName:@"CustomBallView" bundle:nil];
    self.customBallViewController = viewController;
	
	// Set this as the delegate
	[self.customBallViewController setDelegate:self];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void) updateVersionLabel {
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *hires_message = @"";
	if ([UserDefaults enableHiResGraphics])
		hires_message = NSLocalizedString(@"\nHi-res graphics enabled", @"Hi-res graphics label text");

	versionLabel.text = [NSString stringWithFormat: @"Awesome Ball v%@%@", version, hires_message];
}

- (void) updateBounceCountView {
	
	// Make sure the user never *sees* the count not synchronize across runs
	[UserDefaults forceSynchronization];
	
	// Set bounce count string
	bounceCountLabel.text = [UserDefaults totalBounceCountString];
}


#pragma mark ----- View Appearing/Disappearing Methods -----

- (void)viewWillAppear:(BOOL)animated {
	// Called before the view is actually shown to the user
	[super viewWillAppear:animated];
	
	// Update the bounce count before the user sees it
	[self updateBounceCountView];
	
	// Load saved settings (could have changed due to Easter egg unlocking)
	[cameraFollowsBallSwitch setOn:[UserDefaults cameraFollowsBall] animated:YES];
	
	// Update current ball index to saved ball (index could have changed due to Easter egg unlocking)
	self.currentBallIndex = [UserDefaults ballIndex];
	
	settingsLabel.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	// Called after the view has fully appeared
	[super viewDidAppear:animated];
	
	// Set up the status bar
	[[AwesomeBallAppDelegate theApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent];
	[[AwesomeBallAppDelegate theApplication] setStatusBarHidden: NO];
	
	// Let the user know that this is a scrolling view
	[scrollView flashScrollIndicators];
	
	// load all of the texture we're going to need for the balls,
	// but only load them if we haven't gotten a memory warning yet.
	// Stop as soon as a memory warning is received (I don't think it actually ever does because of some thread issues)
	RootViewController * rvc = [RootViewController getSingleton];
	if (!rvc.hasReceivedMemoryWarning) {
		[EAGLContext setCurrentContext: [GLPreView getStaticContext]];
		int numBalls = [ballTypes numberOfBuiltInBalls]; // Don't load the custom ball image
		for (int i = 0; i < numBalls; i++) {
			[TextureLoader textureFromImageNamed: [ballTypes imageFileForBallAtIndex: i]];
			if (rvc.hasReceivedMemoryWarning) {
				break;
			}
		}
	}
	
	// Enable SettingsView as a shake view for iPhone 4 (or anything with a hi-res display)
	UIScreen *mainScreen = [UIScreen mainScreen];
	if ([mainScreen respondsToSelector:@selector(scale)] && [mainScreen scale] == 2.0)
		[self.view becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	// Called just before the view will disappear (to be replaced by the GLView)
	
	// Disable SettingsView as a shake view
    [self.view resignFirstResponder];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	// Called after the view is out of view of the user (and the GLView is up)
	[super viewDidDisappear:animated];
	
}


#pragma mark ----- Memory/Dealloc -----

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	
	// If the SettingsView is in the foreground, release all of the *ball* textures but the current one
	// This saves memory, but each ball texture will have to be loaded on the fly, slowing things down
	if ([self.view superview] != nil) {
		//[self showAlert:@"Memory Warning" withMessage:@"Your iPhone is low on memory. Please reboot your phone to free up memory. (SVC)"];
		
		// Get the names of all of the balls and release their textures one by one
		//   to avoid releasing the wall and floor textures
		// Two cases:
		// 1. Built-in ball: release all but current ball
		// 2. Custom ball: release all but current built-in ball index
		int saveBallTextureIndex;
		if (self.currentBallIndex != [ballTypes customBallIndex])
			saveBallTextureIndex = self.currentBallIndex;
		else {
			saveBallTextureIndex = [UserDefaults customBallIndex];
		}
		
		int numBalls = [ballTypes numberOfBuiltInBalls];
		for (int i = 0; i < numBalls; i++) {
			if (i != saveBallTextureIndex)
				[TextureLoader releaseTextureWithName: [ballTypes imageFileForBallAtIndex: i]];
		}
	}
}




#pragma mark ----- Accessor Methods -----


- (void) setDelegate:(id)newDelegate {
	delegate = newDelegate;
}


#pragma mark ----- E-mail Helper Methods -----

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void) displayMailComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject: NSLocalizedString(@"Check out this iPhone App!", @"E-mail Subject")];
	
	// Fill out the email body text
	// The e-mail body is long, so it's text is stored in the Localizable.strings file
	// The first argument to NSLocalizedString is really the key into that file
	NSString *bounceCount = [UserDefaults totalBounceCountString];
	NSString *bodyFormatString = NSLocalizedString(@"E-mail Body Format String", @"E-mail Body Format String");
	NSString *body = [NSString stringWithFormat:bodyFormatString, bounceCount];
	[picker setMessageBody: body isHTML: YES];
	
	[self presentModalViewController:picker animated:YES];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	// Notifies users about errors associated with the interface
	switch (result) {
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

// Send an e-mail through the iPhone Mail app
- (void) sendEmailTo:(NSString *)to withSubject:(NSString *) subject withBody:(NSString *)body {
	// A generic e-mail sending method. The message is escaped to be a URL and uses the UTF8 encoding 
	// to handle multiple languages
	NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
							[to stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							[subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							[body  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}

- (void) sendMailThroughMailApp {
	// The Pass the Ball button lets the user send a message to a friend with a link to AwesomeBall
	// on the App Store
	
	// Create an e-mail to send with a link to this app in the App Store
	static NSString *recipient = @"";
	NSString *subject = NSLocalizedString(@"Check out this iPhone App!", @"E-mail Subject");
	NSString *bounceCount = [UserDefaults totalBounceCountString];
	// The e-mail body is long, so it's text is stored in the Localizable.strings file
	// The first argument to NSLocalizedString is really the key into that file
	NSString *bodyFormatString = NSLocalizedString(@"E-mail Body Format String", @"E-mail Body Format String");
	NSString *body = [NSString stringWithFormat:bodyFormatString, bounceCount];
	
	[self sendEmailTo:recipient withSubject:subject withBody:body];
}


#pragma mark ----- IBActions -----

- (IBAction) done:(id)sender {
	// User wants to leave the SettingsView
	self.creditsView.hidden = YES;
	[delegate toggleView];
}

-(IBAction)passTheBall:(id)sender
{
	// The Pass the Ball button lets the user send a message to a friend with a link to AwesomeBall
	// on the App Store
	
	// This code can run on devices running iPhone OS 2.0 or later  
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
	// So, we must verify the existence of the above class and provide a workaround for devices running 
	// earlier versions of the iPhone OS. 
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
			[self displayMailComposerSheet];
		}
		else {
			[self sendMailThroughMailApp];
		}
	}
	else {
		[self sendMailThroughMailApp];
	}
}

- (IBAction) selectBall:(id)sender {
	// Pops up the BallPickerView for the user to select a ball
	// The GLPreView is also loaded to give the user a preview of the balls as they are selected
	
	// Pop-up the BallPickerView
	if (!self.ballPickerView.superview) {
		
		// Create a background to prevent any other touching while the picker is up
		if (!noTouchBackground) {
			noTouchBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, kGLPreViewHeight, 320.0, kSettingsViewHeight-kGLPreViewHeight)]; // Minus GLPreView area
			noTouchBackground.backgroundColor = [UIColor blackColor];
			noTouchBackground.opaque = NO;
			noTouchBackground.alpha = 0.0;
		}
		[self.view addSubview:noTouchBackground];
		
		// Add the GLBallPreView
		// Fade it in by setting the alpha channel to fully transparent at first and animating the change to full opacity
		GLPreView * aGLPreView = [[GLPreView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kGLPreViewHeight) andObjectType:glBallType];
		self.glBallPreView = aGLPreView;
		glBallPreView.alpha = 0.0;
		
		// Load the Ball Picker into memory if it isn't there already
		if (!self.ballPickerController || !self.ballPickerView)
			[self loadBallPickerController];
		
		// Bring all three views to the foreground
		[self.view addSubview:ballPickerView];
        [self.view addSubview:pickerNavigationBar];
		[self.view addSubview:glBallPreView];
		
		// Move these subviews off the screen
		// The animation will slide them onto the screen
		pickerNavigationBar.frame = CGRectMake(0.0, kSettingsViewHeight, 320.0, kNavigationBarHeight);
		ballPickerView.frame = CGRectMake(0.0, kSettingsViewHeight+kNavigationBarHeight, 320.0, kBallPickerViewHeight);
		
		// Slide them in for a nice effect
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		ballPickerView.frame = CGRectMake(0.0, kGLPreViewHeight+kNavigationBarHeight, 320.0, kBallPickerViewHeight);
		pickerNavigationBar.frame = CGRectMake(0.0, kGLPreViewHeight, 320.0, kNavigationBarHeight);
		// Fade in the no-touch background
		noTouchBackground.alpha = 0.75;
		// Fade in the GLBallPreView
		glBallPreView.alpha = 1.0;
		[UIView commitAnimations];
		
	}
	
	// Make sure the picker selects the ball that was previously selected
	[self.ballPickerView selectRow:self.currentBallIndex inComponent:0 animated:NO];
	// Make sure the ball that is selected in the picker is the one displayed
	[glBallPreView setBallTypeIndex:self.currentBallIndex];
	
	// Start up animation on the glBallPreView
	[glBallPreView startAnimation];
}

- (IBAction) chooseFloorImage:(id)sender {
	// Load Floor... button
	[self chooseCustomFloorImage];
}

- (IBAction) chooseWallImage:(id)sender {
	// Load Wall... button
	[self chooseCustomWallImage];
}

- (IBAction) setCameraFollowsBall:(id)sender {
	// User toggled the value of the "Camera Follows Ball" switch
	// Grab the value of the switch
	UISwitch* theSwitch = (UISwitch *)sender;
	BOOL cameraFollowsBall = [theSwitch isOn];
	
	// Store this setting
	[UserDefaults setCameraFollowsBall:cameraFollowsBall];
}

- (IBAction) shouldResetBounceCount:(id)sender {
	// User double-tapped the bounce count
	// Ask them if they want to reset the bounce count
	NSString* title = NSLocalizedString(@"Reset Bounce Count", @"Reset Bounce Count title");
	NSString* message = NSLocalizedString(@"Do you want to reset the bounce count to zero?", @"Reset Bounce Count message");
	NSString* yes = NSLocalizedString(@"Yes", @"Yes button");
	NSString* no = NSLocalizedString(@"No", @"No button");
	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:yes,no,nil];
	[alertView show];
}


#pragma mark ----- ShakingView Methods ------

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        // If on device with 2.0 scale, ask user if they want to enable/disable hi-res graphics
		UIScreen *mainScreen = [UIScreen mainScreen];
		if ([mainScreen respondsToSelector:@selector(scale)] && [mainScreen scale] == 2.0) {
			NSString* title = nil;
			NSString* message = nil;
			if ([UserDefaults enableHiResGraphics]) {
				title = NSLocalizedString(@"Disable Hi-Res Graphics", @"Disable Hi-Res Graphics title");
				message = NSLocalizedString(@"Do you want to disable the\nhi-resolution graphics?", @"Disable Hi-Res Graphics message");
			}
			else {
				title = NSLocalizedString(@"Enable Hi-Res Graphics", @"Enable Hi-Res Graphics title");
				message = NSLocalizedString(@"Do you want to enable\nhi-resolution graphics?\n\n(WARNING: experimental feature)", @"Enable Hi-Res Graphics message");
			}
			NSString* yes = NSLocalizedString(@"Yes", @"Yes button");
			NSString* no = NSLocalizedString(@"No", @"No button");
			
			UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:yes,no,nil];
			[alertView show];
		}
    }
}


#pragma mark ----- SubView Helper Methods -----

- (void) removeGLPreView {
	// Fade out the GLPreView and unload it from memory
	
	// Fade out the GLPreView
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// Remove the GLPreView
	if (self.glBallPreView.superview) {
		// Stop animation
		[glBallPreView stopAnimation];
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.glBallPreView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
		glBallPreView.alpha = 0.0;
	}
	
	if (self.glBallPreView) {
		// This unloads the GLPreView from memory since "self" is the only thing holding onto it
		self.glBallPreView = nil;
	}
	
	[UIView commitAnimations];
	
}

- (void) destroyAllPickerViews {
	// Destroy these objects to free up memory
	if (self.pickerNavigationBar)
		self.pickerNavigationBar = nil;
	if (self.ballPickerView)
		self.ballPickerView = nil;
	if (self.ballPickerController)
		self.ballPickerController = nil;
}

- (void) removeAllPickerViews {
	// Remove the BallPicker from the view and remove them from memory
	
	// Move these subviews off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// For each SubView, schedule the view to be removed from the superview a little after the animation has finished
	
	// Remove the navigation bar
	if (self.pickerNavigationBar.superview) {
		self.pickerNavigationBar.frame = CGRectMake(0.0, kSettingsViewHeight, 320.0, kNavigationBarHeight); // Slide off-screen
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.pickerNavigationBar selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	}
	
	// Remove the BallPicker View
	if (self.ballPickerView.superview) {
		self.ballPickerView.frame = CGRectMake(0.0, kSettingsViewHeight+kNavigationBarHeight, 320.0, kBallPickerViewHeight); // Slide off-screen
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.ballPickerView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
	}
	
	[UIView commitAnimations];
	
	// Destroy these objects to free up memory
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(destroyAllPickerViews) userInfo:nil repeats:NO];

}

- (void) removeNoTouchBackground {
	
	// Fade out and remove the no-touch background
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	if (self.noTouchBackground.superview) {
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.noTouchBackground selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
		noTouchBackground.alpha = 0.0;
	}
	
	[UIView commitAnimations];
	
	if (self.noTouchBackground) {
		// Remove from memory
		self.noTouchBackground = nil;
	}
}


#pragma mark ----- BallPickerControllerDelegate Methods -----
// The BallPickerController object calls these methods to inform the SettingsViewController of the changes

- (void) finishBallSelection {
	// User clicked the "done" button in the ball picker
	// - Save the user's selection
	// - If the user picked a built-in ball, remove the GLPreView and go back to the standard settings
	// - If the user picked the custom ball, bring up the CustomBallView
	
	// Save the ball type selection
	[UserDefaults setBallIndex:self.currentBallIndex];
	
	// Remove the picker view
	[self removeAllPickerViews];
	// Call customize ball if that's the ball that was selected
	if (self.currentBallIndex == [ballTypes customBallIndex])
		[self customizeBall];
	else {
		// Done with GLPreView. Remove it.
		[self removeGLPreView];
		// Done with NoTouchBackground. Remove it.
		[self removeNoTouchBackground];
	}
}

- (void) setBallTypeIndex:(unsigned) index {
	// 
	// Update Ball type GLPreView
	[glBallPreView setBallTypeIndex:index];
	
	// Save the ball type selection
	self.currentBallIndex = index;
}

- (void) customizeBall {
	
	// Load CustomBallView
    if (customBallViewController == nil) {
        [self loadCustomBallViewController];
    }
    
    UIView *customBallView = customBallViewController.view;
	[self.view addSubview:customBallView];
	
	// Set this view off the screen
	customBallView.frame = CGRectMake(0.0, kCustomBallSubViewHeight+kNavigationBarHeight, 320.0, kCustomBallViewHeight);
    
    [UIView beginAnimations:nil context:NULL];
	
	// Slide into view
    [UIView setAnimationDuration:0.3];
	customBallView.frame = CGRectMake(0.0, 0.0, 320.0, kCustomBallViewHeight);
	
	[UIView commitAnimations];
}



#pragma mark ----- CustomBallViewControllerDelegate Methods -----
// The BallPickerController object calls these methods to inform the SettingsViewController of the changes

- (void) destroyCustomBallViewController {
	// This will release the view controller
	self.customBallViewController = nil;
}

- (void) removeCustomBallView {
	// User is done with the CustomBallView. Slide it off-screen and remove it from memory
	
	// Remove CustomBallView from superview
    UIView *customBallView = self.customBallViewController.view;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
	// Slide out of view
	if (customBallView.superview) {
		customBallView.frame = CGRectMake(0.0, kCustomBallSubViewHeight+kNavigationBarHeight, 320.0, kCustomBallViewHeight);
		// Remove the views after they have left the screen
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:customBallView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(destroyCustomBallViewController) userInfo:nil repeats:NO];
	}
	
	[UIView commitAnimations];
	
	// Remove GLPreView
	[self removeGLPreView];
	
	// Done with NoTouchBackground. Remove it.
	[self removeNoTouchBackground];
}

- (void) setCustomBallImage:(UIImage*)ballImage {
	// The user provided a custom ball image from their photos
	
	// Save Custom Ball Image to a file
	[UserDefaults setCustomBallImage:ballImage];
	
	// Update ball image in BallTypes
	[ballTypes useCustomBallImage];
	
	// Update Ball image in GLPreView
	[glBallPreView setBallTypeIndex:[ballTypes customBallIndex]];
	
	// Save user preference
	[UserDefaults setShouldUseCustomBallIndex:NO];
}

- (void) setCustomBallSize:(float) radius {
	// User moved the custom ball size slider
	
	// Update Ball GLPreView
	[glBallPreView setBallSize:radius];
}

- (void) setCustomBallBounce:(float) bounce {
	// User moved the custom ball bounce slider
	
	// Update Ball type preview GLView?
	// For now, we don't demonstrate the bounce, but we could make the ball in the 
	// GLPreView do a bounce or two
	
}

- (void) setCustomBallImageAndSoundsToBallIndex:(unsigned) index {
	// The user selected a built-in image to wrap around the custom ball
	
	// Update ball image in BallTypes
	[ballTypes setCustomBallImageFile:[ballTypes imageFileForBallAtIndex:index]];
	// Also update bounce sound
	[ballTypes setCustomBallSounds:index];
	
	// Reload Ball in GLPreView
	[glBallPreView setBallTypeIndex:[ballTypes customBallIndex]];
	
}



#pragma mark ----- UIActionSheet Methods (for choosing image source) -----

// Actionsheet delegate return and act on 
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Handle the user's selection: which source did they choose for the custom images?
	// The choices are slightly different based on the device type: iPhone or iPod Touch
    UIImagePickerControllerSourceType sourceType;
	
	// Set the source type according to the user's selection
	switch(buttonIndex) {
		case 0:
			sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
		case 1:
			sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
			break;
		case 2:
			if([actionSheet numberOfButtons] == 3) {
				// This is the Cancel button
				// Start up the GLPreView again
				[glBallPreView startAnimation];
				return;
			}
			else
				sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		default:
			// This is the Cancel button
			// Start up the GLPreView again
			[glBallPreView startAnimation];
			return;
    }
	
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
		// Though it is unlikely to be an issue, Apple says that we should check to see if the Camera/Photo Library is available
		NSString *cameraNotAvailableMessage = NSLocalizedString(@"Camera not available!", @"Camera not available alert");
		NSString *photoLibraryNotAvailableMessage = NSLocalizedString(@"Photo Library not available!", @"Photo Library not available alert");
		// Pop up an alert view
		if (sourceType == UIImagePickerControllerSourceTypeCamera)
			[self showAlert:cameraNotAvailableMessage withMessage:@""];
		else if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
			[self showAlert:photoLibraryNotAvailableMessage withMessage:@""];
		else
			[self showAlert:photoLibraryNotAvailableMessage withMessage:@""];
	}
	
	// Using the image source above, bring up the built-in image chooser, allowing the user to crop the image.
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [picker setSourceType:sourceType];
    picker.allowsEditing = YES;
	
    // Picker is displayed asynchronously.
    [self presentModalViewController:picker animated:YES];
}


#pragma mark ----- Custom Image Selection Methods -----


- (void) chooseImage {
	// Bring up an ActionSheet for the user to choose the source of the custom image
	// The choices are slightly different based on the device type: iPhone or iPod Touch
    UIActionSheet *actionSheet;
	NSString *chooseSource = NSLocalizedString(@"Choose Source", @"Choose Image Source title");
	NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button");
	NSString *photoLibraryButton = NSLocalizedString(@"Photo Library", @"Photo Library button");
	NSString *cameraRollButton = NSLocalizedString(@"Camera Roll", @"Camera Roll button");
	NSString *savedPhotosButton = NSLocalizedString(@"Saved Photos", @"Saved Photos button");
	NSString *cameraButton = NSLocalizedString(@"Camera", @"Camera button");
	
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:chooseSource delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:photoLibraryButton,cameraRollButton,cameraButton,nil];
    }	else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:chooseSource delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:photoLibraryButton,savedPhotosButton,nil];
    }
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:[self view]];
}

- (void) chooseCustomBallImage {
	// Mark that next image received is for the ball
	// This variable will be used by the useImage method to determine what to do with the image it receives
	nextImageType = kImageTypeBall;
	// Start up image picker
	[self chooseImage];
	[glBallPreView stopAnimation];
}

- (void) chooseCustomFloorImage {
	// Mark that next image received is for the floor
	// This variable will be used by the useImage method to determine what to do with the image it receives
	nextImageType = kImageTypeFloor;
	// Start up image picker
	[self chooseImage];
}

- (void) chooseCustomWallImage {
	// Mark that next image received is for the wall
	// This variable will be used by the useImage method to determine what to do with the image it receives
	nextImageType = kImageTypeWall;
	// Start up image picker
	[self chooseImage];
}

- (void) setCustomWallImagesToShort:(UIImage*)shortWallImage andLong:(UIImage*)longWallImage {
	
	// Save the images to a file. GLView will load them when we switch back.
	[UserDefaults setCustomShortWallImage:shortWallImage];
	[UserDefaults setCustomLongWallImage:longWallImage];
}

-(void) setCustomFloorImage:(UIImage*)floorImage {
	
	// Save the images to a file. GLView will load it when we switch back.
	[UserDefaults setCustomFloorImage:floorImage];
}

- (IBAction) resetWallImage {
	// Reset wall button
	// GLView will pick up these changes when we switch back.
	[UserDefaults removeCustomShortWallImage];
	[UserDefaults removeCustomLongWallImage];
}

- (IBAction) resetFloorImage {
	// Reset floor button
	// GLView will pick up this change when we switch back.
	[UserDefaults removeCustomFloorImage];
}



#pragma mark ----- UIImagePickerControllerDelegate Methods ------

- (void)useImage:(UIImage*)theImage
{
	// This method is called when Apple's built-in image picker comes back with an
	// image chosen and cropped by the user.
	// The method will modify all of the different types of images as needed and call the 
	// appropriate method to store and set the image.
	
	UIImage *tempImage, *newImage;
	CGRect cropRect;
	float width, height, start;
	
	// Get image parameters
	unsigned imageWidth = theImage.size.width;
	unsigned imageHeight = theImage.size.height;
	float imageAspectRatio =  (float)imageWidth/(float)imageHeight;
	
	// Retina Display support
	// Scale the wall and floor by 2.0 for 2.0-scaled devices
	// Note: scaleFactor *must* be a power of 2 for the textures to work
	int scaleFactor = 1;
	if ([UserDefaults enableHiResGraphics]) {
		UIScreen *mainScreen = [UIScreen mainScreen];
		if ([mainScreen respondsToSelector:@selector(scale)] && [mainScreen scale] == 2.0)
			scaleFactor = 2;
	}
	
	// Check which image type we were expecting
	// The nextImageType variable was set based on which button the user pressed
	switch (nextImageType) {
		case kImageTypeBall:
			// For the ball image, make a square from the user image and double
			// it to wrap around both sides of the ball.
			
			// If tall, crop a square section in the middle (as wide as original)
			if (imageAspectRatio < 1.0) {
				width = imageWidth;
				height = imageWidth;
				start = (float)imageHeight/2-(float)height/2;
				cropRect = CGRectMake( 0.0, start, width, height);
			}
			// Else if wide, crop a square section in the middle (as tall as original)
			else {
				width = imageHeight;
				height = imageHeight;
				start = (float)imageWidth/2-(float)width/2;
				cropRect = CGRectMake( start, 0.0, width, height);
			}
			tempImage = [ImageManipulation imageByCropping:theImage toRect:cropRect];
			// Resize square image to 256x256
			newImage = [ImageManipulation resizeImage:tempImage toRect:CGRectMake(0.0, 0.0, 256.0*scaleFactor, 256.0*scaleFactor)];
			// Double image to 512x256 and set custom image
			[self setCustomBallImage:[ImageManipulation doubleImage:newImage]];
			
			break;
			
		case kImageTypeWall:
			// The wall image will be used on both the long and short walls, with the long wall
			// image being cropped to fit the short wall. The image should not be skewed.
			
			// Two cases: short wall and long wall
			/////////////
			// Long Wall: Make a long image
			// If tall, crop a wide (3:2) section in the middle (as wide as original)
			if ( imageAspectRatio < kWideImageAspectRatio ) {
				width = imageWidth;
				height = imageWidth * kTallImageAspectRatio; // Instead of dividing by the inverse
				start = (float)imageHeight/2-(float)height/2;
				cropRect = CGRectMake( 0.0, start, width, height);
				tempImage = [ImageManipulation imageByCropping:theImage toRect:cropRect];
			}
			// Else if wide, crop out a 3:2 section (as tall as the original)
			else {
				width = imageHeight * kWideImageAspectRatio;
				height = imageHeight;
				start = (float)imageWidth/2-(float)width/2;
				cropRect = CGRectMake( start, 0.0, width, height);
				tempImage = [ImageManipulation imageByCropping:theImage toRect:cropRect];
			}
			// Resize 3:2 image to 512x256 and set custom image
			// This will skew the image, but the GLView will skew it back
			newImage = [ImageManipulation resizeImage:tempImage toRect:CGRectMake(0.0, 0.0, 512.0*scaleFactor, 256.0*scaleFactor)];
			//[delegate setCustomWallImage:newImage];
			
			/////////////
			// Short Wall: Make a square image from the center of the long image
			tempImage = [ImageManipulation imageByCropping:newImage toRect:CGRectMake(128.0*scaleFactor, 0.0, 256.0*scaleFactor, 256.0*scaleFactor)];
			
			// Set both wall types at once
			[self setCustomWallImagesToShort:tempImage andLong:newImage];
			break;
		case kImageTypeFloor:
			// The floor image is just like the long wall, but the oposite orientation
			
			// If tall, crop out a 2:3 section (as wide as the original)
			if ( imageAspectRatio < kTallImageAspectRatio ) {
				width = imageWidth;
				height = imageWidth * kWideImageAspectRatio; // Instead of dividing by the inverse
				start = (float)imageHeight/2-(float)height/2;
				cropRect = CGRectMake( 0.0, start, width, height);
				tempImage = [ImageManipulation imageByCropping:theImage toRect:cropRect];
			}
			// Else if wide, crop a tall (2:3) section in the middle (as tall as original)
			else {
				width = imageHeight * kTallImageAspectRatio;
				height = imageHeight;
				start = (float)imageWidth/2-(float)width/2;
				cropRect = CGRectMake( start, 0.0, width, height);
				tempImage = [ImageManipulation imageByCropping:theImage toRect:cropRect];
			}
			// Resize 2:3 image to 256x512 and set custom image
			// This will skew the image, but the GLView will skew it back
			newImage = [ImageManipulation resizeImage:tempImage toRect:CGRectMake(0.0, 0.0, 256.0*scaleFactor, 512.0*scaleFactor)];
			[self setCustomFloorImage:newImage];
			break;
		default:
			NSLog(@"Unknown image type: %d", nextImageType);
			break;
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	// This is the callback from Apple's image picker
    [self useImage:image];
	
    // Remove the picker interface and release the picker object.
    [self dismissModalViewControllerAnimated:YES];
	
	// Start up the GLPreView again
	[glBallPreView startAnimation];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	// The user clicked the cancel button when choosing an image
	// Since there is no image to work with, just get rid of the image picker
	// and start up the GLPreView animation
    [self dismissModalViewControllerAnimated:YES];
	
	// Start up the GLPreView again
	[glBallPreView startAnimation];
}



#pragma mark ----- UINavigationControllerDelegate Methods -----

// Since the UIImagePickerController inherits from UINavigationController, it wants it's delegate to conform to this protocol as well.

// Sent to the receiver just after the navigation controller displays a view controller’s view and navigation item properties.
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
}

// Sent to the receiver just before the navigation controller displays a view controller’s view and navigation item properties.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
}


#pragma mark ----- CreditsView -----

- (IBAction) showCreditsView {
	// This method toggles the visibility of the credits view
	
	if (self.creditsView.hidden == YES) {
		// Bring up the credits view
		self.creditsView.alpha = 0.0;
		[UIView beginAnimations: @"showCreditsView" context: nil];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationStopped:finished:context:)];
		[UIView setAnimationDuration: 0.5];
		self.creditsView.hidden=NO;
		self.creditsView.alpha = 1.0;
		[UIView commitAnimations];
	}
	else {
		// Hide the credits view
		[UIView beginAnimations: @"hideCreditsView" context: nil];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationStopped:finished:context:)];
		[UIView setAnimationDuration: 0.5];
		self.creditsView.alpha = 0.0;
		[UIView commitAnimations];
	}
	
}

- (void) animationStopped: (NSString *)animationID finished: (BOOL) finished context: (void *) context {
	// Once the view has faded, hide the view from the user to make sure it doesn't grab the user touches.
	if ([animationID isEqualToString: @"showCreditsView"])
		[self.creditsTextView flashScrollIndicators];
	else if ([animationID isEqualToString: @"hideCreditsView"])
		self.creditsView.hidden = YES;
}

@end
