//
//  GLWall.m
//  AwesomeBall
//
//  Created by Jonathan Johnson on 2/21/09.
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
//  GLWall simply implements an OpenGL rectangle and handles the settings for 
//  the apperance of the rectangle.

#import "GLWall.h"


@implementation GLWall

@synthesize m_textureID;

- (id) initWithVertices: (GLfloat * ) vertices andTexCoords: (GLfloat *) texCoords {
	
	[self setVertices:vertices andTexCoords:texCoords andTexID:0];
	
	return self;
}

- (id) initWithVertices: (GLfloat * ) vertices andTexCoords: (GLfloat *) texCoords andTexID: (GLuint) textureID {
	
	[self setVertices:vertices andTexCoords:texCoords andTexID:textureID];
	
	return self;
}

- (void) setVertices: (GLfloat * ) vertices {
	for (int i = 0; i < 12; i++) {
		m_vertices[i] = vertices[i];
	}
}

- (void) setVertices: (GLfloat * ) vertices andTexCoords: (GLfloat *) texCoords andTexID: (GLuint) textureID {
	
	[self setVertices:vertices];
	
	for (int i = 0; i < 8; i++) {
		m_texCoords[i] = texCoords[i];
	}
	m_textureID = textureID;
}

- (void) draw {	
	// Special case: invisible wall
	if (m_textureID == -1)
		return;
	
	glVertexPointer(3, GL_FLOAT, 0, m_vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glBindTexture(GL_TEXTURE_2D, m_textureID);
	glTexCoordPointer(2, GL_FLOAT, 0, m_texCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	glColor4f(1, 1, 1, 1);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
