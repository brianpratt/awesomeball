//
//  BallTypes.h
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

#import <Foundation/Foundation.h>

// Conversion from actual measurements to screen drawing size
#define kRadiusScaleFactor 25.0
// Defaults for the custom ball
#define kDefaultCustomBallRadius 0.1 * kRadiusScaleFactor
#define kDefaultCustomBallMass   0.5
#define kDefaultCustomBallBounce 0.9

// Ball Type Identifiers
#define kBallTypeBasketball	@"Basketball"
#define kBallTypeBeachBall	@"BeachBall"
#define kBallTypeBowlingBall	@"BowlingBall"
#define kBallTypeEightBall	@"EightBall"
#define kBallTypeExerciseBall	@"ExerciseBall"
#define kBallTypeFourSquareBall	@"FourSquareBall"
#define kBallTypeGolfBall	@"GolfBall"
#define kBallTypeSoccerBall	@"SoccerBall"
#define kBallTypeTennisBall	@"TennisBall"
#define kBallTypeEarth		@"Earth"
#define kBallTypeInvisibleBall	@"InvisibleBall"
#define kBallTypeSmileyFace	@"SmileyFace"
#define kBallTypeCustomBall	@"Custom"


@interface BallTypes : NSObject {
	
	NSMutableArray		*ballTypeList;
	unsigned			customBallIndex;
	
}

@property (readonly) NSMutableArray *ballTypeList;

// Singleton accessor
+ (BallTypes*) singleton;

// Maintenance
- (void) reload;

// Generall Ball characteristics
-(NSString*) idOfBallAtIndex:(unsigned) index;
-(NSString*) nameOfBallAtIndex:(unsigned) index;
-(NSString*) imageFileForBallAtIndex:(unsigned) index;
-(NSString*) directSoundFilePrefixForBallAtIndex:(unsigned) index;
-(NSString*) deflectSoundFilePrefixForBallAtIndex:(unsigned) index;
-(float) radiusOfBallAtIndex:(unsigned) index;
-(float) bounceOfBallAtIndex:(unsigned) index;
-(float) massOfBallAtIndex:(unsigned) index;
-(BOOL) useMassForBallAtIndex:(unsigned) index;
-(BOOL) useAirResistanceForBallAtIndex:(unsigned) index;
-(unsigned) numberOfBuiltInBalls;
-(unsigned) numberofBalls;

// Custom Ball Settings
-(unsigned) customBallIndex;
-(void) setCustomBallName:(NSString*) name;
-(void) setCustomBallImageFile:(NSString*) imagefile;
-(void) useCustomBallImage;
-(void) setCustomBallSounds:(unsigned) index;
-(void) setCustomBallRadius:(float) radius;
-(void) setCustomBallBounce:(float) bounce;
-(void) setCustomBallMass:(float) mass;

// Easter Egg Ball Methods
-(void) addEasterEggBall;


@end
