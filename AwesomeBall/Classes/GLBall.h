//
//  GLBall.h
//  AwesomeBall
//
//  Created by Jonathan Johnson on 2/16/09.
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
//  GLBall simply implements an OpenGL sphere and handles the settings for 
//  the apperance of the sphere.

#import <Foundation/Foundation.h>
#import "ode.h"

@interface GLBall : NSObject {
	// Ball position
	GLfloat m_x;
	GLfloat m_y;
	GLfloat m_z;
	
	// Ball rotation (matrix form)
	GLfloat m_rot[12];
	
	// This is the radius of the ball
	GLfloat m_scale;
	
	// OpenGL texture number for the ball
	GLuint m_textureID;
	
	// scaling/shift parameters to "squish" the ball (currently unused)
	GLfloat m_xSquish;
	GLfloat m_xShift;
	GLfloat m_ySquish;
	GLfloat m_yShift;
	GLfloat m_zSquish;
	GLfloat m_zShift;
	
	// name for the ball's current texture
	NSString * imageName;
}

@property (nonatomic) NSString * imageName;

- (id) initWithX: (GLfloat) x Y: (GLfloat) y Z: (GLfloat) z andScale: (GLfloat) scale;
- (void) draw;

- (void) setScale: (GLfloat) scale;
- (void) setTexture: (NSString*) imName releaseOld: (BOOL) releaseOld reloadCustomImage: (BOOL) loadCustomBallImage;
- (void) setTexture: (NSString*) imName releaseOld: (BOOL) releaseOld;
- (void) setPos: (const dReal *) pos;
- (void) setRot: (const dReal *) rot;
- (void) setXSquish: (GLfloat) squish andShift: (GLfloat) shift;
- (void) setYSquish: (GLfloat) squish andShift: (GLfloat) shift;
- (void) setZSquish: (GLfloat) squish andShift: (GLfloat) shift;

@end
