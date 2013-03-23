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

@property int horizontalStep;
@property int verticalStep;
@property (strong) GameDictProcessor *gameObj;
@property CGPoint lastTouchedPoint;
@property BOOL moving;
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

    for (int i = 0; i < self.gameObj.arrayLeftField.count; i++) {
        [self placeUnit:self.gameObj.arrayLeftField[i] forLeftArmy:YES];
    }
    for (int i = 0; i < self.gameObj.arrayRightField.count; i++) {
        [self placeUnit:self.gameObj.arrayRightField[i] forLeftArmy:NO];
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
    x = x + self.horizontalStep /2;
    y = y + self.verticalStep / 2;
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
        self.horizontalStep = floor(size.width / 9);
        self.verticalStep = floor(size.height / 6);
        NSLog(@"horizontal step: %i, vertical: %i", self.horizontalStep, self.verticalStep);
        CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"Back" block:^(id sender) {
            [[CCDirector sharedDirector] popScene];
        }];
        CCMenu *menu = [[CCMenu alloc] initWithArray:@[back]];
        menu.position = ccp(size.width - 20, 10);
        [self addChild:menu];
         [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
	return self;
}

#pragma Deal with touch callbacks
//set the last touched point so we can know were to put
-(void) setTouchedPoint:(CGPoint) point {
    self.lastTouchedPoint = point;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [self convertTouchToNodeSpace:touch];
    NSLog(@"touch ended at: %@", NSStringFromCGPoint(location));
    [self setTouchedPoint:location];
    if (!self.moving) {
        [self selectSpriteSquareAt:location];
    }
    self.moving = NO;
}
#pragma End of touch callbacks
//method used just to get i and j coordinates of the selected sprite
//then selectSpriteSquareAt:i j is called to actually select the sprite and do all actions
//like select sprite at i and j coordinates, if question selected - mark all sprites of the answer.
-(void) selectSpriteSquareAt:(CGPoint) touchPoint {
    NSLog(@"Entered select spriteSquare At point: %@", NSStringFromCGPoint(touchPoint));
    if (touchPoint.y  < self.verticalStep) {
        NSLog(@"touch beyond field");
        return;
    }
    /*else if (touchPoint.x < FIELD_OFFSET || touchPoint.x > ([[CCDirector sharedDirector] winSize].width) - FIELD_OFFSET) {
        NSLog(@"touch beynod field");
        return;
    }*/
    [self.gameObj unitPresentAtPosition:touchPoint winSize:[[CCDirector sharedDirector] winSize] horizontalStep:self.horizontalStep verticalStep:self.verticalStep];
}

@end