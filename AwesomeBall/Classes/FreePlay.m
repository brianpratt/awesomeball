//
//  FreePlay.m
//  AwesomeBall
//
//  Created by Jonathan Johnson on 4/8/09.
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
//  FreePlay extends BasicGame by adding easter eggs

#import "FreePlay.h"
#import "GLView.h"
#import "GLBall.h"
#import "SoundEffect.h"
#import "GLWalls.h"
#import "EasterEggs.h"
#import "UserDefaults.h"
#import "RootViewController.h"
#import "AwesomeBallAppDelegate.h"
#import "ImageManipulation.h"


static FreePlay * singleton;


// A class extension to declare private methods and variables
@interface FreePlay ()

- (BOOL) startEasterEggHunt:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL) easterEggTrigger:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) resetEasterEggHunt;
- (void) checkForEasterEgg:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) loadImagePickerController;
- (void) backgroundImageEasterEgg;
- (void) finishBackgroundImageEasterEgg: (UIImage *) image;
- (void) revertBackgroundImageEasterEggChanges;

@end


@implementation FreePlay

// Overrides the parent method
- (id) initWithGLView: (GLView *) view {
	self = [super initWithGLView: view];
	
	easterEggHuntBeganButNotEnded = NO;
	easterEggFound = NO;
	
	// Set up easter egg sound effect
    NSBundle *mainBundle = [NSBundle mainBundle];
	easterEggSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"harp_run" ofType:@"caf"]];
	
	singleton = self;
	return self;
}



- (void) viewWillAppear:(BOOL)animated {
	// Coming back to GLView from SettingsView
	[super viewWillAppear:animated];

	// Might need to clear the changes from the background image Easter egg (home screen)
	if ([UserDefaults customWallImagesChanged] || [UserDefaults customFloorImageChanged]) {
		[self revertBackgroundImageEasterEggChanges];
	}

}


#pragma mark ----- Easter Eggs -----

- (BOOL) alternateTrigger {
	if (m_accZ_lp > 0)
		return YES;
	else
		return NO;
}

- (void) easterEggOne {
	[easterEggSound play];
	
	if ([self alternateTrigger]) {
		[self setupSoundEffectsUsingDirectSoundFilePrefix:@"laser" andDeflectSoundFilePrefix:@"laser"];
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggLaserSound];
	}
	else {
		[self revertBackgroundImageEasterEggChanges]; // Remove background image
		[m_walls setImagesForsShortWallsNamed:@"starfield_sparse_shortWall" andLongWallsNamed:@"starfield_sparse_longWall" andFloorNamed:@"starfield_floor"];
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggSpaceWalls];
		// Notify BallTypes object of the unlock, if necessary
		if ([UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggEarthBall])
			[ballTypes addEasterEggBall];
		int max = [ballTypes numberofBalls];
		for (int i = 0; i < max; i++) {
			if ([[ballTypes idOfBallAtIndex: i] compare: kBallTypeEarth] == NSOrderedSame) {
				[self setBallTypeIndex: i];
				[UserDefaults setBallIndex: i];
				break;
			}
		}
	}
}

- (void) easterEggTwo {
	[easterEggSound play];
	
	if ([self alternateTrigger]) {
		[self setupSoundEffectsUsingDirectSoundFilePrefix:@"boing" andDeflectSoundFilePrefix:@"boing"];
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggBoingSound];
	}
	else {
		// Notify BallTypes object of the unlock, if necessary
		if ([UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggSmileyBall])
			[ballTypes addEasterEggBall];
		int max = [ballTypes numberofBalls];
		for (int i = 0; i < max; i++) {
			if ([[ballTypes idOfBallAtIndex: i] compare: kBallTypeSmileyFace] == NSOrderedSame) {
				[self setBallTypeIndex: i];
				[UserDefaults setBallIndex: i];
				break;
			}
		}
	}
}

- (void) easterEggThree {
	[easterEggSound play];
	
	if ([self alternateTrigger]) {
		[self setupSoundEffectsUsingDirectSoundFilePrefix:@"glass" andDeflectSoundFilePrefix:@"glass"];
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggGlassSound];
	}
	else {
		// Notify BallTypes object of the unlock, if necessary
		if ([UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggInvisibleBall])
			[ballTypes addEasterEggBall];
		int max = [ballTypes numberofBalls];
		for (int i = 0; i < max; i++) {
			if ([[ballTypes idOfBallAtIndex: i] compare: kBallTypeInvisibleBall] == NSOrderedSame) {
				[self setBallTypeIndex: i];
				[UserDefaults setBallIndex: i];
				break;
			}
		}
	}
}


