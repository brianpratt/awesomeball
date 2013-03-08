//
//  TextureLoader.m
//  AwesomeBall
//
//  Created by Jonathan Johnson on 2/19/09.
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
//  TextureLoader handles the textures used in our two EAGLContexts.
//  Textures are cached and can be released all at once or individually.
//  The textures include those used on spheres and walls (and anything else).

#import "TextureLoader.h"
#import <OpenGLES/ES1/gl.h>
#import "TextureLoaderMapEntry.h"

static NSMutableSet * glContextToTextures;

@implementation TextureLoader

+ (void) initialize {
	// This initializes a map (dictionary) that holds the texture cache information.
	// In Java notation, glContextToTextures is like a Map<EAGLContext, Map<String, Integer>>
	// except that the top level map is implemented as a set of TextureLoaderMapEntry objects
	// because of a limitation with the NSMutableDictionary class.
	//
	// There will only ever be two entries in the top level map, one for each OpenGL context (EAGLContext)
	// The submap inside is a map from texture name to texture number for textures that are currently loaded.
	glContextToTextures = [[NSMutableSet alloc] init];
}

// Load a texture from the image with the given name (it is assumed that the image file ends in .png -- this is
// added by the method) and return the OpenGL texture number -- this number is valid until the texture is released
+ (GLuint) textureFromImageNamed: (NSString *) imageName {
	NSBundle * mainBundle = [NSBundle mainBundle];
	UIImage * uiImage = [[UIImage alloc] initWithContentsOfFile: [mainBundle pathForResource:imageName ofType: @"png"]];
	CGImageRef cgImage = uiImage.CGImage;
	
	GLuint result = [TextureLoader textureFromImage: cgImage withName: imageName];
	return result;
}

// Load a texture from the given imageRef and give it textureName as a name to reference it by in the texture caching
// map
+ (GLuint) textureFromImage: (CGImageRef) imageRef withName: (NSString *) textureName
{
	// get the part of the texture cache for the current OpenGL context
	NSMutableDictionary * textures = [TextureLoader getCurrentTexturesMap];
	// if the texture is already loaded (cached), return its number
	NSNumber * textureNum = [textures objectForKey: textureName];
	if (textureNum) {
		return [textureNum unsignedIntValue];
	}
	
	// draw the image onto a core graphics context to get an image data pointer to pass to OpenGL
	// for where to load the texture from
	GLuint mainTexture[1];
	GLsizei width = CGImageGetWidth(imageRef);
	GLsizei height = CGImageGetHeight(imageRef);
	GLubyte * data = malloc(width * 4 * height);
	CGContextRef context = CGBitmapContextCreate(data, width, height, 8, 4 * width, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
	
	// core graphics draws things upside down unless you transform correctly
	CGContextTranslateCTM(context, 0, height);
	CGContextScaleCTM(context, 1, -1);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
	CGContextRelease(context);
	
	glGenTextures(1, mainTexture);
	glBindTexture(GL_TEXTURE_2D, mainTexture[0]);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	// now that OpenGL has the texture, release the memory we allocated for the core graphics context
	free(data);
	
	// put the texture number in the cache
	[textures setObject: [NSNumber numberWithUnsignedInt: mainTexture[0]] forKey: textureName];
	//NSLog(@"loaded texture %@ with num %d in context %x", textureName, mainTexture[0], [EAGLContext currentContext]);
	return mainTexture[0];
}

// Release the texture in the current OpenGL context with the given name (if there is one loaded with that name)
+ (void) releaseTextureWithName: (NSString *) textureName {
	NSMutableDictionary * textures = [TextureLoader getCurrentTexturesMap];
	NSNumber * textureNum = [textures objectForKey: textureName];
	if (textureNum == nil)
		return; // Texture by that name not found. Fail silently.
	GLuint texture[1];
	texture[0] = [textureNum unsignedIntValue];
	glDeleteTextures(1, texture);
	
	[textures removeObjectForKey: textureName];
	//NSLog(@"released texture %@ with num %@ in context %x", textureName, textureNum, [EAGLContext currentContext]);
}

// Release all of the textures loaded in the *current context only*
+ (void) releaseAll {
	[self releaseAllButTextureWithName: @""];
}

// Release all of the textures in the *current context only* except the texture with the given name
+ (void) releaseAllButTextureWithName: (NSString *) textureName {
	NSMutableDictionary * textures = [TextureLoader getCurrentTexturesMap];
	NSEnumerator * keyEnum = [textures keyEnumerator];
	NSString * key;
	NSUInteger count = 0;//[textures count];
	NSMutableArray * toRemove = [[NSMutableArray alloc] initWithCapacity: count];
	while (key = (NSString *) [keyEnum nextObject]) {
		if (key != textureName) { // Skip the one named texture
			[toRemove addObject: key];
			count++;
		}
	}
	for (int i = 0; i < count; i++) {
		[TextureLoader releaseTextureWithName: [toRemove objectAtIndex: i]];
	}
	
}

// Return the part of the textures cache that corresponds to the currently active OpenGL context (EAGLContext)
+ (NSMutableDictionary *) getCurrentTexturesMap {
	EAGLContext * currentContext = [EAGLContext currentContext];
	TextureLoaderMapEntry * mapEntry = [glContextToTextures member: currentContext];
	NSMutableDictionary * textures = nil;
	if (mapEntry != nil)
		textures = [mapEntry getDictionary];
	else {
		textures = [[NSMutableDictionary alloc] init];
		mapEntry = [[TextureLoaderMapEntry alloc] initWithEAGLContext: currentContext andDictionary: textures];
		[glContextToTextures addObject: mapEntry];
	}
	return textures;
}

@end
