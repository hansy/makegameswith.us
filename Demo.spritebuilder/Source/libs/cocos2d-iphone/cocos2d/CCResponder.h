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
 *
 *
 * File autogenerated with Xcode. Adapted for cocos2d needs.
 */

#import <Foundation/Foundation.h>
#import "CCResponderManager.h"
#import "CCMacros.h"

/**
 *  CCResponder is the base class for all nodes.
 *  It exposes the touch and mouse interface to any node, which enables user interaction.
 *
 *  To make a responder react to user interaction, the touchesXXX / mouseXXX event must be overridden.
 *  If this is not the case, the event will be passed on to the next responder.
 *  To force the events to be passed to next responder, call the super as last step, before returning from the event.
 */
@interface CCResponder : NSObject


/** Enables user interaction on a node. */
@property ( nonatomic, assign, getter = isUserInteractionEnabled ) BOOL userInteractionEnabled;

/** Enables multiple touches inside a single node. */
@property ( nonatomic, assign, getter = isMultipleTouchEnabled ) BOOL multipleTouchEnabled;

/** 
 *  Locks the touch to the node if touch moved outside
 *  If a node claims user interaction, the touch will continue to be sent to the node, no matter where the touch is moved
 *  If the node does not claim user interaction, a touch will be cancelled, if moved outside the nodes detection area
 *  If the node does not claim user interaction, and a touch is moved from outside the nodes detection area, to inside, a touchBegan will be generated.
 */
@property (nonatomic, assign) BOOL claimsUserInteraction;

/** 
 *  All other touches will be cancelled / ignored, if a node with exclusive touch, is active
 *  Only one exclusive touch can be active at a time.
 */
@property (nonatomic, assign, getter = isExclusiveTouch) BOOL exclusiveTouch;

/// -----------------------------------------------------------------------
/// @name Initializing a CCResponder Object
/// -----------------------------------------------------------------------

/**
 *  Initialzes a new CCResponder.
 *
 *  @return An CCResponder CCLabelBMFont Object.
 */
- (id)init;

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)


#pragma mark -
#pragma mark Touch Handling Methods
/// -----------------------------------------------------------------------
/// @name Touch Handling Methods
/// -----------------------------------------------------------------------

/**
 Called when a touch began.
 
 If a touch is dragged inside a node which does not claim user interaction, a touchBegan will be generated.
 If node has exclusive touch, all other ongoing touches will be canceled.
 
 If a node wants to grab the touch, touchBegan must be overridden, even if empty. Overriding touchMoved is not enough.
 
 To pass the touch further down the responder chain, call super touchBegan.
 
    if (!thisNodeGrabsTouch) [super touchBegan:touch withEvent:event];
 
 @param touch    Contains the touch.
 @param event    Current event information.
 */
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event;

/**
 *  Called whan a touch moves.
 *
 *  @param touch    Contains the touch.
 *  @param event    Current event information.
 */
- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event;

/**
 *  Called when a touch ends.
 *
 *  @param touch    Contains the touch.
 *  @param event    Current event information.
 */
- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event;

/**
 *  Called when a touch was cancelled.
 *  If a touch is dragged outside a node which does not claim user interaction, touchCancelled will be called.
 *  If another node with exclusive touch is activated, touchCancelled will be called for all ongoing touches.
 *
 *  @param touch    Contains the touch.
 *  @param event    Current event information.
 */
- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event;

#elif __CC_PLATFORM_MAC


#pragma mark -
#pragma mark Mouse Handling Methods
/// -----------------------------------------------------------------------
/// @name Mouse Handling Methods
/// -----------------------------------------------------------------------

/**
 *  Called when left mouse button is pressed inside a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)mouseDown:(NSEvent *)theEvent;

/**
 *  Called when left mouse button is dragged for a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)mouseDragged:(NSEvent *)theEvent;

/**
 *  Called when left mouse button is released for a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)mouseUp:(NSEvent *)theEvent;

/**
 *  Called when right mouse button is pressed inside a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)rightMouseDown:(NSEvent *)theEvent;

/**
 *  Called when right mouse button is dragged for a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)rightMouseDragged:(NSEvent *)theEvent;

/**
 *  Called when right mouse button is released for a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)rightMouseUp:(NSEvent *)theEvent;

/**
 *  Called when middle mouse button is pressed inside a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)otherMouseDown:(NSEvent *)theEvent;

/**
 *  Called when middle mouse button is dragged for a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)otherMouseDragged:(NSEvent *)theEvent;

/**
 *  Called when middle mouse button is released for a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)otherMouseUp:(NSEvent *)theEvent;

/**
 *  Called when scroll wheel is activated inside a node accepting user interaction.
 *
 *  @param theEvent The event created.
 */
- (void)scrollWheel:(NSEvent *)theEvent;

#endif

@end
