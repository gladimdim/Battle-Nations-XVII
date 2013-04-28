//
//  GameFieldLayer.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/17/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "GameFieldLayer.h"
#import "GameDictProcessor.h"
#import "GameLogic.h"
#import "DataPoster.h"
#import "UkraineInfo.h"

@interface GameFieldLayer()

@property int horizontalStep;
@property int verticalStep;
@property (strong) GameDictProcessor *gameObj;
@property CGPoint lastTouchedPoint;
@property BOOL moving;
@property (strong) NSArray *unitWasSelectedPosition;
@property NSMutableArray *arrayOfMoves;
@property NSMutableArray *arrayOfStates;
@property BOOL bMyTurn;
@property NSString *currentPlayerID;
@property BOOL bankSelected;
@property NSString *unitNameSelectedInBank;
@end

@implementation GameFieldLayer

+(CCScene *) sceneWithDictOfGame:(NSDictionary *) dictOfGame;
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameFieldLayer *layer = [GameFieldLayer node];
	layer.dictOfGame = dictOfGame;
    layer.gameObj = [[GameDictProcessor alloc] initWithDictOfGame:dictOfGame];
    layer.arrayOfStates = [[NSMutableArray alloc] init];
    [layer.arrayOfStates addObject:dictOfGame];
    layer.arrayOfMoves  = [[NSMutableArray alloc] init];
    [layer initObject];
	// add layer as a child to scene
	[scene addChild: layer];
	NSLog(@"pixel winsize: %@", NSStringFromCGSize([[CCDirector sharedDirector] winSizeInPixels]));
    
	// return the scene
	return scene;
}

-(void) initObject {

    CGSize size = [[CCDirector sharedDirector] winSize];
    self.horizontalStep = floor(size.width / 9);
    self.verticalStep = floor(size.height / 6);
    NSLog(@"horizontal step: %i, vertical: %i", self.horizontalStep, self.verticalStep);
    CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"Back" block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    CCMenuItemFont *send = [CCMenuItemFont itemWithString:@"Send" block:^(id sender) {
        if ([self.gameObj isMyTurn:self.currentPlayerID]) {
            DataPoster *poster = [[DataPoster alloc] init];
            [self.gameObj changeTurnToOtherPlayer];
            [poster sendMoves:self.arrayOfMoves forGame:self.gameObj withCallBack:^(BOOL success) {
                NSLog(@"sent moves: %@", success ? @"YES" : @"NO");
            }];
        }
        else {
            NSLog(@"Sending denied: it is not your turn");
        }
    }];
    CCMenu *menu = [[CCMenu alloc] initWithArray:@[back, send]];
    menu.position = ccp(size.width - 50, 10);
    [menu alignItemsHorizontally];
    [self addChild:menu];
    
    for (int i = 0; i < self.gameObj.arrayLeftField.count; i++) {
        [self placeUnit:self.gameObj.arrayLeftField[i] forLeftArmy:YES nationName:[self.gameObj.leftArmy valueForKey:@"nation" ]];
    }
    for (int i = 0; i < self.gameObj.arrayRightField.count; i++) {
        [self placeUnit:self.gameObj.arrayRightField[i] forLeftArmy:NO nationName:[self.gameObj.rightArmy valueForKey:@"nation"]];
    }
    self.currentPlayerID = [[NSUserDefaults standardUserDefaults] stringForKey:@"playerID"];
    self.bMyTurn = [self.gameObj isMyTurn:self.currentPlayerID];
    
    NSArray *arrayBank = [self.gameObj getArrayOfUnitNamesInBankForPlayerID:self.currentPlayerID];
    for (int i = 0; i < arrayBank.count; i++) {
        CCSprite *sprite = [CCSprite spriteWithFile:@"ukraine_infantry.png"];
        int xPos = 0;
        NSString *unitName = (NSString *) arrayBank[i];
        if ([unitName isEqualToString:@"infantry"]) {
            xPos = 0;
        }
        else if ([unitName isEqualToString:@"light_cavalry"]) {
            xPos = 1;
        }
        else if ([unitName isEqualToString:@"heavy_cavalry"]) {
            xPos = 2;
        }
        else if ([unitName isEqualToString:@"veteran"]) {
            xPos = 3;
        }
        else if ([unitName isEqualToString:@"super_unit"]) {
            xPos = 4;
        }
        
        NSArray *positionCoords = [NSArray arrayWithObjects:@(xPos), @(-1), nil];
        CGPoint position = [GameLogic gameToCocosCoordinate:positionCoords hStep:self.horizontalStep vStep:self.verticalStep];
        sprite.position = position;
        [self addChild:sprite];
    }
}