- (void) easterEggFour {
	[easterEggSound play];
	
	if ([self alternateTrigger]) {
		[self setupSoundEffectsUsingDirectSoundFilePrefix:@"tank" andDeflectSoundFilePrefix:@"tank"];
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggTankSound];
	}
	else {
		[self revertBackgroundImageEasterEggChanges]; // Remove background image
		[m_walls setImagesForsShortWallsNamed:@"grid_shortWall" andLongWallsNamed:@"grid_longWall" andFloorNamed:@"grid_floor"];
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggGridWalls];
	}
}

- (void) easterEggFive {
	[easterEggSound play];
	
	if ([self alternateTrigger]) {
		[m_walls makeWallsInvisible];
		
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggInvisibleWalls];
	}
	else {
		[self backgroundImageEasterEgg];
		
		[UserDefaults setEasterEggUnlocked:YES forEgg:kEasterEggHomeScreen];
	}
}



#pragma mark ----- Easter Egg Helper Methods -----

- (void) loadImagePickerController {
    
	// Loads the ImagePickerController into memory
    
	ImagePickerController *viewController = [[ImagePickerController alloc] init];
	imagePickerController = viewController;
	
	// Set this as the delegate
	[imagePickerController setDelegate:self];
    [imagePickerController setActiveViewController:[GLViewController getSingleton]];
}

- (void) backgroundImageEasterEgg {
	
	//////////
	// Custom background image
	// Let the user choose a background image
	[glView stopAnimation];
	
	// Create an image picker, if necessary, and add its view
	if (!imagePickerController)
		[self loadImagePickerController];
	[glView addSubview: imagePickerController.view];
	
	// Let it do it's thing. It will return with a callback:
	//   - (void) imagePickerController:(ImagePickerController *)picker didFinishPickingImage:(UIImage *)image)
	[imagePickerController chooseImage];
	
}

- (void) finishBackgroundImageEasterEgg: (UIImage *) image  {
	// 1. Make the walls invisible
	[m_walls makeWallsInvisible];
	
	// 2. Load image below GLView
	// The RootViewController's UIImageView is set to 'UIViewContentModeScaleAspectFill'
	// This will scale down the image and crop it if it landscape. We could alternately detect portrait vs. landscape
	//  and load it in the correct (?) orientation (but the image would still be cropped)
	[[RootViewController getSingleton].imageView setImage: image];
	
	// 3. Remove the status bar
	[[AwesomeBallAppDelegate theApplication] setStatusBarHidden: YES];
	[UserDefaults setHideStatusBar: YES];
	
	// 4. Set view mode to "cameraFollowsBall = NO"
	[self setCameraFollowsBall: NO];
	[UserDefaults setCameraFollowsBall: NO];
	m_cameraZ_zoom = -25;
	
}

- (void) revertBackgroundImageEasterEggChanges {

	// Might need to clear the changes from the background image Easter egg (home screen)
	// Remove background image
	[[RootViewController getSingleton].imageView setImage: nil];
	[UserDefaults setHideStatusBar: NO];

	// Walls will be make visible when new walls are selected
	// Camera zoom factor will be reverted when user toggles the switch
}



#pragma mark ----- Easter Egg Methods -----

- (BOOL) startEasterEggHunt:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet *allTouches = [event allTouches];
	
	BOOL startEasterEggHunt = NO;
	
    switch ([allTouches count]) {
        case 1: {
			//NSLog(@"One finger began");
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint pos = [touch locationInView: glView];
			beganPositions[0] = pos;
			beganPositions[1].x = -1; beganPositions[1].y = -1;
			
			startEasterEggHunt = YES;
        } break;
        case 2: {
			//NSLog(@"Two fingers began");
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
			beganPositions[0] = [touch1 locationInView: glView];
			beganPositions[1] = [touch2 locationInView: glView];
			
			startEasterEggHunt = YES;
			
			//NSLog(@"Begin Easter Egg Hunt");
        } break;
        case 3: {
			//NSLog(@"Three fingers began");
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            UITouch *touch3 = [[allTouches allObjects] objectAtIndex:2];
			beganPositions[0] = [touch1 locationInView: glView];
			beganPositions[1] = [touch2 locationInView: glView];
			beganPositions[2] = [touch3 locationInView: glView];
			
			startEasterEggHunt = YES;
			
			//NSLog(@"Begin Easter Egg Hunt");
        } break;
    }
	
	return startEasterEggHunt;
}

