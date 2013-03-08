//
//  BasicGame.m
//  AwesomeBall
//
//  Created by Brian Pratt on 4/16/09.
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
//  BasicGame is the most basic game type: one ball in a box
//  BasicGame includes handling for the accelerometer, pinch zooming, and swipe spinning

#import "BasicGame.h"
#import "GLView.h"
#import "ode.h"
#import "UserDefaults.h"
#import "GLBall.h"
#import "glUtil.h"
#import "SoundEffect.h"
#import "GLWalls.h"
#import "TextureLoader.h"
#import "BallTypes.h"
#import "math_utils.h"
#import "UserDefaults.h"


#define LEFT_LIMIT -5
#define RIGHT_LIMIT 25
#define TOP_LIMIT 10
#define BOTTOM_LIMIT -35
#define HEIGHT 30
#define WIDTH 30
#define LENGTH 45

#define CAMERA_ALPHA .8

#define MAX_DEPTH 100

#define GLOBAL_CFM .2

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / M_PI * 180.0)


#define kMinSpeedToCalculate 0.1
#define kMaxAngleForDirectBounceSound DEGREES_TO_RADIANS(180.0)
#define kMinAngleForDirectBounceSound DEGREES_TO_RADIANS(135.0)
#define kMaxAngleForDeflectBounceSound DEGREES_TO_RADIANS(135.0)
#define kMinAngleForDeflectBounceSound DEGREES_TO_RADIANS(110.0)

// Enum for sound volumes
typedef enum kSoundVolumeEnum {
	kSoundVolumeFull = 3,
	kSoundVolume75   = 2,
	kSoundVolume50   = 1,
	kSoundVolume25   = 0,
} kSoundVolume;

#define kMinSpeedForFullSound 25.0
#define kMinSpeedFor75Sound  12.5
#define kMinSpeedFor50Sound  2.5
#define kMinSpeedFor25Sound  0.5

// Constant for the accelerometer low-pass/high-pass filter.
#define kFilteringFactor 0.55 // Quicker response
//#define kFilteringFactor 0.04 // Middle ground?
//#define kFilteringFactor 0.01 // Better filtering
#define kForceScalingFactor 5.5
#define kGravityScalingFactor 9.1357 // To convert 1.08 into 9.8 
#define MAX_CONTACTS 20

#define PI 3.14159265358979323846

// Enum for walls
typedef enum kWalIDEnum {
	kWalIDNorth,
	kWalIDSouth,
	kWalIDEast,
	kWalIDWest,
	kWalIDFloor,
	kWalIDCeiling
} kWallID;

// This is an array of contacts that are created when objects collide
static dContact contact_array[MAX_CONTACTS];

static BasicGame * singleton;

// A class extension to declare private methods and variables
@interface BasicGame ()

- (void) resetZoomDistance;
- (void) applyTorque;

@end


@implementation BasicGame

@synthesize m_walls;
@synthesize movedX;
@synthesize movedY;
@synthesize movedZ;


