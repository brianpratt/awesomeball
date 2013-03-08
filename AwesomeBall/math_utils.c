/*
 *  math_utils.c
 *  AwesomeBall
 *
 *  Created by Jonathan Johnson on 3/6/09.
 *  Copyright 2009-2013 Jonathan Johnson and Brian Pratt. All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 *  - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
 *    in the documentation and/or other materials provided with the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
 *  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 *  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 *  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include "math_utils.h"

/**
 * Vector c is unrotated by the rotation from a to b
 *
 * This function is used for knowing what forces to apply to the ball based on input from the accelerometer.
 * Conceptually, the accelerometer values can be split into two components -- forces due to gravity alone and forces due
 * to the user shaking the iPhone around. We separate these two components (approximately) using a low-pass filter. The
 * component due to gravity is applied directly to the ball as a force. The other component should be applied to the
 * box. Since we don't actually move the box in our implementation, we apply the opposite force to the ball. But first
 * we have to "unrotate" the force based on the current orientation of the iPhone (which we know from the gravity
 * component). This function does the unrotating.
 *
 * a is compared to b and the difference in rotation is applied to c to get result.
 * Typically a is the gravity component, b is a reference unit vector pointing straight downward (like gravity), and
 * c is the component due to shaking the iPhone.
 */
void unrotateVectorByVector(dVector3 a, dVector3 b, dVector3 c, dVector3 result) {
	
	// normalize the vectors
	dVector3 d;
	dVector3 e;
	d[0] = a[0]; d[1] = a[1]; d[2] = a[2];
	e[0] = b[0]; e[1] = b[1]; e[2] = b[2];
	if (d[0] != 0 || d[1] != 0 || d[2] != 0)
		dNormalize3(d);
	if (e[0] != 0 || e[1] != 0 || e[2] != 0)
		dNormalize3(e);
	
	// compute the cross product (from b to a since this is a "derotation"); this is the vector to rotate about
	dVector3 cross;
	cross[0] = e[1]*d[2] - e[2]*d[1];
	cross[1] = -e[0]*d[2] + e[2]*d[0];
	cross[2] = e[0]*d[1] - e[1]*d[0];

	if (cross[0] == 0 && cross[1] == 0 && cross[2] == 0) {
		cross[0] = 1;
	}
	// next compute the dot product -- this tells us how far to rotate
	dReal dot = dDOT(e, d);
	dReal theta = acos(dot);
	
	dMatrix3 dR;
	dRFromAxisAndAngle(dR, cross[0], cross[1], cross[2], theta);
	
	result[0] = dR[0]*c[0] + dR[1]*c[1] + dR[2]*c[2];
	result[1] = dR[4]*c[0] + dR[5]*c[1] + dR[6]*c[2];
	result[2] = dR[8]*c[0] + dR[9]*c[1] + dR[10]*c[2];
}