- (BOOL) easterEggTrigger:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
	CGSize viewSize = glView.frame.size;
	
	BOOL easterEggTriggered = NO;
	
	// Get touch positions
	UITouch *touch1, *touch2, *touch3;
	CGFloat travelDistX1, travelDistX2, travelDistX3;
	CGFloat travelDistY1, travelDistY2, travelDistY3;
	
	touch1 = [[allTouches allObjects] objectAtIndex:0];
	endedPositions[0] = [touch1 locationInView: glView];
	// Record travel distance
	travelDistX1 = fabs(beganPositions[0].x - endedPositions[0].x);
	travelDistY1 = fabs(beganPositions[0].y - endedPositions[0].y);
	//NSLog(@"travelDistX1: %f, travelDistY1: %f", travelDistX1, travelDistY1);
	
	if ([allTouches count] >= 2) {
		touch2 = [[allTouches allObjects] objectAtIndex:1];
		endedPositions[1] = [touch2 locationInView: glView];
		// Record travel distance
		travelDistX2 = fabs(beganPositions[1].x - endedPositions[1].x);
		travelDistY2 = fabs(beganPositions[1].y - endedPositions[1].y);
		//NSLog(@"travelDistX2: %f, travelDistY2: %f", travelDistX2, travelDistY2);
		
		if ([allTouches count] >= 3) {
			touch3 = [[allTouches allObjects] objectAtIndex:2];
			endedPositions[2] = [touch3 locationInView: glView];
			// Record travel distance
			travelDistX3 = fabs(beganPositions[2].x - endedPositions[2].x);
			travelDistY3 = fabs(beganPositions[2].y - endedPositions[2].y);
			//NSLog(@"travelDistX3: %f, travelDistY3: %f", travelDistX3, travelDistY3);
		}
		else {
			endedPositions[2].x = -1; endedPositions[2].y = -1;
		}
	}
	else {
		endedPositions[1].x = -1; endedPositions[1].y = -1;
	}
	BOOL twoValidTouches = NO;
	if (beganPositions[1].x != -1 && endedPositions[1].x != -1) {
		twoValidTouches = YES;
	}
	BOOL threeValidTouches = NO;
	if (beganPositions[2].x != -1 && endedPositions[2].x != -1) {
		threeValidTouches = YES;
	}
	
	
	// Check for Easter Eggs!
	// Sort by the number of touches involved (descending)
	
	// Easter Egg 5: Three fingers dragged at least 3/4-way down the screen
	if ( (threeValidTouches == YES) && (travelDistX1 > viewSize.width*.75) && 
		(travelDistX3 > viewSize.width*.75)  && (travelDistX3 > viewSize.width*.75) ) {
		//[self showAlert:@"Congratulations!" withMessage:@"You found easter egg #5!"];
		[self easterEggFive];
		easterEggTriggered = YES;
		
		return easterEggTriggered;
	}
	
	// Easter Egg 1: Two fingers dragged at least 3/4-way down the screen
	if ( (twoValidTouches == YES) && (travelDistY1 > viewSize.height*.75) && (travelDistY2 > viewSize.height*.75) ) {
		//[self showAlert:@"Congratulations!" withMessage:@"You found easter egg #1!"];
		[self easterEggOne];
		easterEggTriggered = YES;
		
		return easterEggTriggered;
	}
	
	// Easter Egg 2: Two fingers dragged at least 3/4-way across the screen
	if ( (twoValidTouches == YES) && (travelDistX1 > viewSize.width*.75) && (travelDistX2 > viewSize.width*.75) ) {
		//[self showAlert:@"Congratulations!" withMessage:@"You found easter egg #2!"];
		[self easterEggTwo];
		easterEggTriggered = YES;
		
		return easterEggTriggered;
	}
	
	
	// Easter Egg 3: Two fingers rotated 180 degrees (or did they switch positions?)
	// Make sure we have two touches to work with
	if (twoValidTouches) {
		// Did fingers switch positions?
		static CGFloat distThreshold = 50.0;
		static CGFloat travelThreshold = 200.0;
		CGFloat dist1 = [self distanceBetweenTwoPoints:beganPositions[0] toPoint:endedPositions[1]];
		CGFloat dist2 = [self distanceBetweenTwoPoints:beganPositions[1] toPoint:endedPositions[0]];
		CGFloat travelDist = [self distanceBetweenTwoPoints:beganPositions[0] toPoint:endedPositions[0]];
		//NSLog(@"beganPositions[0]: (%f, %f)", beganPositions[0].x, beganPositions[0].y);
		//NSLog(@"beganPositions[1]: (%f, %f)", beganPositions[1].x, beganPositions[1].y);
		//NSLog(@"endedPositions[0]: (%f, %f)", endedPositions[0].x, endedPositions[0].y);
		//NSLog(@"endedPositions[1]: (%f, %f)", endedPositions[1].x, endedPositions[1].y);
		//NSLog(@"dist1: %f, dist2: %f", dist1, dist2);
		//NSLog(@"travelDist: %f", travelDist);
		if (dist1 <= distThreshold && dist2 <= distThreshold) {
			if (travelDist >= travelThreshold) {
				//[self showAlert:@"Congratulations!" withMessage:@"You found easter egg #3!"];
				[self easterEggThree];
				easterEggTriggered = YES;
				
				return easterEggTriggered;
			}
		}
	}
	
	// Easter Egg 4: One finger dragged diagonally across the screen
	if ( (travelDistX1 > viewSize.width*.80) && (travelDistY1 > viewSize.height*.80) ) {
		//[self showAlert:@"Congratulations!" withMessage:@"You found easter egg #4!"];
		[self easterEggFour];
		easterEggTriggered = YES;
		
		return easterEggTriggered;
	}
	
	
	return easterEggTriggered;
}