- (id) initWithGLView: (GLView *) view {
	glView = view;
	movedX = movedY = movedZ = 0;
	touchesBeganButNotEnded = NO;
	
	m_ballRadius = 2;
	m_ballArea = PI * m_ballRadius * m_ballRadius;
	m_ball = [[GLBall alloc] initWithX: 0.0 Y: 0.0 Z: 0.0 andScale: m_ballRadius];
	m_ballBounce = 0.92;
	
	// Initialize physics engine
	dInitODE2(0);
	
	// Create physics world
	m_world = dWorldCreate();
	
	// Set physics 'constraint force mixing' parameter -- see ODE manual for details
	dWorldSetCFM(m_world, GLOBAL_CFM);
	
	// Create the ball in the ODE world
	m_ballID = dBodyCreate(m_world);
	dMass ballMass;
	dMassSetSphereTotal(&ballMass, 1.0, m_ballRadius);
	dBodySetMass(m_ballID, &ballMass);
	dBodySetPosition(m_ballID, 0, 0, -2*m_ballRadius);
	
	dWorldSetGravity(m_world, 0, 0, 0);
	
	m_accX = m_accY = m_accZ = 0;
	m_accX_lp = m_accY_lp = m_accZ_lp = 0;
	m_accX_hp = m_accY_hp = m_accZ_hp = 0;
	
	cameraFollowsBall = YES;
	m_cameraX = 0;
	m_cameraY = 0;
	m_cameraZ = 10;
	m_cameraX_offset = 0;
	m_cameraY_offset = 0;
	m_cameraZ_zoom = 0;
	
	m_contactGroup = dJointGroupCreate(MAX_CONTACTS);
	
	// The ODE space we are working with
	m_space = dSimpleSpaceCreate(NULL);
	
	// Create a sphere in the ODE space
	m_ballGeom = dCreateSphere(m_space, m_ballRadius);
	dGeomSetBody(m_ballGeom, m_ballID);
	
	// Create the box in the ODE space
	// Create the planes that bound the box
	// These are what the ball will actually collide with
	m_wallGeoms[kWalIDNorth] = dCreatePlane(m_space, 0, -1, 0, -TOP_LIMIT); // top wall
	m_wallGeoms[kWalIDSouth] = dCreatePlane(m_space, 0, 1, 0, BOTTOM_LIMIT); // bottom wall
	m_wallGeoms[kWalIDEast] = dCreatePlane(m_space, -1, 0, 0, -RIGHT_LIMIT); // right wall
	m_wallGeoms[kWalIDWest] = dCreatePlane(m_space, 1, 0, 0, LEFT_LIMIT); // left wall
	m_wallGeoms[kWalIDFloor] = dCreatePlane(m_space, 0, 0, 1, -HEIGHT); // floor
	m_wallGeoms[kWalIDCeiling] = dCreatePlane(m_space, 0, 0, -1, 0); // ceiling
	
	m_walls = [[GLWalls alloc] initWithLeft: LEFT_LIMIT Right: RIGHT_LIMIT Top: TOP_LIMIT Bottom: BOTTOM_LIMIT andHeight: HEIGHT];
	
	// Setup a pre-chosen ball
	ballTypes = [BallTypes singleton];
	// Load same ball type as last session
	[self setBallTypeIndex: [UserDefaults ballIndex]];
	
	// Set up accelerometer
	UIAccelerometer * acc = [UIAccelerometer sharedAccelerometer];
	acc.updateInterval = 1.0/20.0;
	acc.delegate = self;
	
	
	singleton = self;
	return self;
}

- (void) setGLView: (GLView *) view {
	glView = view;
}

- (void) viewWillAppear:(BOOL)animated {
	// Coming back to GLView from SettingsView
	//[super viewWillAppear:animated];
}



#pragma mark ----- Game Methods -----

- (void) setupGLView: (CGRect) rect {

	const GLfloat			lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			matAmbient[] = {0.6, 0.6, 0.6, 1.0};
	const GLfloat			matDiffuse[] = {1.0, 1.0, 1.0, 1.0};	
	const GLfloat			matSpecular[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			lightPosition[] = {0.0, 0.0, 1.0, 0.0}; 
	const GLfloat			lightShininess = 100.0;
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition); 			
	glShadeModel(GL_SMOOTH);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_COLOR_MATERIAL);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	
	if ([UserDefaults enableHiResGraphics]) {
		// Retina Display support
		// Scale the viewport by 2.0 for 2.0-scaled devices
		UIScreen *mainScreen = [UIScreen mainScreen];
		if ([mainScreen respondsToSelector:@selector(scale)] && [mainScreen scale] == 2.0) {
			gluPerspective(45, rect.size.width / rect.size.height, .1, MAX_DEPTH);
			glViewport(0, 0, rect.size.width*2, rect.size.height*2);
		}
		else {
			gluPerspective(45, rect.size.width / rect.size.height, .1, MAX_DEPTH);
			glViewport(0, 0, rect.size.width, rect.size.height);
		}
	}
	else {
		gluPerspective(45, rect.size.width / rect.size.height, .1, MAX_DEPTH);
		glViewport(0, 0, rect.size.width, rect.size.height);
	}

	
	glMatrixMode(GL_MODELVIEW);
}

static void nearCallback(void * data, dGeomID o1, dGeomID o2) {
	[singleton callBack: data id1: o1 id2: o2];
}

