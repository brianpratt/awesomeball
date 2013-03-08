//
//  ImagePickerController.h
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

#import <UIKit/UIKit.h>

@class ImagePickerController;

@protocol ImagePickerControllerDelegate
@required
- (void) imagePickerController:(ImagePickerController *)picker didFinishPickingImage:(UIImage *)image;
- (void) imagePickerDidCancel:(ImagePickerController *)picker;
- (void) imagePickerDidFinish:(ImagePickerController *)picker;
@end

@interface ImagePickerController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
	
	id<ImagePickerControllerDelegate>	delegate;
    UIViewController    *activeViewController;
	
	BOOL	allowEditing;
	
}

@property (nonatomic, assign) BOOL allowEditing;

- (void) chooseImage;

// Accessor Methods
- (void) setDelegate:(id)newDelegate;
- (void) setActiveViewController:(UIViewController *)newActiveViewController;

@end
