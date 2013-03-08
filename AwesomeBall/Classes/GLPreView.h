//
//  GLPreView.h
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
//  GLPreView is a basic GLView meant for showing off the different ball types
//  or environment types that a user can choose from in a small OpenGL window.
//  GLPreView has its own EAGLContext associated with it, so it has a set of
//  textures separate from the main GLView. This view is meant to be completely 
//  unloaded when it is not in use in order to save memory.

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "ode.h"
#import "BallTypes.h"

@class GLBall, GLWalls, BallTypes;

typedef enum glObjTypeEnum {
	glBallType,
	glWallType
} glObjType;


@interface GLPreView : UIView {

@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    EAGLContext *savedContext;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
    
    NSTimer *m_animationTimer;
    NSTimeInterval m_animationInterval;
	
	// Object Type
	glObjType objType;
	
	// Ball
	BallTypes * ballTypes;
	GLBall * m_ball;
	dReal m_ballRadius;
	
	// Walls
	GLWalls * m_walls;	
	
}

@property (nonatomic) GLWalls * m_walls;

- (id) initWithFrame: (CGRect) frame andObjectType: (glObjType) objectType;
- (id) initialize;
- (void) startAnimation;
- (void) stopAnimation;
- (void) drawView;
- (void) setBallSize:(float)radius;
- (void) setBallTypeIndex: (unsigned) index;
+ (EAGLContext *) getStaticContext;

@end