- (void) applyAerodynamicDragForce {

	//////////////
	// Aerodynamic Drag (force)
	// A force in the opposite direction of the velocity
	//   F_drag = -(1/2)*p*|V|^2*C_D*A * V/|V|
	//     A is the front-projected area of the ball (Cross-section area of bounding sphere)
	//     p is the mass-density of the fluid
	//     C_D is the drag co-efficient ([0..1], no units). Typical values from 0.1 (streamlined) to 0.4 (not streamlined)
	// Get velocity of ball
	const dReal *vel = dBodyGetLinearVel(m_ballID);
	// Get magnitude of the velocity (speed)
	float speed = dLENGTH(vel);
	// Get unit vector of the velocity (direction)
	dVector3 u_vel;
	u_vel[0] = vel[0]; u_vel[1] = vel[1]; u_vel[2] = vel[2];
	if (u_vel[0] != 0 || u_vel[1] != 0 || u_vel[2] != 0)
		dNormalize3(u_vel);
	// Set other parameters
	const float area_fudge_factor = 2;
	float A = m_ballArea * 0.0016 * area_fudge_factor; // B/c we multiply the size of each ball radius by 25 to display it big enough
	const float p = 1.29; // kg / m^3 (Air at sea level and 20 °C = 1.29, Water - 1000.0)
	const float C_D = 0.2; // Fairly streamlined, since we are always working with spheres (so far)
	const float fudge_factor = 0.1; // To get the feel right
	// Calcluate the drag force magnitude
	float F_drag_mag = -0.5 * p * speed * speed * C_D * A * fudge_factor;
	// Don't let the drag force push back harder than the ball is pushing (don't know why this doesn't happen automatically...)
	//  Get the force of the ball in the direction of the velocity vector
	const dReal *force = dBodyGetForce(m_ballID);
	float rForce = fabs(dDOT(force, vel)); // Relative force
	if (F_drag_mag < -rForce) {
		//NSLog(@"Terminal velocity!");
		F_drag_mag = -rForce;
	}
	// Compute the drag vector
	dVector3 F_drag;
	F_drag[0] = u_vel[0]*F_drag_mag;
	F_drag[1] = u_vel[1]*F_drag_mag;
	F_drag[2] = u_vel[2]*F_drag_mag;
	// Apply the force
	//NSLog(@"Ball Velocity: x=%f, y=%f, z=%f", vel[0], vel[1], vel[2]);
	//NSLog(@"Speed: %f", speed);
	//NSLog(@"Drag magnitude: %f", F_drag_mag);
	//NSLog(@"Drag Force: x=%f, y=%f, z=%f", F_drag[0], F_drag[1], F_drag[2]);
	dBodyAddForce(m_ballID, F_drag[0], F_drag[1], F_drag[2]);
	
}

- (void) physicsTimeStep {
	// Force = mass*acceleration so account for the ball mass when applying gravity
	
	//////////////
	// Gravity
	dBodyAddForce(m_ballID, m_accX_lp*m_ballMass, m_accY_lp*m_ballMass, m_accZ_lp*m_ballMass);
	
	
	//////////////
	// Shaking force
	dVector3 a = {m_accX_lp, m_accY_lp, m_accZ_lp};
	dVector3 b = {0, 0, -1};
	dVector3 c = {m_accX_hp, m_accY_hp, m_accZ_hp};
	dVector3 result;
	unrotateVectorByVector(a, b, c, result);
	
	dBodyAddForce(m_ballID, -result[0]*kForceScalingFactor*m_ballMass, -result[1]*kForceScalingFactor*m_ballMass, -result[2]*kForceScalingFactor*m_ballMass);

	
	//////////////
	// Aerodynamic Drag (force)
	// A force in the opposite direction of the velocity
	// Only apply if it matters to this particular ball
	// Disable this feature for now
	//if ([ballTypes useAirResistanceForBallAtIndex:[UserDefaults ballIndex]])
		[self applyAerodynamicDragForce];
	
	
	//////////////
	// Finish up
	dSpaceCollide(m_space, NULL, &nearCallback);
	dWorldStep(m_world, .15);
	dJointGroupEmpty(m_contactGroup);	
}