-(void) placeUnit:(NSDictionary *) unit forLeftArmy:(BOOL) leftArmy nationName:(NSString *) nationName {
    NSString *unitName = [unit allKeys][0];
    NSDictionary *unitDetails = [unit objectForKey:unitName];
    NSArray *position = [unitDetails objectForKey:@"position"];
    if (!position) {
        position = [NSArray arrayWithObjects:@(0), @(2), nil];
    }
    CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_infantry.png", nationName]];
    if (!leftArmy) {
        [sprite setScaleX:-1.0];
    }
    CGPoint newPoint = [GameLogic gameToCocosCoordinate:position hStep:self.horizontalStep vStep:self.verticalStep];
    NSLog(@"placing sprite at %@", NSStringFromCGPoint(newPoint));
    sprite.position = newPoint;
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

        
         [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
	return self;
}

#pragma mark - Deal with touch callbacks
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

#pragma mark - Logic for selecting sprites
//method used just to get i and j coordinates of the selected sprite
//then selectSpriteSquareAt:i j is called to actually select the sprite and do all actions
//like select sprite at i and j coordinates, if question selected - mark all sprites of the answer.
-(void) selectSpriteSquareAt:(CGPoint) touchPoint {
    NSLog(@"Entered select spriteSquare At point: %@", NSStringFromCGPoint(touchPoint));
    
    //handle selection in bank
    if (touchPoint.y  < self.verticalStep) {
        NSLog(@"Handling selection in bank section");
        NSArray *pos = [GameLogic cocosToGameCoordinate:touchPoint hStep:self.horizontalStep vStep:self.verticalStep];
        int x = [pos[0] intValue];
        switch (x) {
            case 0:
                self.unitNameSelectedInBank = @"infantry";
                self.bankSelected = YES;
                break;
            case 1:
                self.unitNameSelectedInBank = @"light_cavalry";
                self.bankSelected = YES;
                break;
            case 2:
                self.unitNameSelectedInBank = @"heavy_cavalry";
                self.bankSelected = YES;
                break;
            case 3:
                self.unitNameSelectedInBank = @"veteran";
                self.bankSelected = YES;
                break;
            case 4:
                self.unitNameSelectedInBank = @"super_unit";
                self.bankSelected = YES;
                break;
            default:
                break;
        }
        NSLog(@"Bank selection: %@", self.unitNameSelectedInBank);
        return;
    }
    
    NSArray *selectedPosition = [self.gameObj unitPresentAtPosition:touchPoint winSize:[[CCDirector sharedDirector] winSize] horizontalStep:self.horizontalStep verticalStep:self.verticalStep currentPlayerID:self.currentPlayerID];
    
    /**********Implement visual selection of sprite*************/
    /***********************************************************/
    //if there are 5 turns already - return
    if (self.arrayOfMoves.count >= 5) {
        NSLog(@"Movement denied: There are already 5 moves");
        return;
    }
    //if it is not our turn - return
    if (![self.gameObj isMyTurn:self.currentPlayerID]) {
        NSLog(@"Movement denied: it is not your turn");
        return;
    }
    
    //attack or heal or deselect
    if (self.unitWasSelectedPosition && selectedPosition) {
        //friendly unit was selected on second touch
        //healing
        NSNumber *nFriendlyUnit = (NSNumber *) selectedPosition[2];
        BOOL friendlyUnit = [nFriendlyUnit boolValue];
        if (friendlyUnit) {
            NSLog(@"healing is to be implemented");
        }
        //unfriendly unit was selected
        //attack
        else {
            NSLog(@"Attack is to be implemented");
        }
        //deselect if selected the same unit
        if ([self.unitWasSelectedPosition[0] integerValue] == [selectedPosition[0] integerValue] && [self.unitWasSelectedPosition[1] integerValue] == [selectedPosition[1] integerValue]) {
            self.unitWasSelectedPosition = nil;
            return;
        }
        self.unitWasSelectedPosition = nil;
    }
    //move
    else if (self.unitWasSelectedPosition && !selectedPosition) {
        for (int i = 0; i < self.children.count; i++) {
            //find old sprite which was selected
            CCSprite *node = (CCSprite *) [self.children objectAtIndex:i];
            NSLog(@"Checking node: %@", NSStringFromCGPoint(node.position));
            //calculate old CGPoint by using old game coordinates
            CGPoint oldPoint = CGPointMake([self.unitWasSelectedPosition[0] integerValue] * self.horizontalStep + self.horizontalStep/2, [self.unitWasSelectedPosition[1] integerValue] * self.verticalStep + self.verticalStep + self.verticalStep / 2);
            //calculate new position in game coordinates
            NSArray *newGameCoordinates = [GameLogic cocosToGameCoordinate:touchPoint hStep:self.horizontalStep vStep:self.verticalStep];
            if (CGRectContainsPoint(node.boundingBox, oldPoint)) {
                NSLog(@"found sprite");
                if ([GameLogic canMoveFrom:self.unitWasSelectedPosition to:newGameCoordinates forPlayerID:self.currentPlayerID inGame:self.gameObj]) {
                   
                    CGPoint newPoint = [GameLogic gameToCocosCoordinate:newGameCoordinates hStep:self.horizontalStep vStep:self.verticalStep];
                    // CGPoint newPoint = CGPointMake(, [self.unitWasSelectedPosition[1] integerValue] * self.verticalStep + self.verticalStep);
                   ////// node.position = newPoint;
                    //update gameObj dictionary with new position of unit
                    //add gameObj to arrayOfMoves
                    //this array contains initial position of unit and its target action;
                    //we need to add only coordinates to array of moves.
                    NSArray *arrayWithoutBool = [[NSArray alloc] initWithObjects:self.unitWasSelectedPosition[0], self.unitWasSelectedPosition[1], nil];
                    NSArray *arrayOfPositionsInMove = [NSArray arrayWithObjects:arrayWithoutBool, newGameCoordinates, nil];
                    
                    [self.arrayOfMoves addObject:arrayOfPositionsInMove];
                    [self.arrayOfStates addObject:self.gameObj.dictOfGame];
                    NSDictionary *newDictOfGame = [GameLogic applyMove:arrayOfPositionsInMove toGame:self.gameObj forPlayerID:self.currentPlayerID];
                    self.gameObj = nil;
                    self.gameObj = [[GameDictProcessor alloc] initWithDictOfGame:newDictOfGame];
                    [self removeAllChildren];
                    [self initObject];
                    self.unitWasSelectedPosition = nil;
                    return;
                }
                else {
                    NSLog(@"Denied movement of unit");
                    return;
                }
             
            }
        }
        self.unitWasSelectedPosition = nil;
    }
    //first selection
    else if (!self.unitWasSelectedPosition && selectedPosition) {
        //remember only if friendly unit was selected;
        NSNumber *nFriendlyUnit = (NSNumber *) selectedPosition[2];
        BOOL friendlyUnit = [nFriendlyUnit boolValue];
        if (friendlyUnit)
            self.unitWasSelectedPosition = selectedPosition;
    }
    //placing new unit on board
    else if (self.bankSelected && !selectedPosition) {
        NSLog(@"Placing new unit");
        self.bankSelected = NO;
        [self placeUnit:[UkraineInfo infantry] forLeftArmy:[[self.gameObj leftPlayerID] isEqualToString:self.currentPlayerID]  nationName:@"ukraine"];
        self.unitNameSelectedInBank = nil;
    }
}
#pragma mark - Build bank sprites
-(void) buildBankMenu {
    NSArray *arrayOfUnitsInBank = [self.gameObj getArrayOfUnitNamesInBankForPlayerID:self.currentPlayerID];
}

@end