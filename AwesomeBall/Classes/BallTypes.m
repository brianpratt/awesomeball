//
//  BallTypes.m
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
//  BallTypes is a wrapper around an NSArray that holds all of the ball types
//  supported. Characteristics of the different balls are stored here.
//  For now, a single custom ball is also supported.
//  This is a singleton object. Many classes will access this object.

#import "BallTypes.h"
#import "TextureLoader.h"
#import "UserDefaults.h"
#import "EasterEggs.h"

// A class extension to declare private methods
@interface BallTypes ()

- (void) loadBalls;

@end


@implementation BallTypes

@synthesize ballTypeList;

+ (BallTypes *)singleton
{
	static BallTypes *singleton;
	
	if (!singleton)
		singleton = [[BallTypes alloc] init];
	
	return singleton;
}

-(id) init {
	
    self = [super init];
    
    if (self != nil) {
		
		[self loadBalls];

	}
	
	return self;
}


- (void) loadBalls {
	// construct the array of ball types we will have available (each array element is a dictionary)
	ballTypeList = [[NSMutableArray alloc] init];
	
	// Parameters and scale factor
	float radius, bounce, mass;
	NSString *ballname;
	
	// Basketball
	// 30-inch circumfrence = 0.121276067 meter radius
	radius = 0.121276067 * kRadiusScaleFactor;
	bounce = 0.8;
	mass = 0.625; // kg
	ballname = NSLocalizedString(@"Basketball", @"Basketball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeBasketball, @"id",
							 ballname, @"name",
							 @"basketball", @"imagefile",
							 @"basketball", @"directsoundfileprefix",
							 @"basketball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	// Beach Ball
	// 16-inch diameter = 0.2032 meter radius
	radius = 0.2032 * kRadiusScaleFactor;
	bounce = 0.6;
	mass = 0.03; //0.0498951607; // kg
	ballname = NSLocalizedString(@"Beach Ball", @"Beach Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeBeachBall, @"id",
							 ballname, @"name",
							 @"beach_ball", @"imagefile",
							 @"beach_ball", @"directsoundfileprefix",
							 @"beach_ball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:YES], @"useAirResistance",
							 [NSNumber numberWithBool:YES], @"useMass",
							 nil]];
	
	// Bowling Ball
	// 8.5-inch diameter = 0.10795 meter radius
	radius = 0.10795 * kRadiusScaleFactor;
	bounce = 0.3;
	mass = 5.44310844; // kg
	ballname = NSLocalizedString(@"Bowling Ball", @"Bowling Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeBowlingBall, @"id",
							 ballname, @"name",
							 @"bowling_ball", @"imagefile",
							 @"bowling_ball", @"directsoundfileprefix",
							 @"bowling_ball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	// Eight Ball
	// 2.25-inch diameter = 0.028575 meter radius
	radius = 0.028575 * kRadiusScaleFactor;
	bounce = 0.5;
	mass = 0.17; // kg
	ballname = NSLocalizedString(@"Eight Ball", @"Eight Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeEightBall, @"id",
							 ballname, @"name",
							 @"eight_ball", @"imagefile",
							 @"eight_ball", @"directsoundfileprefix",
							 @"eight_ball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	// Exercise Ball
	// 65 cm diameter = 0.325 meter radius
	radius = 0.325 * kRadiusScaleFactor;
	bounce = 0.80;
	mass = 0.5; // kg // ???
	ballname = NSLocalizedString(@"Exercise Ball", @"Exercise Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeExerciseBall, @"id",
							 ballname, @"name",
							 @"exercise_ball", @"imagefile",
							 @"exercise_ball", @"directsoundfileprefix",
							 @"exercise_ball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	// Four Square Ball
	// 8.5-inch diameter = 0.10795 meter radius
	radius = 0.10795 * kRadiusScaleFactor;
	bounce = 0.90;
	mass = 0.5; // kg // ???
	ballname = NSLocalizedString(@"Four Square Ball", @"Four Square Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeFourSquareBall, @"id",
							 ballname, @"name",
							 @"foursquare_ball", @"imagefile",
							 @"RubberBallBounce", @"directsoundfileprefix",
							 @"RubberBallBounce", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	// Golf Ball
	// 1.680-inch diameter = 0.021336 meter radius
	radius = 0.021336 * kRadiusScaleFactor;
	bounce = 0.90;
	mass = 0.0459; // kg
	ballname = NSLocalizedString(@"Golf Ball", @"Golf Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeGolfBall, @"id",
							 ballname, @"name",
							 @"golf_ball", @"imagefile",
							 @"golf_ball", @"directsoundfileprefix",
							 @"golf_ball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	// Soccer Ball
	// 27.5-inch circumfrence = 0.111169728 meter radius
	radius = 0.111169728 * kRadiusScaleFactor;
	bounce = 0.6;
	mass = 0.45; // kg
	ballname = NSLocalizedString(@"Soccer Ball", @"Soccer Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeSoccerBall, @"id",
							 ballname, @"name",
							 @"soccer_ball", @"imagefile",
							 @"basketball", @"directsoundfileprefix",
							 @"basketball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	// Tennis Ball
	// 2.5-inch diameter = 0.03175 meter radius
	radius = 0.03175 * kRadiusScaleFactor;
	bounce = 0.85;
	mass = 0.057; // kg
	ballname = NSLocalizedString(@"Tennis Ball", @"Tennis Ball name");
	[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 kBallTypeTennisBall, @"id",
							 ballname, @"name",
							 @"tennis_ball", @"imagefile",
							 @"tennis_ball", @"directsoundfileprefix",
							 @"tennis_ball", @"deflectsoundfileprefix",
							 [NSNumber numberWithFloat:radius], @"radius",
							 [NSNumber numberWithFloat:bounce], @"bounce",
							 [NSNumber numberWithFloat:mass], @"mass",
							 [NSNumber numberWithBool:NO], @"useAirResistance",
							 [NSNumber numberWithBool:NO], @"useMass",
							 nil]];
	
	////////////////////
	// Easter Egg Balls - Unlockable
	
	// Earth Ball
	// Only show this ball if it has been previously unlocked
	if ([UserDefaults easterEggUnlocked:kEasterEggEarthBall]) {
		radius = 0.15 * kRadiusScaleFactor;
		bounce = 0.9;
		mass = 0.5; // kg
		ballname = NSLocalizedString(@"Earth", @"Earth Ball name");
		[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        							 kBallTypeEarth, @"id",
								 ballname, @"name",
								 @"earth", @"imagefile",
								 @"earth", @"directsoundfileprefix",
								 @"earth", @"deflectsoundfileprefix",
								 [NSNumber numberWithFloat:radius], @"radius",
								 [NSNumber numberWithFloat:bounce], @"bounce",
								 [NSNumber numberWithFloat:mass], @"mass",
								 [NSNumber numberWithBool:NO], @"useAirResistance",
								 [NSNumber numberWithBool:NO], @"useMass",
								 nil]];
	}
	
	
	// Invisible Ball
	// Only show this ball if it has been previously unlocked
	if ([UserDefaults easterEggUnlocked:kEasterEggInvisibleBall]) {
		radius = 0.15 * kRadiusScaleFactor;
		bounce = 0.9;
		mass = 0.5; // kg
		ballname = NSLocalizedString(@"Invisible Ball", @"Invisible Ball name");
		[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        							 kBallTypeInvisibleBall, @"id",
								 ballname, @"name",
								 @"invisible", @"imagefile",
								 @"RubberBallBounce", @"directsoundfileprefix",
								 @"RubberBallBounce", @"deflectsoundfileprefix",
								 [NSNumber numberWithFloat:radius], @"radius",
								 [NSNumber numberWithFloat:bounce], @"bounce",
								 [NSNumber numberWithFloat:mass], @"mass",
								 [NSNumber numberWithBool:NO], @"useAirResistance",
								 [NSNumber numberWithBool:NO], @"useMass",
								 nil]];
	}
	
	
	// Smiley Ball
	// Only show this ball if it has been previously unlocked
	if ([UserDefaults easterEggUnlocked:kEasterEggSmileyBall]) {
		radius = 0.15 * kRadiusScaleFactor;
		bounce = 0.9;
		mass = 0.5; // kg
		ballname = NSLocalizedString(@"Smiley Face", @"Smiley Face Ball name");
		[ballTypeList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        							 kBallTypeSmileyFace, @"id",
								 ballname, @"name",
								 @"smiley", @"imagefile",
								 @"smiley", @"directsoundfileprefix",
								 @"smiley", @"deflectsoundfileprefix",
								 [NSNumber numberWithFloat:radius], @"radius",
								 [NSNumber numberWithFloat:bounce], @"bounce",
								 [NSNumber numberWithFloat:mass], @"mass",
								 [NSNumber numberWithBool:NO], @"useAirResistance",
								 [NSNumber numberWithBool:NO], @"useMass",
								 nil]];
	}
	
	
	////////////////////
	// Custom Ball
	// This must be the last ball in the array so the ball image picker can ignore this one simply by
	//   returning (arraySize - 1) for the number of balls available.
	// Load these settings from saved settings
	radius = [UserDefaults customBallRadius];
	bounce = [UserDefaults customBallBounce];
	mass = [UserDefaults customBallMass];
	ballname = NSLocalizedString(@"Custom Ball", @"Custom Ball name");
	NSMutableDictionary* customBallDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   kBallTypeCustomBall, @"id",
										   ballname, @"name",
										   @"questions", @"imagefile",
										   @"RubberBallBounce", @"directsoundfileprefix",
										   @"RubberBallBounce", @"deflectsoundfileprefix",
										   [NSNumber numberWithFloat:radius], @"radius",
										   [NSNumber numberWithFloat:bounce], @"bounce",
										   [NSNumber numberWithFloat:mass], @"mass",
										   [NSNumber numberWithBool:YES], @"useAirResistance",
										   [NSNumber numberWithBool:YES], @"useMass",
										   nil];
	[ballTypeList addObject: customBallDict];
	customBallIndex = [ballTypeList indexOfObject: customBallDict];
	
}

- (void) reload {
	[self loadBalls];
}


#pragma mark ----- General Accessor Methods -----


-(NSString*) idOfBallAtIndex:(unsigned) index {
	return [[ballTypeList objectAtIndex:index] objectForKey:@"id"];
}

-(NSString*) nameOfBallAtIndex:(unsigned) index {
	return [[ballTypeList objectAtIndex:index] objectForKey:@"name"];
}

-(NSString*) imageFileForBallAtIndex:(unsigned) index {
	return [[ballTypeList objectAtIndex:index] objectForKey:@"imagefile"];
}

-(NSString*) directSoundFilePrefixForBallAtIndex:(unsigned) index {
	return [[ballTypeList objectAtIndex:index] objectForKey:@"directsoundfileprefix"];
}

-(NSString*) deflectSoundFilePrefixForBallAtIndex:(unsigned) index {
	return [[ballTypeList objectAtIndex:index] objectForKey:@"deflectsoundfileprefix"];
}

-(float) radiusOfBallAtIndex:(unsigned) index {
	return [[[ballTypeList objectAtIndex:index] objectForKey:@"radius"] floatValue];
}

-(float) bounceOfBallAtIndex:(unsigned) index {
	return [[[ballTypeList objectAtIndex:index] objectForKey:@"bounce"] floatValue];
}

-(float) massOfBallAtIndex:(unsigned) index {
	return [[[ballTypeList objectAtIndex:index] objectForKey:@"mass"] floatValue];
}

-(BOOL) useMassForBallAtIndex:(unsigned) index {
	return [[[ballTypeList objectAtIndex:index] objectForKey:@"useMass"] boolValue];
}

-(BOOL) useAirResistanceForBallAtIndex:(unsigned) index {
	return [[[ballTypeList objectAtIndex:index] objectForKey:@"useAirResistance"] boolValue];
}

-(unsigned) numberOfBuiltInBalls {
	return [ballTypeList count] - 1; // Don't include the one custom ball. Include Easter Egg balls.
}

-(unsigned) numberofBalls {
	return [ballTypeList count]; // Include all balls
}


#pragma mark ----- Custom Ball Methods -----

-(unsigned) customBallIndex {
	// The custom ball is really just the last ball in the array
	return [ballTypeList count] - 1;
	//return customBallIndex;
}

-(void) setCustomBallName:(NSString*) name {
	// Allow the user to customize the name of the custom ball
	[[ballTypeList objectAtIndex:([ballTypeList count]-1)] setObject:name forKey:@"name"];
}

-(void) setCustomBallImageFile:(NSString*) imagefile {
	// Use the image from one of the other built-in balls
	[[ballTypeList objectAtIndex:([ballTypeList count]-1)] setObject:imagefile forKey:@"imagefile"];
}

-(void) useCustomBallImage {
	// Simply update the image name in dictionary to the reserved custom ball image name
	[self setCustomBallImageFile:@"customBall"];
}

-(void) setCustomBallSounds:(unsigned) index {
	// Use the sounds from one of the other built-in balls
	[[ballTypeList objectAtIndex:([ballTypeList count]-1)] setObject:[[ballTypeList objectAtIndex:index] objectForKey:@"directsoundfileprefix"] forKey:@"directsoundfileprefix"];
	[[ballTypeList objectAtIndex:([ballTypeList count]-1)] setObject:[[ballTypeList objectAtIndex:index] objectForKey:@"deflectsoundfileprefix"] forKey:@"deflectsoundfileprefix"];
}

-(void) setCustomBallRadius:(float) radius {
	[[ballTypeList objectAtIndex:([ballTypeList count]-1)] setObject:[NSNumber numberWithFloat:radius] forKey:@"radius"];
}

-(void) setCustomBallBounce:(float) bounce {
	[[ballTypeList objectAtIndex:([ballTypeList count]-1)] setObject:[NSNumber numberWithFloat:bounce] forKey:@"bounce"];
}

-(void) setCustomBallMass:(float) mass {
	[[ballTypeList objectAtIndex:([ballTypeList count]-1)] setObject:[NSNumber numberWithFloat:mass] forKey:@"mass"];
}



#pragma mark ----- Easter Egg Ball Methods -----

-(void) addEasterEggBall {
	// Handle the addition of a new Easter egg ball:
	//  - Reload the ball list to include the new ball
	//  - Change the index of the saved ball, if necessary
	// (This must be done for both the saved ball index as well as the saved custom ball image index)
	
	// Get the current saved ball info
	unsigned savedBallIndex = [UserDefaults ballIndex];
	NSString* savedBallName = [self nameOfBallAtIndex: savedBallIndex];
	unsigned savedCustomBallIndex = [UserDefaults customBallIndex];
	NSString* savedCustomBallImageName = [self nameOfBallAtIndex: savedCustomBallIndex];
	
	// Reload the ball list
	[self reload];
	
	//////////
	// 1. Saved Ball Index
	// Find the saved ball in the altered ball list
	unsigned numBalls = [self numberofBalls];
	unsigned newBallIndex = 0;
	for (int i=0; i < numBalls; i++) {
		if ([savedBallName isEqualToString:[self nameOfBallAtIndex: i]]) {
			newBallIndex = i;
			break;
		}
	}
	// Set the new ball index
	[UserDefaults setBallIndex: newBallIndex];
	
	//////////
	// 2. Saved Custom Ball Image Index
	// Find the saved ball in the altered ball list
	newBallIndex = 0;
	for (int i=0; i < numBalls; i++) {
		if ([savedCustomBallImageName isEqualToString:[self nameOfBallAtIndex: i]]) {
			newBallIndex = i;
			break;
		}
	}
	// Set the new ball index
	[UserDefaults setCustomBallIndex: newBallIndex];
}


@end