- (void) drawGameView {
	const dReal * pos = dBodyGetPosition(m_ballID);
	const dReal * rot = dBodyGetRotation(m_ballID);
	//NSLog(@"x = %f, y = %f, z = %f", pos[0], pos[1], pos[2]);
	
	// Change height of camera relative to box
	GLfloat m_cameraZ_height_above_box;
	m_cameraZ_zoom = m_cameraZ_zoom + movedZ/5;
	
	static int stdHeightFollowBall = 12.0;
	static int stdHeightNoFollowBall = 53.0;
	
    // Update camera
	if (cameraFollowsBall) {
		// Camera follows the ball
		m_cameraX = (CAMERA_ALPHA * m_cameraX) + ((1-CAMERA_ALPHA) * pos[0]);
		m_cameraY = (CAMERA_ALPHA * m_cameraY) + ((1-CAMERA_ALPHA) * pos[1]);
		// Camera follows box in height
		m_cameraZ_height_above_box = m_cameraZ_zoom + stdHeightFollowBall;
	}
	else {
		// Camera does not follow ball
		// Camera does follow the box
		m_cameraX = (LEFT_LIMIT+RIGHT_LIMIT)/2 - m_cameraX_offset;
		m_cameraY = (TOP_LIMIT+BOTTOM_LIMIT)/2 - m_cameraY_offset;
		// Camera follows box in height
		m_cameraZ_height_above_box = m_cameraZ_zoom + stdHeightNoFollowBall;
	}
	// Don't let the camera zoom out too much (so the floor doesn't disappear)
	float maxZoomIn = -HEIGHT + m_ballRadius*2 + 1;
	float maxZoomOut = MAX_DEPTH - HEIGHT;
	if (m_cameraZ_height_above_box > maxZoomOut) {
		// Reset zoom position
		m_cameraZ_height_above_box = maxZoomOut;
		if (cameraFollowsBall) m_cameraZ_zoom = m_cameraZ_height_above_box - stdHeightFollowBall;
		else m_cameraZ_zoom = m_cameraZ_height_above_box - stdHeightNoFollowBall;
	}
	else if (m_cameraZ_height_above_box < maxZoomIn) {
		// Reset zoom position
		m_cameraZ_height_above_box = maxZoomIn;
		if (cameraFollowsBall) m_cameraZ_zoom = m_cameraZ_height_above_box - stdHeightFollowBall;
		else m_cameraZ_zoom = m_cameraZ_height_above_box - stdHeightNoFollowBall;
	}
	m_cameraZ = /*boxPos[2]*/ + m_cameraZ_height_above_box;
	
	
	glTranslatef(-m_cameraX, -m_cameraY, -m_cameraZ);
	movedX = movedY = movedZ = 0;
	
	
	[m_ball setPos: pos];
	[m_ball setRot: rot];
	
	[m_walls draw];
	[m_ball draw];
	
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// Raw accelerometer values
	m_accX = acceleration.x * kGravityScalingFactor;
	m_accY = acceleration.y * kGravityScalingFactor;
	m_accZ = acceleration.z * kGravityScalingFactor;
	
	// Apply a basic high-pass filter to remove the gravity influence from the accelerometer values.
	// Keep the low-pass filter values as well.
	//
	// This approximately separates the accelerometer into "gravity" (from low-pass filter) and forces from the user
	// jerking the iPhone around (from high-pass filter). Gravity forces are applied to the ball. The other
	// component gets unrotated by the direction of the gravity force vector and then negated and applied to
	// the ball in order to simulate the effects of the box smacking the ball when the user jerks the iPhone
	
	m_accX_lp = m_accX * kFilteringFactor + m_accX_lp * (1.0 - kFilteringFactor);
	m_accX_hp = m_accX - m_accX_lp;
	m_accY_lp = m_accY * kFilteringFactor + m_accY_lp * (1.0 - kFilteringFactor);
	m_accY_hp = m_accY - m_accY_lp;
	m_accZ_lp = m_accZ * kFilteringFactor + m_accZ_lp * (1.0 - kFilteringFactor);
	m_accZ_hp = m_accZ - m_accZ_lp;
}

- (void) setCameraFollowsBall:(BOOL)followBall {
	if (followBall)
		cameraFollowsBall = YES;
	else {
		cameraFollowsBall = NO;
	}
	
	// Reset user zoom factor
	m_cameraX_offset = 0;
	m_cameraY_offset = 0;
	m_cameraZ_zoom = 0;
}

- (void) resetZoomFactor {
	m_cameraZ_zoom = 0;
}


#pragma mark----- Collision Sounds Methods -----