- (void) resetEasterEggHunt {
	easterEggFound = NO;
	easterEggHuntBeganButNotEnded = NO;
	
	// Clear tracking points
	beganPositions[0].x = -1; beganPositions[0].y = -1;
	beganPositions[1].x = -1; beganPositions[1].y = -1;
	beganPositions[2].x = -1; beganPositions[2].y = -1;
}

- (void) checkForEasterEgg:(NSSet *)touches withEvent:(UIEvent *)event {
	if (easterEggFound)
		return; // Already found one. Don't look until a new hunt begins.
	
	// Has a valid hunt begun? (according to startEasterEggHunt)
    if (easterEggHuntBeganButNotEnded) {
		// We are in the middle of a hunt. Is it over?
		easterEggFound = [self easterEggTrigger: touches withEvent: event];
		
		// If Easter egg was triggered, start up hunt again in a few seconds
		if (easterEggFound) {
			[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(resetEasterEggHunt) userInfo:nil repeats:NO];
			easterEggHuntBeganButNotEnded = NO;
		}
	}
	else {
		// No hunt in progress. Start one up.
		easterEggHuntBeganButNotEnded = [self startEasterEggHunt:touches withEvent:event];
	}
	
}


#pragma mark ----- Touch Handling Methods -----

// Pass touches to parent and reset Easter egg hunt
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesBegan: touches withEvent: event];
	
	[self resetEasterEggHunt];
}

// Pass touches to parent and check for Easter egg
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesMoved: touches withEvent: event];
    
	[self checkForEasterEgg:touches withEvent:event];
}

// Pass touches to parent and reset easter egg hunt
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesEnded: touches withEvent: event];
	
	[self resetEasterEggHunt];
}

/*
 // Pass touches to parent
 - (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
 
 [super touchesEnded: touches withEvent: event];
 }
 */



#pragma mark ----- ImagePickerControllerDelegate mmethods -----

- (void) imagePickerController:(ImagePickerController *)pickerController didFinishPickingImage:(UIImage *)image {

	// Finish with the Easter Egg stuff
	[self finishBackgroundImageEasterEgg: image];
	
	// Start up the animation again
	[glView startAnimation];
	
	// Remove the pickerController
	// Don't want to release this object too early, but I can't figure out how to know when it's done
	// Could wait until the ImagePickerController receives the:
	//    - (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animate
	// message with viewController=nil, but that's not really documented, so I don't know if we should rely on that happening.
	// Update: I tried that and it still wasn't quite done receiving messages even after that.
	//[NSTimer scheduledTimerWithTimeInterval:0.5 target:pickerController.view selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
}

- (void) imagePickerDidCancel:(ImagePickerController *)pickerController {
	
	// Start up the animation again
	[glView startAnimation];
	
	// Remove the pickerController
	// See note above in imagePickerController:didFinishPickingImage
	//[NSTimer scheduledTimerWithTimeInterval:0.5 target:pickerController.view selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
}

- (void) imagePickerDidFinish:(ImagePickerController *)pickerController {
	// Release the picker controller
	if (pickerController == imagePickerController) {
		[imagePickerController.view removeFromSuperview];
		imagePickerController = nil;
	}
}


@end
