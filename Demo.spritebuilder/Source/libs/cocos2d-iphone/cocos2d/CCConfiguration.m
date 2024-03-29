/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCMacros.h"

#if __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>		// Needed for UIDevice
#elif __CC_PLATFORM_ANDROID
#import <BridgeKitV3/BridgeKit.h> // Needed for AndroidBuild
#endif

#import "Platforms/CCGL.h"
#import "CCConfiguration.h"
#import "CCMacros.h"
#import "CCConfig.h"
#import "cocos2d.h"

@interface CCConfiguration ()
-(void) getOpenGLvariables;
@end

@implementation CCConfiguration

@synthesize maxTextureSize = _maxTextureSize, maxTextureUnits=_maxTextureUnits;
@synthesize supportsPVRTC = _supportsPVRTC;
@synthesize supportsNPOT = _supportsNPOT;
@synthesize supportsBGRA8888 = _supportsBGRA8888;
@synthesize supportsDiscardFramebuffer = _supportsDiscardFramebuffer;
@synthesize supportsShareableVAO = _supportsShareableVAO;
@synthesize OSVersion = _OSVersion;

//
// singleton stuff
//
static CCConfiguration *_sharedConfiguration = nil;

static char * glExtensions;

+ (CCConfiguration *)sharedConfiguration
{
	if (!_sharedConfiguration)
		_sharedConfiguration = [[self alloc] init];

	return _sharedConfiguration;
}

+(id)alloc
{
	NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}


#if __CC_PLATFORM_IOS
#elif __CC_PLATFORM_MAC
- (NSString*)getMacVersion
{
    return([[NSProcessInfo processInfo] operatingSystemVersionString]);
}
#endif // __CC_PLATFORM_MAC

-(id) init
{
	if( (self=[super init])) {

		// Obtain iOS version
		_OSVersion = 0;
#if __CC_PLATFORM_IOS
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif __CC_PLATFORM_MAC
		NSString *OSVer = [self getMacVersion];
#elif __CC_PLATFORM_ANDROID
        NSString *OSVer = @"?";//[AndroidBuild DISPLAY];
#endif
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];
		int idx = 0x01000000;
		for( NSString *str in arr ) {
			int value = [str intValue];
			_OSVersion += value * idx;
			idx = idx >> 8;
		}
	}

	CC_CHECK_GL_ERROR_DEBUG();

	return self;
}

- (BOOL) checkForGLExtension:(NSString *)searchName
{
	// For best results, extensionsNames should be stored in your renderer so that it does not
	// need to be recreated on each invocation.
    NSString *extensionsString = [NSString stringWithCString:glExtensions encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}

// XXX: Optimization: This should be called only once
-(NSInteger) runningDevice
{
	NSInteger ret=-1;

	/*
#if defined(APPORTABLE)
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		ret = ([UIScreen mainScreen].scale > 1) ? CCDeviceiPadRetinaDisplay : CCDeviceiPad;
	}
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		if( [UIScreen mainScreen].scale > 1 ) {
			ret = CCDeviceiPhoneRetinaDisplay;
		} else
			ret = CCDeviceiPhone;
	}
#el*/#if __CC_PLATFORM_IOS
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		ret = ([UIScreen mainScreen].scale == 2) ? CCDeviceiPadRetinaDisplay : CCDeviceiPad;
	}
	else if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
	{
		// From http://stackoverflow.com/a/12535566
		BOOL isiPhone5 = CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
		
		if( [UIScreen mainScreen].scale == 2 ) {
			ret = isiPhone5 ? CCDeviceiPhone5RetinaDisplay : CCDeviceiPhoneRetinaDisplay;
		} else
			ret = isiPhone5 ? CCDeviceiPhone5 : CCDeviceiPhone;
	}
	
#elif __CC_PLATFORM_MAC
	
	// XXX: Add here support for Mac Retina Display
	ret = CCDeviceMac;
	
#endif // __CC_PLATFORM_MAC
	
	return ret;
}

#pragma mark OpenGL getters

/** OpenGL Max texture size. */

-(void) getOpenGLvariables
{
	if( ! _openGLInitialized ) {

		glExtensions = (char*) glGetString(GL_EXTENSIONS);

		NSAssert( glExtensions, @"OpenGL not initialized!");

#if __CC_PLATFORM_IOS
		if( _OSVersion >= CCSystemVersion_iOS_4_0 )
			glGetIntegerv(GL_MAX_SAMPLES_APPLE, &_maxSamplesAllowed);
		else
			_maxSamplesAllowed = 0;
#elif __CC_PLATFORM_MAC
		glGetIntegerv(GL_MAX_SAMPLES, &_maxSamplesAllowed);
#endif

		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_maxTextureSize);
		glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &_maxTextureUnits );

#if __CC_PLATFORM_IOS
		_supportsNPOT = YES;
        _supportsPackedDepthStencil = YES;