- (void) setupSoundEffectsUsingDirectSoundFilePrefix:(NSString*)directSoundFilePrefix andDeflectSoundFilePrefix:(NSString*)deflectSoundFilePrefix {
    NSBundle *mainBundle = [NSBundle mainBundle];
		
	// special hack for smiley face and earth sounds (so they don't repeat until they have finished all the way)
	BOOL shouldWait = NO;
	if ([directSoundFilePrefix compare: @"earth"] == NSOrderedSame || [directSoundFilePrefix compare: @"smiley"] == NSOrderedSame)
		shouldWait = YES;
	
	// Direct bounce sounds
    directBounceSounds[kSoundVolumeFull] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:directSoundFilePrefix ofType:@"caf"] andShouldWait: shouldWait];
    directBounceSounds[kSoundVolume75] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[directSoundFilePrefix stringByAppendingString:@"-9dB"] ofType:@"caf"] andShouldWait: shouldWait];
    directBounceSounds[kSoundVolume50] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[directSoundFilePrefix stringByAppendingString:@"-18dB"] ofType:@"caf"] andShouldWait: shouldWait];
    directBounceSounds[kSoundVolume25] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[directSoundFilePrefix stringByAppendingString:@"-36dB"] ofType:@"caf"] andShouldWait: shouldWait];
	
	// Deflect bounce sounds
    //deflectBounceSounds[kSoundVolumeFull] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:deflectSoundFilePrefix ofType:@"caf"]];
    //deflectBounceSounds[kSoundVolume75] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[deflectSoundFilePrefix stringByAppendingString:@"-9dB"] ofType:@"caf"]];
    //deflectBounceSounds[kSoundVolume50] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[deflectSoundFilePrefix stringByAppendingString:@"-18dB"] ofType:@"caf"]];
    //deflectBounceSounds[kSoundVolume25] = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:[deflectSoundFilePrefix stringByAppendingString:@"-36dB"] ofType:@"caf"]];
	
}


- (void) playSoundForCollisionWithAbsSpeed:(float)absSpeed andAngle:(float)absAngle {
	
	// Set the sound volume based on the speed of the collision
	kSoundVolume soundVolume;
	
	if (absSpeed >= kMinSpeedForFullSound) {
		soundVolume = kSoundVolumeFull;
		//NSLog(@"Full speed hit!");
	}
	else if (absSpeed >= kMinSpeedFor75Sound) {
		soundVolume = kSoundVolume75;
		//NSLog(@"75%% speed hit!");
	}
	else if (absSpeed >= kMinSpeedFor50Sound) {
		soundVolume = kSoundVolume50;
		//NSLog(@"50%% speed hit!");
	}
	else if (absSpeed >= kMinSpeedFor25Sound) {
		soundVolume = kSoundVolume25;
		//NSLog(@"25%% speed hit!");
	}
	else {
		//NSLog(@"Hit too slow to play sound!");
		return; // Too soft a hit to play any sound
	}
    
	// Set the type of sound (direct vs. deflect) based on the angle of the collision
    if (absAngle >= kMinAngleForDirectBounceSound) {
		//NSLog(@"Direct hit!");
        [directBounceSounds[soundVolume] play];
    } else if (absAngle >= kMinAngleForDeflectBounceSound) {
		//NSLog(@"Deflected!");
        //[deflectBounceSounds[soundVolume] play];
		// Reuse the same sounds to save memory since we don't have any deflect sounds for now.
        [directBounceSounds[soundVolume] play];
    } else {
		//NSLog(@"Too shallow to play sound.");
        // Play no sound?
    }
	
}

- (void) handleCollisionWithSpeed:(float)speed andAngle:(float)angle {
    float absSpeed = fabs(speed);
    float absAngle = fabs(angle);
	
	// Play sound
	[self playSoundForCollisionWithAbsSpeed:absSpeed andAngle:absAngle];
	
	// Increment bounce count
	if (absSpeed >= kMinSpeedFor25Sound && absAngle >= kMinAngleForDeflectBounceSound) {
		[UserDefaults addToTotalBounceCount:1];
		//NSLog(@"Bounce!");
	}
	
}

