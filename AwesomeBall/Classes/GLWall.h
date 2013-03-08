//
//  GLWall.h
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

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

@interface GLWall : NSObject {
	// the four vertices for the rectangle specified as x,y,z, x,y,z, x,y,z, x,y,z
	GLfloat m_vertices[12];
	
	// texture coordinates corresponding to the vertices specified as u,v, u,v, u,v, u,v
	GLfloat m_texCoords[8];
	
	// OpenGL texture number for the wall
	GLuint m_textureID;
}

@property (readwrite) GLuint m_textureID;

- (id) initWithVertices: (GLfloat * ) vertices andTexCoords: (GLfloat *) texCoords andTexID: (GLuint) textureID;
- (void) setVertices: (GLfloat * ) vertices;
- (void) setVertices: (GLfloat * ) vertices andTexCoords: (GLfloat *) texCoords andTexID: (GLuint) textureID;
- (void) draw;

@end
