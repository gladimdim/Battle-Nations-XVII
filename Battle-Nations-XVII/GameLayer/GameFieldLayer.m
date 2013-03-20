//
//  GameFieldLayer.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/17/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "GameFieldLayer.h"
#import "GameDictProcessor.h"

@interface GameFieldLayer()
@property NSDictionary *dictLeftArmy;
@property NSDictionary *dictRightArmy;
@property NSArray *arrayLeftField;
@property NSArray *arrayRightField;
@property int horizontalStep;
@property int verticalStep;
@property (strong) GameDictProcessor *gameObj;
@end

#define FIELD_OFFSET 20
@implementation GameFieldLayer

+(CCScene *) sceneWithDictOfGame:(NSDictionary *) dictOfGame;
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameFieldLayer *layer = [GameFieldLayer node];
	layer.dictOfGame = dictOfGame;
    layer.gameObj = [[GameDictProcessor alloc] initWithDictOfGame:dictOfGame];
    [layer initObject];
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) initObject {
    self.dictLeftArmy = [self.gameObj getLeftArmy];
    self.dictRightArmy = [self.gameObj getRightArmy];
    self.arrayLeftField = [self.gameObj getLeftField];
    self.arrayRightField = [self.gameObj getRightField];
    for (int i = 0; i < self.arrayLeftField.count; i++) {
        [self placeUnit:self.arrayLeftField[i] forLeftArmy:YES];
    }
    for (int i = 0; i < self.arrayRightField.count; i++) {
        [self placeUnit:self.arrayRightField[i] forLeftArmy:NO];
    }
}

-(void) placeUnit:(NSDictionary *) unit forLeftArmy:(BOOL) leftArmy {
    NSString *unitName = [unit allKeys][0];
    NSDictionary *unitDetails = [unit objectForKey:unitName];
    NSArray *position = [unitDetails objectForKey:@"position"];
    CCSprite *sprite = [CCSprite spriteWithFile:@"cossack.png"];
    NSNumber *posX = [NSNumber numberWithInt:(int)[position[0] intValue]];
    NSNumber *posY = [NSNumber numberWithInt:(int)[position[1] intValue]];
    int x = [posX intValue] * self.horizontalStep + FIELD_OFFSET;
    int y = [posY intValue] * self.verticalStep + self.verticalStep;
    if (!leftArmy) {
        [sprite setScaleX:-1.0];
        //[sprite setScaleY:-1.0];
    }
    NSLog(@"placing sprite at %i %i", x, y);
    sprite.position = ccp(x, y);
    [self addChild:sprite];
}
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        // to avoid a retain-cycle with the menuitem and blocks
        __block id copy_self = self;
     //   CCSprite *sprite = [CCSprite spriteWithFile:@"cossack.png"];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        //int x = (size.width - FIELD_OFFSET) / 9;
        self.horizontalStep = floor((size.width - FIELD_OFFSET) / 9);
        self.verticalStep = floor((size.height - FIELD_OFFSET) / 6);
        NSLog(@"horizontal step: %i, vertical: %i", self.horizontalStep, self.verticalStep);
        CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"Back" block:^(id sender) {
            [[CCDirector sharedDirector] popScene];
        }];
        CCMenu *menu = [[CCMenu alloc] initWithArray:@[back]];
        menu.position = ccp(size.width - 20, 10);
        [self addChild:menu];
    }
	return self;
}

@end