#elif __CC_PLATFORM_MAC
		_supportsNPOT = [self checkForGLExtension:@"GL_ARB_texture_non_power_of_two"];
        _supportsPackedDepthStencil = YES;
#elif __CC_PLATFORM_ANDROID
        // source: http://www.khronos.org/registry/gles/
        _supportsNPOT = [self checkForGLExtension:@"GL_OES_texture_npot"] || [self checkForGLExtension:@"GL_NV_texture_npot_2D_mipmap"];
        _supportsPackedDepthStencil = [self checkForGLExtension:@"GL_OES_packed_depth_stencil"];
#endif

		_supportsPVRTC = [self checkForGLExtension:@"GL_IMG_texture_compression_pvrtc"];

		// It seems that somewhere between firmware iOS 3.0 and 4.2 Apple renamed
		// GL_IMG_... to GL_APPLE.... So we should check both names
#if __CC_PLATFORM_IOS
		BOOL bgra8a = [self checkForGLExtension:@"GL_IMG_texture_format_BGRA8888"];
		BOOL bgra8b = [self checkForGLExtension:@"GL_APPLE_texture_format_BGRA8888"];
		_supportsBGRA8888 = bgra8a | bgra8b;
#elif __CC_PLATFORM_MAC
		_supportsBGRA8888 = [self checkForGLExtension:@"GL_EXT_bgra"];
#endif
		_supportsDiscardFramebuffer = [self checkForGLExtension:@"GL_EXT_discard_framebuffer"];

		_supportsShareableVAO = [self checkForGLExtension:@"GL_APPLE_vertex_array_object"];
		
		_openGLInitialized = YES;
	}
}

-(GLint) maxTextureSize
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];
	return _maxTextureSize;
}

-(GLint) maxTextureUnits
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];

	return _maxTextureUnits;
}

-(BOOL) supportsNPOT
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];

	return _supportsNPOT;
}

-(BOOL) supportsPVRTC
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];

	return _supportsPVRTC;
}

-(BOOL) supportsPackedDepthStencil
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];

    return _supportsPackedDepthStencil;
}

-(BOOL) supportsBGRA8888
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];

	return _supportsBGRA8888;
}

-(BOOL) supportsDiscardFramebuffer
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];

	return _supportsDiscardFramebuffer;
}

-(BOOL) supportsShareableVAO
{
	if( ! _openGLInitialized )
		[self getOpenGLvariables];

	return _supportsShareableVAO;
}


#pragma mark Helper

-(void) dumpInfo
{
#if DEBUG
	printf("cocos2d: %s\n", [cocos2dVersion() UTF8String] );

#if __CC_PLATFORM_IOS
	NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif __CC_PLATFORM_ANDROID
    NSString *OSVer = @"?";//[AndroidBuild DISPLAY];
#else //__CC_PLATFORM_MAC
	NSString *OSVer = [self getMacVersion];
#endif

#if __CC_PLATFORM_MAC
	printf("cocos2d: Director's thread: %s\n",
#if (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_MAIN_THREAD)
		  "Main thread"
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_OWN_THREAD)
		  "Own thread"
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_DISPLAY_LINK_THREAD)
		  "DisplayLink thread"
#endif //
		  );
#endif // Mac
	
	printf("cocos2d: compiled with Profiling Support: %s\n",
#if CC_ENABLE_PROFILERS
		  "YES - *** Disable it when you finish profiling ***"
#else
		  "NO"
#endif
		  );

	printf("cocos2d: OS version: %s (0x%08x)\n", [OSVer UTF8String], _OSVersion);
	printf("cocos2d: %ld bit runtime\n", 8*sizeof(long));
	
	printf("cocos2d: GL_VENDOR:   %s\n", glGetString(GL_VENDOR) );
	printf("cocos2d: GL_RENDERER: %s\n", glGetString ( GL_RENDERER   ) );
	printf("cocos2d: GL_VERSION:  %s\n", glGetString ( GL_VERSION    ) );
	
	printf("cocos2d: GL_MAX_TEXTURE_SIZE: %d\n", _maxTextureSize);
	printf("cocos2d: GL_MAX_TEXTURE_UNITS: %d\n", _maxTextureUnits);
	printf("cocos2d: GL_MAX_SAMPLES: %d\n", _maxSamplesAllowed);
	printf("cocos2d: GL supports PVRTC: %s\n", (_supportsPVRTC ? "YES" : "NO") );
	printf("cocos2d: GL supports BGRA8888 textures: %s\n", (_supportsBGRA8888 ? "YES" : "NO") );
	printf("cocos2d: GL supports NPOT textures: %s\n", (_supportsNPOT ? "YES" : "NO") );
	printf("cocos2d: GL supports discard_framebuffer: %s\n", (_supportsDiscardFramebuffer ? "YES" : "NO") );
	printf("cocos2d: GL supports shareable VAO: %s\n", (_supportsShareableVAO ? "YES" : "NO") );
	
#endif // DEBUG
}
@end
