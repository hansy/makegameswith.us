//
//  GameState.h
//  GameArchitecture
//
//  Created by Hans Yadav on 6/26/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

+ (GameState *)sharedInstance;
- (void)updateCurrentLevel;
- (void)resetCurrentLevel;
- (float)getLevelAttribute:(NSString*) attribute;
- (void)resetStarCount;
- (void)updateStarCount;

@property (nonatomic, assign) int currentLevel;
@property (nonatomic, strong) NSDictionary *levels;
@property (nonatomic, assign) int starsCollected;

@end
