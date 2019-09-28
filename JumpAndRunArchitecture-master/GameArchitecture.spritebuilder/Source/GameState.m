//
//  GameState.m
//  GameArchitecture
//
//  Created by Hans Yadav on 6/26/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameState.h"

@implementation GameState

const static int DEFAULT_LEVEL = 1;

+ (GameState *)sharedInstance {
  static dispatch_once_t once;
  static GameState *instance;
  dispatch_once(&once, ^{
    instance = [[GameState alloc] init];
  });
  return instance;
}

- (id)init {
  self = [super init];
  
  if (self) {
    self.currentLevel = DEFAULT_LEVEL;
    self.levels = @{
                    @1: @{ @"walkingSpeed": @40.f, @"jumpHeight": @1200.f },
                    @2: @{ @"walkingSpeed": @100.f, @"jumpHeight": @1200.f },
                    @3: @{ @"walkingSpeed": @20.f, @"jumpHeight": @1200.f },
                  };
    self.starsCollected = 0;
  }
  
  return self;
}

- (void)updateCurrentLevel {
  self.currentLevel++;
}

- (void)resetCurrentLevel {
  self.currentLevel = DEFAULT_LEVEL;
}

- (float)getLevelAttribute:(NSString*) attribute {
  
  NSDictionary* levelProperties = [self.levels objectForKey:[NSNumber numberWithInt:self.currentLevel]];
  
  return [[levelProperties objectForKey:attribute] floatValue];
}

- (void)resetStarCount {
  self.starsCollected = 0;
}

- (void)updateStarCount {
  self.starsCollected++;
}

@end
