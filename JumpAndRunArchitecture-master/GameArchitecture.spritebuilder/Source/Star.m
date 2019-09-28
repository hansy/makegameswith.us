//
//  Star.m
//  GameArchitecture
//
//  Created by Hans Yadav on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Star.h"

@implementation Star

- (void)didLoadFromCCB {
  self.physicsBody.collisionType = @"star";
}

@end
