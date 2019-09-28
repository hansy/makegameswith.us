//
//  Level.m
//  GameArchitecture
//
//  Created by Hans Yadav on 6/26/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level.h"
#import "CCActionFollow+CurrentOffset.h"
#define CP_ALLOW_PRIVATE_ACCESS 1
#import "CCPhysics+ObjectiveChipmunk.h"
#import "WinPopup.h"
#import "GameState.h"

@implementation Level {
  CCNode *_startPositionNode;
  CCNode *_flagPositionNode;
  CCPhysicsNode *_physicsNode;
  CCNode* _flag;
  CCNode* _character;
  BOOL _jumped;
  CCLabelTTF* _starsCollected;
}

- (void)didLoadFromCCB {
  self.userInteractionEnabled = TRUE;
  _physicsNode.collisionDelegate = self;
//  _physicsNode.debugDraw = TRUE;
  
  [[GameState sharedInstance] resetStarCount];
  [self displayStarCount];
  [self addCharacter:@"green"];
  [self addFlag:@"blue"];
}

- (void)addCharacter:(NSString*) characterColor {
  
  if ([characterColor isEqual: @"green"]) {
    _character = [CCBReader load:@"Characters/CharacterGreen"];
  } else {
    _character = [CCBReader load:@"Characters/CharacterBlue"];
  }
  
  _character.position = _startPositionNode.position;
  [_physicsNode addChild:_character];
}

- (void)addFlag:(NSString *) flagColor {
  
  if ([flagColor isEqual:@"blue"]) {
    _flag = [CCBReader load:@"Flags/FlagBlue"];
  } else {
    _flag = [CCBReader load:@"Flags/FlagYellow"];
  }
  
  _flag.position = _flagPositionNode.position;
  [_physicsNode addChild:_flag];
}

- (void)onEnter {
  [super onEnter];
  
  _character.physicsBody.body.body->velocity_func = playerUpdateVelocity;
  CCActionFollow *follow = [CCActionFollow actionWithTarget:_character worldBoundary:_physicsNode.boundingBox];
  _physicsNode.position = [follow currentOffset];
  [_physicsNode runAction:follow];
}

- (void)onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  self.userInteractionEnabled = YES;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  [_character.physicsBody.chipmunkObjects[0] eachArbiter:^(cpArbiter *arbiter) {
    if (!_jumped) {
      [_character.physicsBody applyImpulse:ccp(0, [[GameState sharedInstance] getLevelAttribute:@"jumpHeight"])];
      _jumped = TRUE;
      [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.3f];
    }
  }];
}

- (void)resetJump {
  _jumped = FALSE;
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair star:(CCNode *)nodeA hero:(CCNode *)nodeB {
  [nodeA removeFromParent];
  [[GameState sharedInstance] updateStarCount];
  [self displayStarCount];
}

static void
playerUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
  cpAssertSoft(body->m > 0.0f && body->i > 0.0f, "Body's mass and moment must be positive to simulate. (Mass: %f Moment: %f)", body->m, body->i);
  
	body->v = cpvadd(cpvmult(body->v, damping), cpvmult(cpvadd(gravity, cpvmult(body->f, body->m_inv)), dt));
	body->w = body->w*damping + body->t*body->i_inv*dt;
  
	// Reset forces.
	body->f = cpvzero;
	body->t = 0.0f;
  
	body->v.x = [[GameState sharedInstance] getLevelAttribute:@"walkingSpeed"];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero flag:(CCNode *)flag {
  self.paused = YES;
  
  WinPopup *popup = (WinPopup *)[CCBReader load:@"WinPopup"];
  popup.positionType = CCPositionTypeNormalized;
  popup.position = ccp(0.5, 0.5);
  popup.nextLevelName = [NSString stringWithFormat:@"Levels/Level%i", [self getNextLevelNumber]];
  [self addChild:popup];
  
  return TRUE;
}

- (void)update:(CCTime)delta {
  if (CGRectGetMaxY([_character boundingBox]) <  CGRectGetMinY(_physicsNode.boundingBox)) {
    [self gameOver];
  }
}

- (void)gameOver {
  CCScene *restartScene = [CCBReader loadAsScene:[NSString stringWithFormat:@"Levels/Level%i", [self currentLevel]]];
  CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
  [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}

- (int)getNextLevelNumber {
  int levelSize = [[[[GameState sharedInstance] levels] allKeys] count];
  
  if ([self currentLevel] < levelSize) {
    [[GameState sharedInstance] updateCurrentLevel];
  } else {
    [[GameState sharedInstance] resetCurrentLevel];
  }
  
  return [self currentLevel];
}

- (int)currentLevel {
  return [[GameState sharedInstance] currentLevel];
}

- (void)displayStarCount {
  _starsCollected.string = [NSString stringWithFormat:@"%i", [[GameState sharedInstance] starsCollected]];
}

@end
