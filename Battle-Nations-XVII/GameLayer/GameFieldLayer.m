//
//  GameFieldLayer.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/17/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "GameFieldLayer.h"

@implementation GameFieldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameFieldLayer *layer = [GameFieldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        // to avoid a retain-cycle with the menuitem and blocks
        __block id copy_self = self;
        CCSprite *sprite = [CCSprite spriteWithFile:@"cossack.png"];
        sprite.position = ccp(100, 100);
        [self addChild:sprite];
    }
	return self;
}


@end

