//
//  UserDefaults.m
//  AwesomeBall
//
//  Created by Brian Pratt on 3/17/09.
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
//  UserDefaults holds settings that are shared between the Awesome Ball classes
//  and/or that are meant to persist across sessions. The calls to
//  [NSUserDefaults standardUserDefaults] are to the standard user settings 
//  class provided by Apple. The settings are stored in a file in the App's
//  Documents directory and the file persists across updates to the App.

#import "UserDefaults.h"
#import "BallTypes.h"
#import "EasterEggs.h"


// Dictionary Keys
#define kTotalBounceCount @"totalBounceCount"
#define kCameraFollowsBall @"cameraFollowsBall"
#define kHighScoresUsername @"highScoresUserName"
#define kEasterEggUnlocked @"easterEggUnlocked"
#define kBallIndex @"ballIndex"
#define kCustomBallRadius @"customBallRadius"
#define kCustomBallMass @"customBallMass"
#define kCustomBallBounce @"customBallBounce"
#define kShouldUseCustomBallIndex @"shouldUseCustomBallIndex"
#define kCustomBallIndex @"customBallIndex"
#define kEnableHiResGraphics @"enableHiResGraphics"

// Filenames
#define kCustomBallImage @"customBallImage.jpg"
#define kCustomShortWallImage @"customShortWallImage.png"
#define kCustomLongWallImage @"customLongWallImage.png"
#define kCustomFloorImage @"customFloorImage.png"


// A class extension to declare private methods
@interface UserDefaults ()

+ (void) setTotalBounceCount: (NSUInteger) newTotalBounceCount;
+ (BOOL) writeApplicationData:(NSData *) data toFile:(NSString *) fileName;
+ (NSData *) applicationDataFromFile:(NSString *) fileName;
+ (UIImage*) customImage:(NSString*) imageFileName;
+ (void) setCustomImage: (UIImage*) newCustomImage withImageFileName: (NSString*) imageFileName;

@end


@implementation UserDefaults

// Class variables
// Keep track of changes for the current session (these values don't persist)
BOOL cameraFollowsBallChanged = NO, ballTypeChanged = NO, customBallParametersChanged = NO;
BOOL easterEggUnlockedArrayChanged = NO;
BOOL customBallImageChanged = NO, customWallImagesChanged = NO, customFloorImageChanged = NO;
BOOL enableHiResGraphicsChanged = NO;
// Right now, the only time the status bar should be hidden is during the background image easter egg,
// so this setting does not persist.
BOOL hideStatusBar = NO;


+ (BOOL) forceSynchronization {
	// Return the results of attempting to write preferences to system
	return [[NSUserDefaults standardUserDefaults] synchronize];	
}



#pragma mark ----- Generic NSData Storage Methods ------

// Write any type of NSData object (which can be created from many types of objects) to 
// flash memory
+ (BOOL) writeApplicationData:(NSData *) data toFile:(NSString *) fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		NSLog(@"Documents directory not found!");
		return NO;
	}
	
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
	return ([data writeToFile:appFile atomically:YES]);
}

// Read a previously-stored NSData object from flash memory
+ (NSData *) applicationDataFromFile:(NSString *) fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *myData = [[NSData alloc] initWithContentsOfFile:appFile];
    return myData;
}

// Remove a previously-stored file from flash memory
+ (void) deleteApplicationDataFile:(NSString *) fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:appFile error:NULL];
}


#pragma mark ----- Total Bounce Count Methods ------

+ (NSUInteger) totalBounceCount {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kTotalBounceCount])
		return [[NSUserDefaults standardUserDefaults] integerForKey:kTotalBounceCount];
	else {
		[self setTotalBounceCount:0];
		return 0; // Start at zero
	}
}

+ (NSString*) totalBounceCountString {
	NSUInteger bounceCount = [self totalBounceCount];
	
	NSNumberFormatter * aFormatter = [[NSNumberFormatter alloc] init];
	[aFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * aNumber = [[NSNumber alloc] initWithUnsignedInt:bounceCount];
	
	return [aFormatter stringFromNumber:aNumber];
}

+ (void) resetTotalBounceCount {
	[self setTotalBounceCount:0];
}

// Add to the total bounce count without explicit synchronization
+ (void) addToTotalBounceCount: (NSUInteger) bounceCount {
	
	[[NSUserDefaults standardUserDefaults] setInteger:([self totalBounceCount]+bounceCount) forKey:kTotalBounceCount];
}

+ (void) setTotalBounceCount: (NSUInteger) newTotalBounceCount {
	
	[[NSUserDefaults standardUserDefaults] setInteger:newTotalBounceCount forKey:kTotalBounceCount];
}


#pragma mark ----- User Settings ------

+ (BOOL) cameraFollowsBallChanged {
	return cameraFollowsBallChanged;
}
+ (void) setCameraFollowsBallChanged: (BOOL) setCameraFollowsBallChanged {
	cameraFollowsBallChanged = setCameraFollowsBallChanged;
}

+ (BOOL) cameraFollowsBall {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kCameraFollowsBall])
		return [[NSUserDefaults standardUserDefaults] boolForKey:kCameraFollowsBall];
	else {
		[self setCameraFollowsBall:YES];
		return YES;
	}
}
+ (void) setCameraFollowsBall: (BOOL) cameraShouldFollowBall {
	
	[[NSUserDefaults standardUserDefaults] setBool:cameraShouldFollowBall forKey:kCameraFollowsBall];
	
	[self setCameraFollowsBallChanged:YES];
}