- (void) handleCollisionForGID: (dGeomID) o1 andGID: (dGeomID) o2  {
	float relativeSpeed, collisionAngle;
	dVector3 rVel; // Relative velocity
	
	// Get the relative speed of the two bodies colliding to change the sound effect (volume).
	dBodyID body1 = dGeomGetBody(o1);
	dBodyID body2 = dGeomGetBody(o2);
	//NSLog(@"Body1: %d, Body2: %d", body1, body2);
	if (!body1 || !body2) { // One object didn't have a body ID (it is a wall)
		// Figure out which is which
		dBodyID ballBody;
		dGeomID ballGeom, wallGeom;
		if (body1) {
			ballBody = body1;
			ballGeom = o1;
			wallGeom = o2;
		}
		else {
			ballBody = body2;
			ballGeom = o2;
			wallGeom = o1;
		}
		
		// Set the relative velocity to the ball's velocity
		const dReal *vel = dBodyGetLinearVel(ballBody);
		rVel[0] = vel[0];
		rVel[1] = vel[1];
		rVel[2] = vel[2];
		
		// Get the normal vector of the wall
		dVector4 wallNormal;
		dGeomPlaneGetParams(wallGeom, wallNormal);
		
		// Use a threshold for which we do no calculation
		//   When the ball is rolling on the ground, it "collides" every cycle and we don't want to do a useless
		//   square root (and other) calculations.
		if (fabs(rVel[0]) < kMinSpeedToCalculate && fabs(rVel[1]) < kMinSpeedToCalculate && fabs(rVel[2]) < kMinSpeedToCalculate) {
			relativeSpeed = 0.0;
			//NSLog(@"Too slow to calculate:");
			//NSLog(@"\tRelative Velocity: x=%f, y=%f, z=%f", rVel[0], rVel[1], rVel[2]);
			return; // No sense calling the playSound function when we won't be playing any sound for a "zero"-speed hit.
		}
		
		// Calculate the angle of impact
		//   A.B = |A|*|B|*Cos(θ)
		float AdotB = (vel[0] * wallNormal[0]) + (vel[1] * wallNormal[1]) + (vel[2] * wallNormal[2]);
		float magA = sqrtf( (vel[0] * vel[0]) + (vel[1] * vel[1]) + (vel[2] * vel[2]) );
		//float magB = 1.0; // It is a normal vector (for the wall plane)
		float cosTheta = AdotB / magA; // No need to multiply by 1
		collisionAngle = acos(cosTheta);
		//NSLog(@"Collision angle: %f", RADIANS_TO_DEGREES(collisionAngle));
		
		// Speed of ball is magnitude of velocity vector (already computed)
		relativeSpeed = magA;
	}
	else { // Two balls?
		// Get difference of velocity vectors to get the relative velocity
		const dReal *vel1 = dBodyGetLinearVel(body1);
		const dReal *vel2 = dBodyGetLinearVel(body2);
		rVel[0] = vel1[0] - vel2[0];
		rVel[1] = vel1[1] - vel2[1];
		rVel[2] = vel1[2] - vel2[2];
		// Get magnitude of the velocity (speed)
		relativeSpeed = sqrtf( rVel[0]*rVel[0] + rVel[1]*rVel[1] + rVel[2]*rVel[2] );
		
		// Calculate the angle of impact
		//   A.B = |A|*|B|*Cos(θ)
		float AdotB = (vel1[0] * vel2[0]) + (vel1[1] * vel2[1]) + (vel1[2] * vel2[2]);
		float magA = sqrtf( (vel1[0] * vel1[0]) + (vel1[1] * vel1[1]) + (vel1[2] * vel1[2]) );
		float magB = sqrtf( (vel2[0] * vel2[0]) + (vel2[1] * vel2[1]) + (vel2[2] * vel2[2]) );
		float cosTheta = AdotB / (magA*magB);
		collisionAngle = acos(cosTheta);
	}
	
	//NSLog(@"Relative Velocity: x=%f, y=%f, z=%f", rVel[0], rVel[1], rVel[2]);
	//NSLog(@"Collision speed: %f", relativeSpeed);
	//NSLog(@"Collision angle: %f", RADIANS_TO_DEGREES(collisionAngle));
	
	// Play the sound for the collision
	[self handleCollisionWithSpeed:relativeSpeed andAngle:collisionAngle];
	
}


#pragma mark ----- Near Callback Method -----

