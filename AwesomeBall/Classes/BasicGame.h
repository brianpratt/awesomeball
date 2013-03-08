//
//  BasicGame.h
//  AwesomeBall
//
//  Created by Brian Pratt on 4/16/09.
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
//  BasicGame is the most basic game type: one ball in a box
//  BasicGame includes handling for the accelerometer, pinch zooming, and swipe spinning

#import <Foundation/Foundation.h>
#import "GameType.h"
#import "ode.h"
#import <OpenGLES/ES1/gl.h>


@class GLView, GLBall, SoundEffect, BallTypes, GLWalls;

@interface BasicGame : NSObject <GameType, UIAccelerometerDelegate> {

	GLView * glView;	
	
	/* -- Game Stuff -- */
	// ODE World and Space
	GLBall * m_ball;
	dWorldID m_world;
	dSpaceID m_space;
	dJointGroupID m_contactGroup;
	
	// Ball
	BallTypes * ballTypes;
	dBodyID m_ballID;
	dGeomID m_ballGeom;
	dReal m_ballRadius;
	dReal m_ballArea; // Cross-sectional area
	dReal m_ballMass;
	dReal m_ballBounce;
	
	// Walls
	GLWalls * m_walls;
	dGeomID m_wallGeoms[6];
	
	// Camera
	BOOL cameraFollowsBall;
	GLfloat m_cameraX;
	GLfloat m_cameraY;
	GLfloat m_cameraZ;
	GLfloat m_cameraX_offset;
	GLfloat m_cameraY_offset;
	GLfloat m_cameraZ_zoom;

	
	
	// Sound Effects
    SoundEffect *directBounceSounds[4];
	// Reuse the same sounds to save memory since we don't have any deflect sounds for now.
	
	// Accelerometer values
	UIAccelerationValue m_accX, m_accY, m_accZ;
	UIAccelerationValue m_accX_hp, m_accY_hp, m_accZ_hp; // With high-pass filter
	UIAccelerationValue m_accX_lp, m_accY_lp, m_accZ_lp; // With low-pass filter
	
	/* -- Touch Handling stuff -- */	
	// Keep track of touches state
	BOOL touchesBeganButNotEnded;
	
	//Variables for touch gesture recognition
    CGFloat             initialXPosition;
    CGFloat             initialYPosition;
    CGFloat             initialDistance;
    
    //Variables for matrix transformations
    float               movedZ;
    float               movedX;
    float               movedY;
	NSDate * timeStamp;
	
}

@property (nonatomic) GLWalls * m_walls;

@property (readwrite) float movedX;
@property (readwrite) float movedY;
@property (readwrite) float movedZ;


- (id) initWithGLView: (GLView *) view;
- (void) callBack: (void *) data id1: (dGeomID) o1 id2: (dGeomID) o2;
- (void) setBallTypeIndex: (unsigned) index reloadCustomImage: (BOOL) loadCustomBallImage;
- (void) setBallTypeIndex: (unsigned) index;
- (void) setBallSize:(float)radius andBounce:(float)bounce andMass:(float)mass;
- (void) setCameraFollowsBall:(BOOL)followBall;
- (void) setupSoundEffectsUsingDirectSoundFilePrefix:(NSString*)directSoundFilePrefix andDeflectSoundFilePrefix:(NSString*)deflectSoundFilePrefix;
- (void) resetZoomFactor;
- (void) addTorqueX: (dReal) x Y: (dReal) y Z: (dReal) z;
- (CGFloat) distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;


@end
