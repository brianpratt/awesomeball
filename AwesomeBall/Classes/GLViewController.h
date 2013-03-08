//
//  GLViewController.h
//  AwesomeBall
//
//  Created by Brian Pratt on 2/18/09.
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
//  GLViewController owns the OpenGL view. It handles the loading and unloading
//  of that view.

#import <UIKit/UIKit.h>
#import "GameType.h"

@class GLView;

@class GLViewController;

@protocol GLViewControllerDelegate
@required
-(void) toggleView;
@end


@interface GLViewController : UIViewController {
	
	id<GLViewControllerDelegate>	delegate;
	GLView							*glView;
    UIButton                        *settingsButton;
	id<GameType> m_gameType;
}

@property (nonatomic) GLView * glView;
@property (nonatomic) UIButton * settingsButton;
@property (nonatomic) id<GameType> m_gameType;

- (void) setDelegate:(id)newDelegate;
- (void) reloadGLView;

+ (GLViewController *) getSingleton;

@end
