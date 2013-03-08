//
//  GLPreView.m
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

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "GLPreView.h"
#import "GLBall.h"
#import "GLWalls.h"
#import "glUtil.h"
#import "TextureLoader.h"
#import "ode.h"
#import "BallTypes.h"
#import "RootViewController.h"


#define USE_DEPTH_BUFFER 1

// These define the boundaries for the walls
#define LEFT_LIMIT -5
#define RIGHT_LIMIT 20
#define TOP_LIMIT 10
#define BOTTOM_LIMIT -30
#define HEIGHT 30

#define MAX_DEPTH 100

#define GLOBAL_CFM .1



// A class extension to declare private methods
@interface GLPreView ()

@property (nonatomic) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


static EAGLContext * static_context = nil;

@implementation GLPreView

@synthesize context;
@synthesize m_walls;

+ (EAGLContext *) getStaticContext {
	if (static_context == nil) {
		static_context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES1];
	}
	return static_context;
}


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}



#pragma mark----- Initialization Methods -----


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
		return [self initialize];
    }
    return self;
}
 
- (id) initWithFrame: (CGRect) frame andObjectType: (glObjType) objectType {
	self = [super initWithFrame: frame];
	
	objType = objectType;
	
	return [self initialize];
}

- (id) initialize {
	
	if (ENABLE_HI_RES_PREVIEW) {
		// Retina Display support
		// Set scale factor of this view to 2.0 for 2.0-scaled devices
		// The CAEAGLLayer will then match that scale factor automatically
		UIScreen *mainScreen = [UIScreen mainScreen];
		if ([mainScreen respondsToSelector:@selector(scale)] && [mainScreen scale] == 2.0)
			self.contentScaleFactor = 2.0;
	}
	
	// Get the layer
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	eaglLayer.opaque = NO; // Leave the background slightly transparent
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	
	// Save the current context and restore it when this object is destroyed
	savedContext = [EAGLContext currentContext];
	 
	context = [GLPreView getStaticContext];
	
	if (!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
		return nil;
	}
	
	m_animationInterval = 1.0 / 30.0;
	
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glViewport(0, 0, backingWidth, backingHeight);
	
	const GLfloat			lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			matAmbient[] = {0.6, 0.6, 0.6, 1.0};
	const GLfloat			matDiffuse[] = {1.0, 1.0, 1.0, 1.0};	
	const GLfloat			matSpecular[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			lightPosition[] = {0.0, 0.0, 1.0, 0.0}; 
	const GLfloat			lightShininess = 100.0;
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition); 			
	glShadeModel(GL_SMOOTH);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_COLOR_MATERIAL);
	
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	CGRect rect = self.bounds;
	
	if (ENABLE_HI_RES_PREVIEW) {
		// Retina Display support
		// Scale the viewport by 2.0 for 2.0-scaled devices
		UIScreen *mainScreen = [UIScreen mainScreen];
		if ([mainScreen respondsToSelector:@selector(scale)] && [mainScreen scale] == 2.0) {
			gluPerspective(45, rect.size.width / rect.size.height, .1, MAX_DEPTH);
			glViewport(0, 0, rect.size.width*2, rect.size.height*2);
		}
		else{
			gluPerspective(45, rect.size.width / rect.size.height, .1, MAX_DEPTH);
			glViewport(0, 0, rect.size.width, rect.size.height);
		}
	}
	else {
		gluPerspective(45, rect.size.width / rect.size.height, .1, MAX_DEPTH);
		glViewport(0, 0, rect.size.width, rect.size.height);
	}

	
	glMatrixMode(GL_MODELVIEW);
	

	// Grab the BallTypes instance
	ballTypes = [BallTypes singleton];
	
	if (objType == glBallType) {
		// Set up a ball object
		m_ballRadius = 2;
		m_ball = [[GLBall alloc] initWithX: 0.0 Y: 0.0 Z: 0 andScale: m_ballRadius];
		
	}
	else if (objType == glWallType) {
		// Set up a set of walls (a box)
		m_walls = [[GLWalls alloc] initWithLeft: LEFT_LIMIT Right: RIGHT_LIMIT Top: TOP_LIMIT Bottom: BOTTOM_LIMIT andHeight: HEIGHT];
	}

	return self;
}


#pragma mark----- View Methods -----


- (void)drawView {
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    // Leave the background slightly transparent
    glClearColor(0.0f, 0.0f, 0.0f, 0.75f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	
	if (objType == glBallType) {
		static GLfloat cameraAngleX = 0; // rotation about X axis
		static GLfloat cameraAngleY = 0; // rotation about Y axis
		cameraAngleX += .75;
		cameraAngleY += 1.5;
		if (cameraAngleX > 360)
			cameraAngleX -= 360;
		if (cameraAngleY > 360)
			cameraAngleY -= 360;
		
		// Set camera posision
		glTranslatef(0, 0, -15);
		
		// set camera rotation
		glRotatef(cameraAngleX, 1.0, 0, 0);
		glRotatef(cameraAngleY, 0, 1.0, 0);

		[m_ball draw];
	}
	else if (objType == glWallType) {
		
		// Move camera posision
		static float cameraPos = 25.0;
		cameraPos += 0.5;
		if (cameraPos >= 50.0)
			cameraPos = 25.0;
		glTranslatef(0.0, 0.0, -cameraPos);
		
		[m_walls draw];
	}
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];	
	
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}



#pragma mark----- FrameBuffer and Animation -----


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)startAnimation {
	if (m_animationTimer != nil && [m_animationTimer isValid])
		[m_animationTimer invalidate];
	
    self.m_animationTimer = [NSTimer scheduledTimerWithTimeInterval:m_animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    if (m_animationTimer != nil && [m_animationTimer isValid])
		[m_animationTimer invalidate];
    self.m_animationTimer = nil;
}


- (void)setM_animationTimer:(NSTimer *)newTimer {
    if (m_animationTimer != nil && [m_animationTimer isValid]) {
		[m_animationTimer invalidate];
    }
    m_animationTimer = newTimer;
}


- (void)setM_animationInterval:(NSTimeInterval)interval {
    
    m_animationInterval = interval;
    if (m_animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}


#pragma mark----- Customization Methods -----

- (void) setBallSize:(float)radius {
	// Update the ball size so the user can see the change in real time
	
	// Set ball size
	m_ballRadius = radius;
	[m_ball setScale: m_ballRadius];
	
}

- (void) setBallTypeIndex: (unsigned) index {
	// Update the ball image so the user can see the change in real time
	
	// Set ball size
	m_ballRadius = [ballTypes radiusOfBallAtIndex:index];
	[m_ball setScale: m_ballRadius];
	
	// Setup texture
	// Release the previous texture from memory if there has been a memory warning during this session
	// so we keep our memory usage down.
	BOOL shouldReleaseOld = [RootViewController getSingleton].hasReceivedMemoryWarning;
	[m_ball setTexture:[ballTypes imageFileForBallAtIndex:index] releaseOld: shouldReleaseOld];
}


- (void)dealloc {
    
    [self stopAnimation];
	
	
    if ([EAGLContext currentContext] == context) {
		// Restore saved context
        [EAGLContext setCurrentContext:savedContext];
    }
	
	// don't release the context (only 1 will ever be made)
	
}


@end
