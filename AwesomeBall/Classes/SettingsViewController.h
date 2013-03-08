//
//  SettingsViewController.h
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

#import <UIKit/UIKit.h>
#import "BallPickerController.h"
#import "CustomBallViewController.h"
#import "GLPreView.h"
#import "BallTypes.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate
@required
-(void) toggleView;
@end


@interface SettingsViewController : UIViewController <UIImagePickerControllerDelegate, 
UINavigationControllerDelegate, UIActionSheetDelegate, BallPickerControllerDelegate, 
CustomBallViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, 
MFMailComposeViewControllerDelegate> {
	
	id<SettingsViewControllerDelegate>	delegate;
	
	BallTypes					*ballTypes;
	
	IBOutlet UIButton			*selectBallButton;
	IBOutlet UISwitch			*cameraFollowsBallSwitch;
	IBOutlet UILabel			*settingsLabel;
	
	IBOutlet UIScrollView		*scrollView;
	BallPickerController		*ballPickerController;
    UINavigationBar				*pickerNavigationBar;
	UIPickerView				*ballPickerView;
	UIView						*noTouchBackground;
	CustomBallViewController	*customBallViewController;
	GLPreView					*glBallPreView;
	
	NSInteger					currentBallIndex;
	
	IBOutlet UILabel			*bounceCountLabel;
	
	IBOutlet UILabel			*versionLabel;
	
	IBOutlet UIView				*creditsView;
	IBOutlet UITextView			*creditsTextView;
	
	UIButton                    *infoButton;
	
}

@property (nonatomic) IBOutlet UIButton *selectBallButton;
@property (nonatomic) IBOutlet UISwitch *cameraFollowsBallSwitch;
@property (nonatomic) IBOutlet UILabel	*settingsLabel;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) UINavigationBar *pickerNavigationBar;
@property (nonatomic) UIPickerView	*ballPickerView;
@property (nonatomic) BallPickerController	*ballPickerController;
@property (nonatomic) UIView *noTouchBackground;
@property (nonatomic) CustomBallViewController *customBallViewController;
@property (nonatomic) GLPreView	*glBallPreView;
@property (nonatomic) IBOutlet UILabel * bounceCountLabel;
@property (nonatomic) IBOutlet UILabel * versionLabel;
@property (nonatomic) IBOutlet UIView * creditsView;
@property (nonatomic) IBOutlet UITextView * creditsTextView;
@property (nonatomic, assign) NSInteger currentBallIndex;
@property (nonatomic) IBOutlet UIButton * infoButton;

// Accessor Methods
- (void) setDelegate:(id)newDelegate;
+ (SettingsViewController *) getSingleton;

// IBActions
- (IBAction) done:(id)sender;
- (IBAction) passTheBall:(id)sender;
- (IBAction) selectBall:(id)sender;
- (IBAction) chooseFloorImage:(id)sender;
- (IBAction) chooseWallImage:(id)sender;
- (IBAction) setCameraFollowsBall:(id)sender;
- (IBAction) shouldResetBounceCount:(id)sender;

// Image customization
- (void) chooseCustomBallImage;
- (void) chooseCustomFloorImage;
- (void) chooseCustomWallImage;
- (IBAction) resetWallImage;
- (IBAction) resetFloorImage;

// Credits View
- (IBAction) showCreditsView;

@end
