//
//  Flag.m
//  GameArchitecture
//
//  Created by Hans Yadav on 6/26/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Flag.h"

@implementation Flag {
  CCNode* _flag;
}

- (void)didLoadFromCCB {
  _flag.physicsBody.sensor = YES;
  self.physicsBody.collisionType = @"flag";
}

@end
