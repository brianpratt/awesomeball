//
//  GLWall.h
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
//  GLWalls is a box consisting of 5 GLWall objects. Since the settings for 
//  these walls (position, appearance, etc.) are tied together so tightly,
//  they are grouped in this class.

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class GLWall;

@interface GLWalls : NSObject {

	GLWall * m_leftWall;
	GLWall * m_rightWall;
	GLWall * m_topWall;
	GLWall * m_bottomWall;
	GLWall * m_floor;
	
	NSString * shortWallImageName;
	NSString * longWallImageName;
	NSString * floorImageName;
}

@property (nonatomic) NSString * shortWallImageName;
@property (nonatomic) NSString * longWallImageName;
@property (nonatomic) NSString * floorImageName;

- (id) initWithLeft: (GLfloat) left Right: (GLfloat) right Top: (GLfloat) top Bottom: (GLfloat) bottom andHeight: (GLfloat) height;
- (void) loadImagesForWalls: (BOOL) loadWallImages andFloor: (BOOL) loadFloorImage;
- (void) loadWallImages;
- (void) setImagesForWallsNamed:(NSString*)wallImageName andFloorNamed:(NSString*)floorImageName;
- (void) setImagesForsShortWallsNamed:(NSString*)shortWallImageName andLongWallsNamed:(NSString*)longWallImageName andFloorNamed:(NSString*)floorImageName;
- (void) setCustomFloorImage:(UIImage*)floorImage;
- (void) setCustomWallImagesToShort:(UIImage*)shortWallImage andLong:(UIImage*)longWallImage;
- (void) resetWallImages: (BOOL) removeCustomImages;
- (void) resetWallImages;
- (void) resetFloorImage: (BOOL) removeCustomImage;
- (void) resetFloorImage;
- (void) makeWallsInvisible;
- (void) draw;

@end
