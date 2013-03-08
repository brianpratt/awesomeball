//
//  ImageManipulation.m
//  AwesomeBall
//
//  Created by Brian Pratt on 6/27/09.
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
//  Contains helper methods for cropping, resizing, and duplicating images for use on walls and balls
//

#import "ImageManipulation.h"


@implementation ImageManipulation


+ (UIImage*) imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	// Create a new image by cropping the passed-in image to the size specified by the 
	// passed-in CGRect
	
	//create a context to do our clipping in
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(currentContext, 0, rect.size.height);
	CGContextScaleCTM(currentContext, 1, -1);
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClipToRect( currentContext, clippedRect);
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
								 rect.origin.y * -1,
								 imageToCrop.size.width,
								 imageToCrop.size.height);
	
	//draw the image to our clipped context using our offset rect
	CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

+ (UIImage*) resizeImage:(UIImage*) inImage toRect:(CGRect) newImageRect {
	// Create a new image by resizing the passed-in image to the size of the
	// passed-in CGRect
	
	CGImageRef			imageRef = [inImage CGImage];
	CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
	
	// There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
	// see Supported Pixel Formats in the Quartz 2D Programming Guide
	// Creating a Bitmap Graphics Context section
	// only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
	// and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
	// The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	// Build a bitmap context that's the size of the thumbRect
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												newImageRect.size.width,		// width
												newImageRect.size.height,		// height
												CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
												4 * newImageRect.size.width,	// rowbytes
												CGImageGetColorSpace(imageRef),
												alphaInfo
												);
	//CGContextTranslateCTM(bitmap, 0, newImageRect.size.height);
	//CGContextScaleCTM(bitmap, 1, -1);
	
	// Ask for a high quality interpolation
	CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
	
	// Draw into the context, this scales the image
	CGContextDrawImage(bitmap, newImageRect, imageRef);
	
	// Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage*	result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
	
	return result;
}

+ (UIImage*) doubleImage:(UIImage*) inImage {
	// Create a new image by duplicating the passed-in image and placing the duplicates
	// side-by-side. Thus the new image is twice the width of the original.
	
	unsigned			inWidth = inImage.size.width;
	unsigned			inHeight = inImage.size.height;
	CGImageRef			imageRef = [inImage CGImage];
	CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGRect				newImageRectLeft = CGRectMake(0.0, 0.0, inWidth, inHeight);
	CGRect				newImageRectRight = CGRectMake(inWidth, 0.0, inWidth, inHeight);
	
	// There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
	// see Supported Pixel Formats in the Quartz 2D Programming Guide
	// Creating a Bitmap Graphics Context section
	// only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
	// and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
	// The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	// Build a bitmap context that's the size of the thumbRect
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												inWidth*2,		// width
												inHeight,		// height
												CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
												4 * inWidth*2,	// rowbytes
												CGImageGetColorSpace(imageRef),
												alphaInfo
												);
	
	// Ask for a high quality interpolation
	CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
	
	// Draw into the context, this scales the image
	CGContextDrawImage(bitmap, newImageRectLeft, imageRef);
	CGContextDrawImage(bitmap, newImageRectRight, imageRef);
	CGContextTranslateCTM(bitmap, 0, inHeight);
	CGContextScaleCTM(bitmap, 1, -1);
	
	// Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage*	result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
	
	return result;
}


@end
