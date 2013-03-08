//
//  ImagePickerController.m
//  AwesomeBall
//
//  Created by Brian Pratt on 6/24/09.
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
//  A helper class to load up the Apple-provided UIImagePicker, allowing the user 
//  to select the image source location (camera, photo library, etc.)
//

#import "ImagePickerController.h"


@implementation ImagePickerController

@synthesize allowEditing;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// Default to not allow image editing
	self.allowEditing = NO;
	
	// By default, take over the whole screen.
	// This can be overridden by the owner of this object setting the view frame directly after 
	//   this initialization is done.
	
	// get the window frame here.
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	
	UIView *view = [[UIView alloc] initWithFrame:appFrame];
	// making flexible because this will end up in a navigation controller.
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.view = view;
	
	
}



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 // Start up the image picking right away
	 //[self chooseImage];
 }

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark ----- AlertView Methods -----

- (void) showAlert:(NSString*)title withMessage:(NSString*)message
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}



#pragma mark ----- Accessor Methods -----

- (void) setDelegate:(id)newDelegate {
	delegate = newDelegate;
}

- (void) setActiveViewController:(UIViewController *)newActiveViewController {
    activeViewController = newActiveViewController;
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
				[delegate imagePickerDidCancel:self];
                
                // Inform the delgate that image picking is over
                [delegate imagePickerDidFinish: self];
                
				return;
			}
			else
				sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		default:
			// This is the Cancel button
			[delegate imagePickerDidCancel: self];
            
            // Inform the delgate that image picking is over
            [delegate imagePickerDidFinish: self];
            
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
	picker.allowsEditing = self.allowEditing;
	
	// Picker is displayed asynchronously.
	[activeViewController presentModalViewController: picker animated: YES];

	// Don't let the picker use the status bar area
	// Not needed?
	//[picker view].frame = CGRectMake(0.0, 20.0, 320.0, 460.0);
	
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
	[actionSheet showInView:self.view];
}



#pragma mark ----- UIImagePickerControllerDelegate Methods ------

// This is the callback from Apple's image picker
- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	[delegate imagePickerController: self didFinishPickingImage: image];
	
	// Remove the picker interface and release the picker object.
	[activeViewController dismissModalViewControllerAnimated: YES];
    
    // Inform the delgate that image picking is over
	[delegate imagePickerDidFinish: self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	
	[delegate imagePickerDidCancel: self];
	
	// The user clicked the cancel button when choosing an image
	// Since there is no image to work with, just get rid of the image picker
	// and start up the GLPreView animation
	[activeViewController dismissModalViewControllerAnimated: YES];
    
    // Inform the delgate that image picking is over
	[delegate imagePickerDidFinish: self];

}



#pragma mark ----- UINavigationControllerDelegate Methods -----

// Since the UIImagePickerController inherits from UINavigationController, it wants it's delegate to conform to this protocol as well.

// Sent to the receiver just after the navigation controller displays a view controller’s view and navigation item properties.
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//NSLog(@"Here");
	// This message seems to come with viewController=nil when the other picker has been dismissed
}

// Sent to the receiver just before the navigation controller displays a view controller’s view and navigation item properties.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//NSLog(@"Here");
}


@end