- (void) callBack: (void *) data id1: (dGeomID) o1 id2: (dGeomID) o2 {
	
	if (dGeomIsSpace(o1) || dGeomIsSpace(o2)) {
		// colliding a space with something
		dSpaceCollide2(o1, o2, data, &nearCallback);
		// collide all geoms internal to the space(s)
		if (dGeomIsSpace(o1)) dSpaceCollide(o1, data, &nearCallback);
		if (dGeomIsSpace(o2)) dSpaceCollide(o2, data, &nearCallback);
	}
	else {
		//NSLog(@"colliding two non-space geoms");
		// colliding two non-space geoms, so generate contact points between o1 and o2
		int num_contacts = dCollide(o1, o2, MAX_CONTACTS, &contact_array[0].geom, sizeof(dContact));
		for (int i = 0; i < num_contacts; i++) {
			contact_array[i].surface.mode = dContactBounce | dContactSoftCFM;
			// friction parameter
			contact_array[i].surface.mu = 8;
			
			// bounce is the amount of "bouncyness".
			contact_array[i].surface.bounce = m_ballBounce;
			// bounce_vel is the minimum incoming velocity to cause a bounce
			contact_array[i].surface.bounce_vel = 0.25;//0.1;
			// soft_cfm is the "constraint force mixing parameter"
			contact_array[i].surface.soft_cfm = 0.001;
			
			dJointID c = dJointCreateContact (m_world, m_contactGroup, &contact_array[i]);
			dJointAttach (c, dGeomGetBody(contact_array[i].geom.g1), dGeomGetBody(contact_array[i].geom.g2));
			
			// Play a sound for the collision
			// It works to play a sound here because we are working with spheres, which only have one contact point
			[self handleCollisionForGID: o1 andGID: o2];
			
		}
	}
}


#pragma mark ----- Torque Stuff -----

- (void) addTorqueX: (dReal) x Y: (dReal) y Z: (dReal) z {
	dReal scale = (m_ballRadius + 3) * (m_ballRadius + 3) * .025;
	//NSLog(@"torqMagSq: %f", torqMagSq);
	dBodyAddTorque(m_ballID, x * scale, y * scale, z * scale);
}

- (float) magnitude:(dVector3) vector {
	return sqrtf(vector[0]*vector[0] + vector[1]*vector[1] + vector[2]*vector[2]);	
}

- (float) dotProductOfVector1:(dVector3) vector1 andVector2:(dVector3) vector2 {
	return (vector1[0] * vector2[0]) + (vector1[1] * vector2[1]) + (vector1[2] * vector2[2]);
}


#pragma mark----- Customization Methods -----

- (void) setBallTypeIndex: (unsigned) index reloadCustomImage: (BOOL) loadCustomBallImage {
	
	// Use mass only if specified
	// A mass of 1.0 was the default before adding the ball mass options and won't adversely affect the physics
	float mass = 1.0;
	// Disable this feature for now
	//if ([ballTypes useMassForBallAtIndex:[UserDefaults ballIndex]])
		mass = [ballTypes massOfBallAtIndex:index];
	
	// Setup size, bounce, and mass parameters
	[self setBallSize:[ballTypes radiusOfBallAtIndex:index] andBounce:[ballTypes bounceOfBallAtIndex:index] andMass:mass];
	
	// Setup texture
	[m_ball setTexture:[ballTypes imageFileForBallAtIndex:index] releaseOld: YES reloadCustomImage: loadCustomBallImage];
	
	// Setup sound effects
	NSString * directSoundFilePrefix = [ballTypes directSoundFilePrefixForBallAtIndex:index];
	NSString * deflectSoundFilePrefix = [ballTypes deflectSoundFilePrefixForBallAtIndex:index];
	[self setupSoundEffectsUsingDirectSoundFilePrefix:directSoundFilePrefix andDeflectSoundFilePrefix:deflectSoundFilePrefix];
}

- (void) setBallTypeIndex: (unsigned) index {
	[self setBallTypeIndex:	index reloadCustomImage: YES];
}

- (void) setBallSize:(float)radius andBounce:(float)bounce andMass:(float)mass {
	
	// Set ball size
	m_ballRadius = radius;
	m_ballArea = PI * radius * radius;
	[m_ball setScale:m_ballRadius];
	
	// Set ball mass
	m_ballMass = mass;
	dMass ballMass;
	dBodyGetMass(m_ballID, &ballMass);
	dMassSetSphereTotal(&ballMass, m_ballMass, m_ballRadius);
	dBodySetMass(m_ballID, &ballMass);
	
	dGeomSphereSetRadius(m_ballGeom, m_ballRadius);
	
	// Set ball bounciness
	m_ballBounce = bounce;
	
	// Reset position of ball (to make sure it isn't inside a wall or the floor)
	dBodySetPosition(m_ballID, 0, 0, -2*m_ballRadius);
}


#pragma mark ----- Touch Handling Methods -----

