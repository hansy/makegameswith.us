//
//  StartScene.m
//  GameArchitecture
//
//  Created by Benjamin Encz on 10/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "StartScene.h"

@implementation StartScene

- (void)startGame {
  CCScene *firstLevel = [CCBReader loadAsScene:@"Levels/Level1"];
  CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
  [[CCDirector sharedDirector] presentScene:firstLevel withTransition:transition];
}

- (NSArray*)getLevelNames {
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *publishedIOSPath = [resourcePath stringByAppendingPathComponent:@"Published-iOS"];
  NSString *levelsPath = [publishedIOSPath stringByAppendingPathComponent:@"Levels"];
  NSError *error;
  NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:levelsPath error:&error];
  
//  NSMutableArray *fileNames;
//  
//  for (id fileName in directoryContents) {
//    [fileNames addObject:[fileName stringByDeletingPathExtension]];
//  }
//  
  return directoryContents;
}
@end
