//
//  CustomBallViewController.h
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

#import <UIKit/UIKit.h>
#import "BallTypes.h"
#import "BallImagePickerController.h"

@class CustomBallViewController;

@protocol CustomBallViewControllerDelegate
@required
- (void) removeCustomBallView;
- (void) setBallTypeIndex:(unsigned) index;
- (void) setCustomBallSize:(float) radius;
- (void) setCustomBallBounce:(float) bounce;
- (void) chooseCustomBallImage;
- (void) setCustomBallImageAndSoundsToBallIndex:(unsigned) index;
@end


@interface CustomBallViewController : UIViewController <BallImagePickerControllerDelegate> {
	
	id<CustomBallViewControllerDelegate>	delegate;
	
	BallTypes					*ballTypes;
	
	NSInteger					currentBallIndex;
	
	IBOutlet UIView				*bottomView;
	IBOutlet UISlider			*radiusSlider;
	IBOutlet UISlider			*massSlider;
	IBOutlet UISlider			*bounceSlider;
	
	BallImagePickerController	*ballImagePickerController;
    UINavigationBar				*pickerNavigationBar;
	UIPickerView				*ballImagePickerView;
	
}

@property (nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic) IBOutlet UISlider *radiusSlider;
@property (nonatomic) IBOutlet UISlider *massSlider;
@property (nonatomic) IBOutlet UISlider *bounceSlider;
@property (nonatomic) UINavigationBar *pickerNavigationBar;
@property (nonatomic) UIPickerView	*ballImagePickerView;
@property (nonatomic) BallImagePickerController	*ballImagePickerController;
@property (nonatomic, assign) NSInteger currentBallIndex;

// Accessor Methods
- (void) setDelegate:(id)newDelegate;

// IBActions
- (IBAction) done:(id)sender;
- (IBAction) chooseBuiltInBallImage:(id)sender;
- (IBAction) chooseCustomBallImage:(id)sender;
- (IBAction) radiusSliderAction:(id)sender;
- (IBAction) massSliderAction:(id)sender;
- (IBAction) bounceSliderAction:(id)sender;

@end