+ (NSString*) highScoresUserName {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kHighScoresUsername])
		return [[NSUserDefaults standardUserDefaults] stringForKey:kHighScoresUsername];
	else {
		[self setHighScoresUsername:@""];
		return @"";
	}
}

+ (void) setHighScoresUsername: (NSString*) newHighScoresUsername {
	
	[[NSUserDefaults standardUserDefaults] setObject:newHighScoresUsername forKey:kHighScoresUsername];
}

+ (BOOL) hideStatusBar {
	return hideStatusBar;
}
+ (void) setHideStatusBar: (BOOL) shouldHideStatusBar {
	hideStatusBar = shouldHideStatusBar;
}



#pragma mark ----- Easter Egg Unlocking Methods ------

+ (BOOL) easterEggUnlockedArrayChanged {
	return easterEggUnlockedArrayChanged;
}
+ (void) setEasterEggUnlockedArrayChanged: (BOOL) setEasterEggUnlockedArrayChanged {
	easterEggUnlockedArrayChanged = setEasterEggUnlockedArrayChanged;
}

+ (void) initEasterEggUnlockedArray: (NSMutableArray*) easterEggUnlockedArray {
	for (int i=0; i < kMaxEasterEggs; i++) {
		[easterEggUnlockedArray addObject: [NSNumber numberWithBool: NO]];
	}
}

+ (NSMutableArray*) easterEggUnlockedArray {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kEasterEggUnlocked]) {
		// Make sure the array has the right number of slots (could have changed between versions)
		NSMutableArray* easterEggUnlockedArray = [[[NSUserDefaults standardUserDefaults] objectForKey:kEasterEggUnlocked] mutableCopy];
		unsigned count = [easterEggUnlockedArray count];
		if (count > kMaxEasterEggs) {
			// Need to remove entries
			for (int i=kMaxEasterEggs; i < count; i++)
				[easterEggUnlockedArray removeLastObject];
		}
		else if (count < kMaxEasterEggs) {
			// Need to add more entries
			for (int i=count; i < kMaxEasterEggs; i++)
				[easterEggUnlockedArray addObject: [NSNumber numberWithBool: NO]];
		}
		return easterEggUnlockedArray;
	}
	else {
		NSMutableArray* easterEggUnlockedArray = [[NSMutableArray alloc] init];
		[self initEasterEggUnlockedArray:easterEggUnlockedArray];
		//[self setEasterEggUnlockedArray:easterEggUnlockedArray]; // Infinite recursion!
		[[NSUserDefaults standardUserDefaults] setObject:easterEggUnlockedArray forKey:kEasterEggUnlocked];
		return easterEggUnlockedArray;
	}
}

+ (BOOL) easterEggUnlocked: (unsigned) easterEggIndex {
	if (easterEggIndex >= kMaxEasterEggs)
		return NO;
	
	NSMutableArray* easterEggUnlockedArray = [self easterEggUnlockedArray];
	return [((NSNumber*)[easterEggUnlockedArray objectAtIndex:easterEggIndex]) boolValue];
}

+ (BOOL) setEasterEggUnlocked: (BOOL) unlocked forEgg: (unsigned) easterEggIndex {
	if (easterEggIndex >= kMaxEasterEggs)
		return NO;
	
	NSMutableArray* easterEggUnlockedArray = [self easterEggUnlockedArray];
	[easterEggUnlockedArray replaceObjectAtIndex:easterEggIndex withObject:[NSNumber numberWithBool: unlocked]];
	return [self setEasterEggUnlockedArray:easterEggUnlockedArray];
}

