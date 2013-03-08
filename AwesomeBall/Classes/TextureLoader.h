//
//  TextureLoader.h
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

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/EAGL.h>

@interface TextureLoader : NSObject {

}

+ (void) initialize;
+ (GLuint) textureFromImageNamed: (NSString *) imageName;
+ (GLuint) textureFromImage: (CGImageRef) imageRef withName: (NSString *) textureName;
+ (void) releaseTextureWithName: (NSString *) textureName;
+ (void) releaseAll;
+ (void) releaseAllButTextureWithName: (NSString *) textureName;
+ (NSMutableDictionary *) getCurrentTexturesMap;

@end