// Swipe to move and pinch to zoom
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	timeStamp = [NSDate date];
    
	NSSet *allTouches = [event allTouches];
	
	// Just in case touchesEnded never got called before new touches began
	if (touchesBeganButNotEnded)
		[self resetZoomDistance];
	else
		touchesBeganButNotEnded = YES;
	
    
    switch ([allTouches count]) {
        case 1: {
			//NSLog(@"One finger began");
			//Get the first touch.
			UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint pos = [touch locationInView: glView];
			
			switch([touch tapCount])
			{
				case 1://Single tap
					//NSLog(@"\tSingle tap");
					initialXPosition = pos.x;
					initialYPosition = pos.y;
					break;
				case 2://Double tap.
					//NSLog(@"\tDouble tap");
					// Flip to Settings View
					// This is now done in TouchesEnded
					//[delegate toggleView];
					break;
			}
			
			// Reset zoom distance just in case
			[self resetZoomDistance];
			
        } break;
        case 2: {
			//NSLog(@"Two fingers began");
            //get out two fingers
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
			
			//and calculate our initial distance between them
			initialDistance = [self distanceBetweenTwoPoints:[touch1 locationInView: glView]
													 toPoint:[touch2 locationInView: glView]];
			
        } break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: { //Move
			//NSLog(@"One finger moved");
            CGPoint actualPosition = [[[allTouches allObjects] objectAtIndex:0] locationInView: glView];
            
            movedX = actualPosition.x - initialXPosition;
            movedY = initialYPosition - actualPosition.y;
            
            initialXPosition = actualPosition.x;
            initialYPosition = actualPosition.y;
			
			// Add a torque to the ball
			[self applyTorque];
			
			// Reset zoom distance just in case
			[self resetZoomDistance];
			
        } break;
        case 2: { //Zoom
			//NSLog(@"Two fingers moved");
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
            //Calculate the distance between the two fingers.
            CGFloat finalDistance = [self distanceBetweenTwoPoints:[touch1 locationInView: glView]
                                                           toPoint:[touch2 locationInView: glView]];
			
			if (initialDistance == -1)
				movedZ = 0;
			else
				movedZ = initialDistance - finalDistance;
			
			//NSLog(@"\tinitialDistance= %f", initialDistance);
			//NSLog(@"\tfinalDistance= %f", finalDistance);
			//NSLog(@"\tmovedZ= %f", movedZ);
			
            initialDistance = finalDistance;
			
			// Tell the GLView
			self.movedZ = movedZ;
			
        } break;
    }
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
	
	
	if ([allTouches count] == 1) {
		
		// Get the first touch.
		UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
		
		// Apply a torque to the ball
		CGPoint actualPosition = [touch locationInView: glView];
		
		movedX = actualPosition.x - initialXPosition;
		movedY = initialYPosition - actualPosition.y;
		
		if (movedX != 0 || movedY != 0) {
			
			initialXPosition = actualPosition.x;
			initialYPosition = actualPosition.y;
			
			[self applyTorque];
			
		}
	}
	
	
	// Update the current state of touches
	touchesBeganButNotEnded = NO;
	[self resetZoomDistance];
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	touchesBeganButNotEnded = NO;
	[self resetZoomDistance];
}


// This method is for spinning the ball
- (void) applyTorque {
	// Give the ball a torque
	NSDate * now = [NSDate date];
	double timeDiff = [now timeIntervalSinceDate: timeStamp];
	timeStamp = now;
	dReal unitX = (movedX / timeDiff);
	dReal unitY = (movedY / timeDiff);
	
	dVector3 a;
	dVector3 b;
	a[0] = unitX;
	a[1] = unitY;
	a[2] = 0;
	b[0] = 0;
	b[1] = 0;
	b[2] = 1;
	dVector3 cross;
	cross[0] = b[1]*a[2] - b[2]*a[1];
	cross[1] = -b[0]*a[2] + b[2]*a[0];
	cross[2] = b[0]*a[1] - b[1]*a[0];
	float scale = 200;
	
	// addTorque spins the ball around the given vector. The appropriate vector to spin around is given by the
	// cross product of the z axis (straight into iPhone screen) with the direction of the finger swipe.
	[self addTorqueX: cross[0]/scale Y: cross[1]/scale Z: cross[2]/scale];
}

- (void)resetZoomDistance {
	initialDistance = -1;
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

- (void) dealloc {
	dJointGroupDestroy(m_contactGroup);
	dBodyDestroy(m_ballID);
	dWorldDestroy(m_world);
	
}


@end
