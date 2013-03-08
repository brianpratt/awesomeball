//
//  GLWalls.m
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

#import "GLWalls.h"
#import "GLWall.h"
#import "TextureLoader.h"
#import "UserDefaults.h"

@implementation GLWalls

@synthesize shortWallImageName;
@synthesize longWallImageName;
@synthesize floorImageName;


static NSString *customShortWallName = @"customShortWall";
static NSString *customLongWallName = @"customLongWall";
static NSString *customFloorName = @"customFloor";


- (id) initWithLeft: (GLfloat) left Right: (GLfloat) right Top: (GLfloat) top Bottom: (GLfloat) bottom andHeight: (GLfloat) height {

	GLfloat leftVertices[12] = {left, bottom, 0, left, bottom, -height, left, top, 0, left, top, -height};
	GLfloat topVertices[12] = {left, top, 0, left, top, -height, right, top, 0, right, top, -height};
	GLfloat rightVertices[12] = {right, top, 0, right, top, -height, right, bottom, 0, right, bottom, -height};
	GLfloat bottomVertices[12] = {right, bottom, 0, right, bottom, -height, left, bottom, 0, left, bottom, -height};
	GLfloat floorVertices[12] = {left, top, -height, left, bottom, -height, right, top, -height, right, bottom, -height};
	
	GLfloat texCoords[8] = {0, 1,  0, 0,  1, 1,  1, 0};
	
	// Create walls without a texture
	m_topWall = [[GLWall alloc] initWithVertices: topVertices andTexCoords: texCoords andTexID: 0];
	m_bottomWall = [[GLWall alloc] initWithVertices: bottomVertices andTexCoords: texCoords andTexID: 0];
	m_leftWall = [[GLWall alloc] initWithVertices: leftVertices andTexCoords: texCoords andTexID: 0];
	m_rightWall = [[GLWall alloc] initWithVertices: rightVertices andTexCoords: texCoords andTexID: 0];
	m_floor = [[GLWall alloc] initWithVertices: floorVertices andTexCoords: texCoords andTexID: 0];
	
	// Load wall images, possibly saved images from the disk
	[self loadWallImages];
	
	
	return self;
}

- (void) loadImagesForWalls: (BOOL) loadWallImages andFloor: (BOOL) loadFloorImage {
	
	if (loadWallImages) {
		// Load custom images from a file if they exist
		UIImage * customShortWallImage = [UserDefaults customShortWallImage];
		UIImage * customLongWallImage = [UserDefaults customLongWallImage];
		
		// Set up custom walls
		if (customShortWallImage != nil && customLongWallImage != nil) {
			[self setCustomWallImagesToShort:customShortWallImage andLong:customLongWallImage];
		}
		else
			// Not using custom wall images. Load the default images.
			[self resetWallImages: NO];
	}
	
	if (loadFloorImage) {
		// Load custom images from a file if they exist
		UIImage * customFloorImage = [UserDefaults customFloorImage];
		
		if (customFloorImage != nil) {
			[self setCustomFloorImage:customFloorImage];
		}
		else
			// Not using custom floor image. Load the default image.
			[self resetFloorImage: NO];
	}
	
}

- (void) loadWallImages {
	// Load walls and floors
	[self loadImagesForWalls: YES andFloor: YES];
	
}

- (void) releaseUnusedTextures:(NSString*)newShortWallImageName andLongWallsNamed:(NSString*)newLongWallImageName andFloorNamed:(NSString*)newFloorImageName {
	// Releases the images whose names are saved with the object
	// Sets the passed-in strings as the new saved image names
	if (newShortWallImageName) {
		[TextureLoader releaseTextureWithName: self.shortWallImageName];
		self.shortWallImageName = newShortWallImageName;
	}
	if (newLongWallImageName) {
		[TextureLoader releaseTextureWithName: self.longWallImageName];
		self.longWallImageName = newLongWallImageName;
	}
	if (newFloorImageName) {
		[TextureLoader releaseTextureWithName: self.floorImageName];
		self.floorImageName = newFloorImageName;
	}
}

- (void) setImagesForWallsNamed:(NSString*)newWallImageName andFloorNamed:(NSString*)newFloorImageName {
	
	// Release old textures
	[self releaseUnusedTextures:newWallImageName andLongWallsNamed:newWallImageName andFloorNamed:newFloorImageName];
	
	// Load new textures
	GLuint wallTexture = [TextureLoader textureFromImageNamed: newWallImageName];
	GLuint floorTexture = [TextureLoader textureFromImageNamed: newFloorImageName];
	
	m_leftWall.m_textureID = wallTexture;
	m_topWall.m_textureID = wallTexture;
	m_rightWall.m_textureID = wallTexture;
	m_bottomWall.m_textureID = wallTexture;
	
	m_floor.m_textureID = floorTexture;
}

