//
//  BallImagePickerController.h
//  AwesomeBall
//
//  Created by Brian Pratt on 3/7/09.
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
//  BallImagePickerController is a simple class to handle the UIPickerView for 
//  the different ball image types used for wrapping on the custom ball.
//  It provides the picker with the balls to choose from and handles actions, 
//  passing them back to the delegate.

#import <Foundation/Foundation.h>
#import "BallTypes.h"

@class BallImagePickerController;

@protocol BallImagePickerControllerDelegate
@required
- (void) setCustomBallImageAndSoundsToBallIndex:(unsigned) index;
@end


@interface BallImagePickerController : NSObject<UIPickerViewDelegate, UIPickerViewDataSource> {
	
	id<BallImagePickerControllerDelegate>	delegate;
	
	BallTypes	*ballTypes;
	
	NSInteger currentIndex;
	
}

@property (nonatomic, assign) NSInteger currentIndex;

// Accessor Methods
- (void) setDelegate:(id)aDelegate;

@end
