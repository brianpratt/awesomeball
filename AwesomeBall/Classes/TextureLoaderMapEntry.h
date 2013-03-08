//
//  TextureLoaderMapEntry.h
//  AwesomeBall
//
//  Created by Jonathan Johnson on 4/13/09.
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

#import <Foundation/Foundation.h>

@class EAGLContext;

/**
 * This class exists because an NSMutableDictionary always makes a copy of a key when inserting an entry into a map.
 * This is not always desirable. In this case, we need a map from an EAGLContext to another NSMutableDictionary. Since
 * the EAGLContext class doesn't want to have its instances copied, we need another way. We'll use an NSMutableSet
 * instead of a map. Each entry in the set will be an instance of this class -- a mapping from a single EAGLContext
 * to an NSMutableDictionary. This class will *not* try to make a copy of the EAGLContext. Why does the Cocoa framework
 * let you put things in a set without copying them but not in a dictionary? Perhaps there is a more elegant way of
 * coding this?
 */
@interface TextureLoaderMapEntry : NSObject {
	// this is the key of the map entry
	EAGLContext * m_eaglContext;
	
	// this is the value of the map entry
	NSMutableDictionary * m_subDictionary;
}

- (id) initWithEAGLContext: (EAGLContext *) eaglContext andDictionary: (NSMutableDictionary *) subDictionary;

- (EAGLContext *) getEAGLContext;
- (NSMutableDictionary *) getDictionary;

@end
