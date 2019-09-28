//
//  Character.m
//  GameArchitecture
//
//  Created by Hans Yadav on 6/26/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Character.h"

@implementation Character

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"hero";
}

@end