+ (BOOL) setEasterEggUnlockedArray: (NSArray*) easterEggUnlockedArray {
	// Returns YES if any changes were made
	
	NSArray* previousEEArray = [self easterEggUnlockedArray];
	
	[[NSUserDefaults standardUserDefaults] setObject:easterEggUnlockedArray forKey:kEasterEggUnlocked];
	
	// Check for any changes and report them
	if (previousEEArray != nil) {
		for (int i=0; i < kMaxEasterEggs; i++) {
			if ([previousEEArray objectAtIndex:i] != [easterEggUnlockedArray objectAtIndex:i]) {
				[self setEasterEggUnlockedArrayChanged:YES];
				return YES;
			}
		}
	}
	else {
		[self setEasterEggUnlockedArrayChanged:YES];
		return YES;
	}
	
	return NO;
}



#pragma mark ----- Current Ball Type Methods ------

+ (BOOL) ballTypeChanged {
	return ballTypeChanged;
}
+ (void) setBallTypeChanged: (BOOL) setBallTypeChanged {
	ballTypeChanged = setBallTypeChanged;
}

+ (unsigned) ballIndex {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kBallIndex])
		return [[NSUserDefaults standardUserDefaults] integerForKey:kBallIndex];
	else {
		[self setBallIndex:0];
		return 0; // Start with the first ball
	}
}

+ (void) setBallIndex: (unsigned) newBallIndex {
	
	[[NSUserDefaults standardUserDefaults] setInteger:newBallIndex forKey:kBallIndex];
	
	[self setBallTypeChanged:YES];
}



#pragma mark ----- Custom Ball Parameter Methods ------

+ (BOOL) customBallParametersChanged {
	return customBallParametersChanged;
}
+ (void) setCustomBallParametersChanged: (BOOL) setCustomBallParametersChanged {
	customBallParametersChanged = setCustomBallParametersChanged;
}

// Custom Ball Radius
+ (float) customBallRadius {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kCustomBallRadius])
		return [[NSUserDefaults standardUserDefaults] floatForKey:kCustomBallRadius];
	else {
		[self setCustomBallRadius:kDefaultCustomBallRadius];
		return kDefaultCustomBallRadius; // Default custom ball radius
	}
}
+ (void) setCustomBallRadius: (float) newCustomBallRadius {
	
	[[NSUserDefaults standardUserDefaults] setFloat:newCustomBallRadius forKey:kCustomBallRadius];
	[self setCustomBallParametersChanged:YES];
}

// Custom Ball Mass
+ (float) customBallMass {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kCustomBallMass])
		return [[NSUserDefaults standardUserDefaults] floatForKey:kCustomBallMass];
	else {
		[self setCustomBallMass:kDefaultCustomBallMass];
		return kDefaultCustomBallMass; // Default custom ball mass
	}
}
+ (void) setCustomBallMass: (float) newCustomBallMass {
	
	[[NSUserDefaults standardUserDefaults] setFloat:newCustomBallMass forKey:kCustomBallMass];
	[self setCustomBallParametersChanged:YES];
}

// Custom Ball Bounce Factor
+ (float) customBallBounce {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kCustomBallBounce])
		return [[NSUserDefaults standardUserDefaults] floatForKey:kCustomBallBounce];
	else {
		[self setCustomBallBounce:kDefaultCustomBallBounce];
		return kDefaultCustomBallBounce; // Default custom ball bounce factor
	}
}
+ (void) setCustomBallBounce: (float) newCustomBallBounce {
	
	[[NSUserDefaults standardUserDefaults] setFloat:newCustomBallBounce forKey:kCustomBallBounce];
	[self setCustomBallParametersChanged:YES];
}

// Custom Ball Index
+ (BOOL) shouldUseCustomBallIndex {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kShouldUseCustomBallIndex])
		return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldUseCustomBallIndex];
	else {
		[self setShouldUseCustomBallIndex:NO];
		return NO;
	}
}
+ (void) setShouldUseCustomBallIndex: (BOOL) shoudUseCustomBallIndex {
	
	[[NSUserDefaults standardUserDefaults] setBool:shoudUseCustomBallIndex forKey:kShouldUseCustomBallIndex];
	[self setCustomBallParametersChanged:YES];
}
+ (unsigned) customBallIndex {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kCustomBallIndex])
		return [[NSUserDefaults standardUserDefaults] floatForKey:kCustomBallIndex];
	else {
		[self setCustomBallIndex:0];
		return 0; // Default to first ball
	}
}
+ (void) setCustomBallIndex: (unsigned) newCustomBallIndex {
	
	[[NSUserDefaults standardUserDefaults] setFloat:newCustomBallIndex forKey:kCustomBallIndex];
	[self setCustomBallParametersChanged:YES];
}

// Save all custom ball parameters as reflected in the BallTypes object
+ (void) saveCustomBallParameters {
	BallTypes * ballTypes = [BallTypes singleton];
	
	[self setCustomBallRadius:[ballTypes radiusOfBallAtIndex:[ballTypes customBallIndex]]];
	[self setCustomBallMass:[ballTypes massOfBallAtIndex:[ballTypes customBallIndex]]];
	[self setCustomBallBounce:[ballTypes bounceOfBallAtIndex:[ballTypes customBallIndex]]];
}



