//
//  GLBall.m
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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "GLBall.h"
#import "TextureLoader.h"
#import "ball_model.h"
#import "ode.h"
#import "UserDefaults.h"

@implementation GLBall

@synthesize imageName;

- (id) initWithX: (GLfloat) x Y: (GLfloat) y Z: (GLfloat) z andScale: (GLfloat) scale {
	m_x = x;
	m_y = y;
	m_z = z;
	
	// initialize with no rotation (identity matrix)
	m_rot[0] = 1;
	m_rot[1] = 0;
	m_rot[2] = 0;
	m_rot[3] = 0;
	
	m_rot[4] = 0;
	m_rot[5] = 1;
	m_rot[6] = 0;
	m_rot[7] = 0;
	
	m_rot[8] = 0;
	m_rot[9] = 0;
	m_rot[10] = 1;
	m_rot[11] = 1;
	
	// these aren't really used yet (these values make them have no effect)
	m_xShift = 0.0;
	m_xSquish = 1.0;
	m_yShift = 0.0;
	m_ySquish = 1.0;
	m_zShift = 0.0;
	m_zSquish = 1.0;
	
	m_scale = scale;
	imageName = NULL;
	
	return self;
}


- (void) draw {
	
	// Special case: invisible ball
	if ([imageName isEqual:@"invisible"])
		return;
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();

	// apply shift/squish parameters (not currently used)
	glTranslatef(m_x + m_xShift, m_y + m_yShift, m_z + m_zShift);
	glScalef(m_xSquish, m_ySquish, m_zSquish);
	
	// apply ball rotation
	GLfloat matrix[16];
	matrix[0] = m_rot[0];
	matrix[1] = m_rot[4];
	matrix[2] = m_rot[8];
	matrix[3] = 0;
	matrix[4] = m_rot[1];
	matrix[5] = m_rot[5];
	matrix[6] = m_rot[9];
	matrix[7] = 0;
	matrix[8] = m_rot[2];
	matrix[9] = m_rot[6];
	matrix[10] = m_rot[10];
	matrix[11] = 0;
	matrix[12] = 0;
	matrix[13] = 0;
	matrix[14] = 0;
	matrix[15] = 1;
	glMultMatrixf(matrix);
	
	// apply ball scale (radius)
	glScalef(m_scale, m_scale, m_scale);
	
	// perform drawing using coordinate/normal/texture arrays
	glVertexPointer(3, GL_FLOAT, 0, ballVertices);
	glNormalPointer(GL_FLOAT, 0, ballNormals);
	glTexCoordPointer (2, GL_FLOAT, 0, ballTexture);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, m_textureID);
	glEnable(GL_TEXTURE_2D);
	//glEnable(GL_BLEND);
//	glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA);
//	glDisable(GL_DEPTH_TEST);
	glColor4f(1, 1, 1, 1);
	for (unsigned int i = 0; i < ballIndexCount/3; i++) {
		glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_SHORT, &ballIndices[i * 3]);
	}
//	glEnable(GL_DEPTH_TEST);
//	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glPopMatrix();
}

- (void) setScale: (GLfloat) scale {
	m_scale = scale;
}

- (void) setTexture: (NSString*) imName releaseOld: (BOOL) releaseOld reloadCustomImage: (BOOL) loadCustomBallImage {
	//NSLog(@"imageName: %@", imageName);
	static NSString *customBallName = @"customBall";

	// Custom image or built-in image?
	if ([imName compare: customBallName] == NSOrderedSame) {
		if (self.imageName && [self.imageName compare: customBallName] == NSOrderedSame) {
			if (!loadCustomBallImage)
				return; // Don't do work we don't have to do. (Was previously a custom ball image and it hasn't changed)
			else
				// Custom image should always be released to make sure we have the newest image
				[TextureLoader releaseTextureWithName: customBallName];
		}
		
		// Release old image
		if (self.imageName && releaseOld)
			[TextureLoader releaseTextureWithName: self.imageName];
		
		// Custom Ball image is in a different area than all other images
		UIImage * customImage = [UserDefaults customBallImage];
		if (customImage != nil) {
			CGImageRef cgImage = customImage.CGImage;
			m_textureID = [TextureLoader textureFromImage: cgImage withName: customBallName];
		}
	}
	else {
		if (self.imageName && [self.imageName compare: imName] == NSOrderedSame)
			return; // Don't do work we don't have to do!
		
		// Release old image
		if (self.imageName && releaseOld)
			[TextureLoader releaseTextureWithName: self.imageName];
		
		// Standard image
		m_textureID = [TextureLoader textureFromImageNamed: imName];
	}
	
	self.imageName = imName;
}

- (void) setTexture: (NSString*) imName releaseOld: (BOOL) releaseOld {
	[self setTexture: imName releaseOld: releaseOld reloadCustomImage: YES];
}

// set ball position
- (void) setPos: (const dReal *) pos {
	m_x = pos[0];
	m_y = pos[1];
	m_z = pos[2];
}

// set ball rotation
- (void) setRot: (const dReal *) rot {
	for (int i = 0; i < 12; i++) {
		m_rot[i] = rot[i];
	}
}

// unused
- (void) setXSquish: (GLfloat) squish andShift: (GLfloat) shift {
	m_xSquish = squish;
	m_xShift = shift;
}

- (void) setYSquish: (GLfloat) squish andShift: (GLfloat) shift {
	m_ySquish = squish;
	m_yShift = shift;
}

- (void) setZSquish: (GLfloat) squish andShift: (GLfloat) shift {
	m_zSquish = squish;
	m_zShift = shift;
}
@end
