//
//  EAGLView.m
//  AwesomeBall
//
//  Created by Jonathan Johnson on 2/13/09.
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
////  Copyright 2009 Jonathan Johnson and Brian Pratt. All rights reserved.
//
//  GLView is the UIView that displays the OpenGL elements of the app (the ball, wall, etc)
//  When refreshing its view, it uses the GameType object specified to do any extra actions.



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "GLView.h"
#import "TextureLoader.h"
#import "UserDefaults.h"


#define USE_DEPTH_BUFFER 1

// A class extension to declare private methods
@interface GLView ()

@property (nonatomic) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end

static EAGLContext * static_context = nil;

@implementation GLView

+ (EAGLContext *) getStaticContext {
	if (static_context == nil) {
		static_context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES1];
	}
	return static_context;
}

@synthesize context;

@synthesize m_gameType;

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

- (id) initWithFrame: (CGRect) frame {
	self = [super initWithFrame: frame];
	
	return [self initialize];
}

- (id) initialize {
	
	if ([UserDefaults enableHiResGraphics]) {
		// Retina Display support
		// Set scale factor of this view to 2.0 for 2.0-scaled devices
		// The CAEAGLLayer will then match that scale factor automatically
		UIScreen *mainScreen = [UIScreen mainScreen];
		if ([mainScreen respondsToSelector:@selector(scale)] && [mainScreen scale] == 2.0)
			self.contentScaleFactor = 2.0;
	}
	
	
	// Get the layer
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	eaglLayer.opaque = NO; // Leave the background transparent
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	
	// Each openGL view has one static context throughout the app's life. The context is used as a key in a texture
	// loading map to keep track of which textures have been loaded for which openGL views (there are only two so far)
	context = [GLView getStaticContext];
	if (!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
		return nil;
	}
	
	m_animationInterval = 1.0 / 60.0;
	
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glViewport(0, 0, backingWidth, backingHeight);
	
	return self;
}


#pragma mark----- View Methods -----


- (void)drawView {
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    // Leave the background transparent
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	[m_gameType drawGameView];
	[m_gameType physicsTimeStep];
	
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






#pragma mark ----- Dealloc -----


- (void)dealloc {
    
    [self stopAnimation];
    
	
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
	
    // don't release the context (only 1 will ever be made)

}

@end