- (void) setImagesForsShortWallsNamed:(NSString*)newShortWallImageName andLongWallsNamed:(NSString*)newLongWallImageName andFloorNamed:(NSString*)newFloorImageName {
	
	// Release old textures
	[self releaseUnusedTextures:newShortWallImageName andLongWallsNamed:newLongWallImageName andFloorNamed:newFloorImageName];
	
	// Load new textures
	GLuint shortWallTexture = [TextureLoader textureFromImageNamed: newShortWallImageName];
	GLuint longWallTexture = [TextureLoader textureFromImageNamed: newLongWallImageName];
	GLuint floorTexture = [TextureLoader textureFromImageNamed: newFloorImageName];
	
	m_topWall.m_textureID = shortWallTexture;
	m_bottomWall.m_textureID = shortWallTexture;
	m_leftWall.m_textureID = longWallTexture;
	m_rightWall.m_textureID = longWallTexture;
	
	m_floor.m_textureID = floorTexture;
}

- (void) setCustomWallImagesToShort:(UIImage*)shortWallImage andLong:(UIImage*)longWallImage {
	
	// Release old textures
	[self releaseUnusedTextures:customShortWallName andLongWallsNamed:customLongWallName andFloorNamed:nil];
	
	// Release any old custom texture
	[TextureLoader releaseTextureWithName:customShortWallName];
	[TextureLoader releaseTextureWithName:customLongWallName];
	
	// Create a new one
	CGImageRef cgImage = shortWallImage.CGImage;
	GLuint wallTexture = [TextureLoader textureFromImage: cgImage withName: customShortWallName];
	m_topWall.m_textureID = wallTexture;
	m_bottomWall.m_textureID = wallTexture;
	
	// Create a new one
	cgImage = longWallImage.CGImage;
	wallTexture = [TextureLoader textureFromImage: cgImage withName: customLongWallName];
	m_leftWall.m_textureID = wallTexture;
	m_rightWall.m_textureID = wallTexture;
}

- (void) setCustomFloorImage:(UIImage*)floorImage {
	
	// Release old texture
	[self releaseUnusedTextures:nil andLongWallsNamed:nil andFloorNamed:customFloorName];
	
	// Release any old custom textures
	[TextureLoader releaseTextureWithName:customFloorName];
	
	// Create new ones
	CGImageRef cgImage = floorImage.CGImage;
	GLuint floorTexture = [TextureLoader textureFromImage: cgImage withName: customFloorName];
	
	m_floor.m_textureID = floorTexture;
}

- (void) resetWallImages: (BOOL) removeCustomImages {
	[self releaseUnusedTextures:@"wood_floor_rot" andLongWallsNamed:@"wood_floor_rot" andFloorNamed:nil];
	
	if (removeCustomImages) {
		[UserDefaults removeCustomShortWallImage];
		[UserDefaults removeCustomLongWallImage];
	}
	
	GLuint shortWallTexture = [TextureLoader textureFromImageNamed: self.shortWallImageName];
	GLuint longWallTexture = [TextureLoader textureFromImageNamed: self.longWallImageName];
	
	m_topWall.m_textureID = shortWallTexture;
	m_bottomWall.m_textureID = shortWallTexture;
	m_leftWall.m_textureID = longWallTexture;
	m_rightWall.m_textureID = longWallTexture;
	
}

- (void) resetWallImages {
	[self resetWallImages: YES];
}

- (void) resetFloorImage: (BOOL) removeCustomImage {
	[self releaseUnusedTextures:nil andLongWallsNamed:nil andFloorNamed:@"wood_floor"];
	
	if (removeCustomImage)
		[UserDefaults removeCustomFloorImage];
	
	GLuint floorTexture = [TextureLoader textureFromImageNamed: self.floorImageName];
	m_floor.m_textureID = floorTexture;
}

- (void) resetFloorImage {
	[self resetFloorImage: YES];
}


- (void) makeWallsInvisible {
	[self setImagesForsShortWallsNamed:@"invisible" andLongWallsNamed:@"invisible" andFloorNamed:@"invisible"];
}


- (void) draw {
	if (![shortWallImageName isEqual: @"invisible"]) {
		[m_topWall draw];
		[m_bottomWall draw];
	}
	if (![longWallImageName isEqual: @"invisible"]) {
		[m_leftWall draw];
		[m_rightWall draw];
	}
	if (![floorImageName	isEqual: @"invisible"])
		[m_floor draw];
}


@end
