//
//  Seal.m
//  PeevedPenguins
//
//  Created by Hans Yadav on 6/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"seal";
}

@end