#pragma mark ----- Custom Images Methods ------

+ (UIImage*) customImage:(NSString*) imageFileName {
	NSData * imageData = [self applicationDataFromFile:imageFileName];
	if (imageData == nil)
		return nil;
	else {
		UIImage * loadedCustomImage = [UIImage imageWithData:imageData];
		return loadedCustomImage;
	}
}

+ (void) setCustomImage: (UIImage*) newCustomImage withImageFileName: (NSString*) imageFileName {
	// Convert image to an NSData object
	NSData * imageData = UIImagePNGRepresentation(newCustomImage);
	
	// Store with custom image filename
	[self writeApplicationData:imageData toFile:imageFileName];
}

// Custom Ball Image
+ (BOOL) customBallImageChanged {
	return customBallImageChanged;
}
+ (void) setCustomBallImageChanged: (BOOL) setCustomBallImageChanged {
	customBallImageChanged = setCustomBallImageChanged;
}
+ (UIImage*) customBallImage {
	return [self customImage:kCustomBallImage];
}
+ (void) setCustomBallImage: (UIImage*) newCustomBallImage {
	[self setCustomBallImageChanged:YES];
	
	return [self setCustomImage:newCustomBallImage withImageFileName:kCustomBallImage];
}
+ (void) removeCustomBallImage {
	[self setCustomBallImageChanged:YES];
	
	[self deleteApplicationDataFile:kCustomBallImage];
}

// Custom Wall Images
+ (BOOL) customWallImagesChanged {
	return customWallImagesChanged;
}
+ (void) setCustomWallImagesChanged: (BOOL) setCustomWallImagesChanged {
	customWallImagesChanged = setCustomWallImagesChanged;
}
// Custom Short Wall Image
+ (UIImage*) customShortWallImage {
	return [self customImage:kCustomShortWallImage];
}
+ (void) setCustomShortWallImage: (UIImage*) newCustomShortWallImage {
	[self setCustomWallImagesChanged:YES];
	
	return [self setCustomImage:newCustomShortWallImage withImageFileName:kCustomShortWallImage];
}
+ (void) removeCustomShortWallImage {
	[self setCustomWallImagesChanged:YES];
	
	[self deleteApplicationDataFile:kCustomShortWallImage];
}
// Custom Long Wall Image
+ (UIImage*) customLongWallImage {
	return [self customImage:kCustomLongWallImage];
}
+ (void) setCustomLongWallImage: (UIImage*) newCustomLongWallImage {
	[self setCustomWallImagesChanged:YES];
	
	return [self setCustomImage:newCustomLongWallImage withImageFileName:kCustomLongWallImage];
}
+ (void) removeCustomLongWallImage {
	[self setCustomWallImagesChanged:YES];
	
	[self deleteApplicationDataFile:kCustomLongWallImage];
}

// Custom Floor Image
+ (BOOL) customFloorImageChanged {
	return customFloorImageChanged;
}
+ (void) setCustomFloorImageChanged: (BOOL) setCustomFloorImageChanged {
	customFloorImageChanged = setCustomFloorImageChanged;
}
+ (UIImage*) customFloorImage {
	return [self customImage:kCustomFloorImage];
}
+ (void) setCustomFloorImage: (UIImage*) newCustomFloorImage {
	[self setCustomFloorImageChanged:YES];
	
	return [self setCustomImage:newCustomFloorImage withImageFileName:kCustomFloorImage];
}
+ (void) removeCustomFloorImage {
	[self setCustomFloorImageChanged:YES];
	
	[self deleteApplicationDataFile:kCustomFloorImage];
}



#pragma mark ----- Hi Resolution Graphics Preferences ------

+ (BOOL) enableHiResGraphicsChanged {
	return enableHiResGraphicsChanged;
}
+ (void) setEnableHiResGraphicsChanged: (BOOL) setEnableHiResGraphicsChanged {
	enableHiResGraphicsChanged = setEnableHiResGraphicsChanged;
}

+ (BOOL) enableHiResGraphics {
	// If data exists...
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnableHiResGraphics])
		return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableHiResGraphics];
	else {
		// Default = NO
		[self setEnableHiResGraphics:NO];
		return NO;
	}
}
+ (void) setEnableHiResGraphics: (BOOL) enableHiResGraphics {
	
	[[NSUserDefaults standardUserDefaults] setBool:enableHiResGraphics forKey:kEnableHiResGraphics];
	
	[self setEnableHiResGraphicsChanged:YES];
}


@end
