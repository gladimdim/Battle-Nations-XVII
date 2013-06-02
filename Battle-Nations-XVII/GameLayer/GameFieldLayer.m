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
#import "Animator.h"

@interface GameFieldLayer()

@property int horizontalStep;
@property int verticalStep;
@property (strong) GameDictProcessor *gameObj;
@property CGPoint lastTouchedPoint;
@property BOOL moving;
@property (strong) NSArray *unitWasSelectedPosition;
@property NSMutableArray *arrayOfMoves;
@property (strong) NSMutableArray *arrayOfStates;
@property BOOL bMyTurn;
@property NSString *currentPlayerID;
@property BOOL bankSelected;
@property NSString *unitNameSelectedInBank;
@property (strong) CCSprite *selectedSprite;
@property (strong) GameDictProcessor *downloadedGameObj;
@end

@implementation GameFieldLayer

+(CCScene *) sceneWithDictOfGame:(NSDictionary *) dictOfGame;
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameFieldLayer *layer = [GameFieldLayer node];
	//layer.dictOfGame = dictOfGame;
    layer.gameObj = [[GameDictProcessor alloc] initWithDictOfGame:dictOfGame];
    layer.downloadedGameObj = [[GameDictProcessor alloc] initWithDictOfGame:dictOfGame];
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

-(void) playPreviousMoves {
    
}

-(void) initObject {
    CGSize size = [[CCDirector sharedDirector] winSize];
    self.horizontalStep = floor(size.width / 9);
    self.verticalStep = floor(size.height / 6);
    NSLog(@"horizontal step: %i, vertical: %i", self.horizontalStep, self.verticalStep);
    CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"Back" block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    self.currentPlayerID = [[NSUserDefaults standardUserDefaults] stringForKey:@"playerID"];
    self.bMyTurn = [self.gameObj isMyTurn:self.currentPlayerID];
    CCMenuItemFont *send = [CCMenuItemFont itemWithString:@"Send" block:^(id sender) {
        /*if ([self.gameObj isMyTurn:self.currentPlayerID]) {
            DataPoster *poster = [[DataPoster alloc] init];
            [self.gameObj changeTurnToOtherPlayer];
            [poster sendMoves:self.arrayOfMoves forGame:self.gameObj withCallBack:^(BOOL success) {
                NSLog(@"Sent moves: %@", success ? @"YES" : @"NO");
            }];
        }
        else {
            NSLog(@"Sending denied: it is not your turn");
        }*/
        [self replayMoves];
    }];
    
    CCMenuItemFont *undoTurn = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%i/%i", self.arrayOfMoves.count, self.bMyTurn ? 5 : 0] block:^(id sender) {
        if (self.arrayOfMoves.count > 0) {
            NSLog(@"moves: %i, states: %i", self.arrayOfMoves.count, self.arrayOfStates.count);
            [self.arrayOfMoves removeLastObject];
            [self.arrayOfStates removeLastObject];
            self.gameObj = [[GameDictProcessor alloc] initWithDictOfGame:[self.arrayOfStates lastObject]];
            [self removeAllChildren];
            [self initObject];
        }
    }];
    
    CCMenu *menu = [[CCMenu alloc] initWithArray:@[undoTurn, back, send]];
    menu.position = [GameLogic gameToCocosCoordinate:@[@(7), @(-1)]];// ccp(size.width - 100, 10);
    [menu alignItemsHorizontally];
    [self addChild:menu];
    
    for (int i = 0; i < self.gameObj.arrayLeftField.count; i++) {
        [self placeUnit:self.gameObj.arrayLeftField[i] forLeftArmy:YES nationName:[self.gameObj.leftArmy valueForKey:@"nation" ]];
    }
    for (int i = 0; i < self.gameObj.arrayRightField.count; i++) {
        [self placeUnit:self.gameObj.arrayRightField[i] forLeftArmy:NO nationName:[self.gameObj.rightArmy valueForKey:@"nation"]];
    }
    
    //show bank units
    NSArray *arrayBank = [self.gameObj getArrayOfUnitNamesInBankForPlayerID:self.currentPlayerID];
    for (int i = 0; i < arrayBank.count; i++) {
        CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_%@.png", [self.gameObj nationForPlayerID:self.currentPlayerID], arrayBank[i]]];
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
        else if ([unitName isEqualToString:@"healer"]) {
            xPos = 4;
        }
        else if ([unitName isEqualToString:@"super_unit"]) {
            xPos = 5;
        }
        
        NSArray *positionCoords = [NSArray arrayWithObjects:@(xPos), @(-1), nil];
        CGPoint position = [GameLogic gameToCocosCoordinate:positionCoords];
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
    CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_%@.png", nationName, unitName]];
    if (!leftArmy) {
        //[sprite setScaleX:-1.0];
        [sprite setFlipX:YES];
    }
    CGPoint newPoint = [GameLogic gameToCocosCoordinate:position];
   // NSLog(@"placing sprite at %@ [%@]", NSStringFromCGPoint(newPoint), position);
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
    
    //find what sprite was touched
    for (int i = 0; i < [self children].count; i++) {
        CCSprite *sprite = (CCSprite *) [[self children] objectAtIndex:i];
        if (CGRectContainsPoint([sprite boundingBox], touchPoint)) {
            [Animator animateSpriteDeselection:self.selectedSprite];
            self.selectedSprite = sprite;
        }
    }

    //handle selection in bank
    if (touchPoint.y  < self.verticalStep) {
        NSLog(@"Handling selection in bank section");
        NSArray *pos = [GameLogic cocosToGameCoordinate:touchPoint];
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
                self.unitNameSelectedInBank = @"healer";
                self.bankSelected = YES;
                break;
            case 5:
                self.unitNameSelectedInBank = @"super_unit";
                self.bankSelected = YES;
                break;
            default:
                break;
        }
        self.unitWasSelectedPosition = nil;
        NSLog(@"Bank selection: %@", self.unitNameSelectedInBank);
        [Animator animateSpriteSelection:self.selectedSprite];
        return;
    }
    
    NSArray *positionOfSelectedUnit = [self.gameObj unitPresentAtPosition:touchPoint winSize:[[CCDirector sharedDirector] winSize] horizontalStep:self.horizontalStep verticalStep:self.verticalStep currentPlayerID:self.currentPlayerID];
    //deselect if selected the same unit. Then return.
    if (positionOfSelectedUnit) {
        if ([self.unitWasSelectedPosition[0] integerValue] == [positionOfSelectedUnit[0] integerValue] && [self.unitWasSelectedPosition[1] integerValue] == [positionOfSelectedUnit[1] integerValue]) {
            self.unitWasSelectedPosition = nil;
            [Animator animateSpriteDeselection:self.selectedSprite];
            return;
        }
    }
    //if there are 6 states (5 + 1 because the initial position counts as state) already - return
    if (self.arrayOfStates.count >= 6) {
        NSLog(@"Movement denied: There are already 5 moves");
        return;
    }
    //if it is not our turn - return
    if (![self.gameObj isMyTurn:self.currentPlayerID]) {
        NSLog(@"Movement denied: it is not your turn");
        return;
    }
    
    //attack or heal or deselect
    BOOL healerPresent = [GameLogic healerPresentAt:self.unitWasSelectedPosition forGame:self.gameObj forPlayerID:self.currentPlayerID];
    if (self.unitWasSelectedPosition && positionOfSelectedUnit) {
        //friendly unit was selected on second touch
        //healing
        NSNumber *nFriendlyUnit = (NSNumber *) positionOfSelectedUnit[2];
        BOOL friendlyUnit = [nFriendlyUnit boolValue];
        if (friendlyUnit && healerPresent) {
            [Animator animateSpriteDeselection:self.selectedSprite];
            BOOL canHeal = [GameLogic canAttackFrom:self.unitWasSelectedPosition to:positionOfSelectedUnit forPlayerID:self.currentPlayerID inGame:self.gameObj];
            if (canHeal) {
                NSDictionary *newDictOfGame = [GameLogic healUnitFrom:self.unitWasSelectedPosition fromPlayerID:self.currentPlayerID toUnit:positionOfSelectedUnit forGame:self.gameObj];
                
                if (newDictOfGame) {
                    GameDictProcessor *newGameObj = [[GameDictProcessor alloc] initWithDictOfGame:newDictOfGame];
                    NSArray *arrayWithoutBool = @[self.unitWasSelectedPosition[0], self.unitWasSelectedPosition[1]];
                    [self.arrayOfMoves addObject:@[arrayWithoutBool, positionOfSelectedUnit]];
                    self.gameObj = newGameObj;
                    [self.arrayOfStates addObject:self.gameObj.dictOfGame];
                    [self removeAllChildren];
                    [self initObject];
                    self.unitNameSelectedInBank = nil;
                    self.unitWasSelectedPosition = nil;
                }
            }
            else {
                NSLog(@"Cannot attack.");
            }
        }
        //enemy unit was selected
        //attack if not healer
        else if (!healerPresent) {
            BOOL canAttack = [GameLogic canAttackFrom:self.unitWasSelectedPosition to:positionOfSelectedUnit forPlayerID:self.currentPlayerID inGame:self.gameObj];
            if (canAttack) {
                NSDictionary *newDictOfGame = [GameLogic attackUnitFrom:self.unitWasSelectedPosition fromPlayerID:self.currentPlayerID toUnit:positionOfSelectedUnit forGame:self.gameObj];
                if (newDictOfGame) {
                    GameDictProcessor *newGameObj = [[GameDictProcessor alloc] initWithDictOfGame:newDictOfGame];
                    NSArray *arrayWithoutBool = @[self.unitWasSelectedPosition[0], self.unitWasSelectedPosition[1]];
                    [self.arrayOfMoves addObject:@[arrayWithoutBool, positionOfSelectedUnit]];
                    self.gameObj = newGameObj;
                    [self.arrayOfStates addObject:self.gameObj.dictOfGame];
                    [self removeAllChildren];
                    [self initObject];
                    self.unitNameSelectedInBank = nil;
                    self.unitWasSelectedPosition = nil;
                }
            }
            else {
                NSLog(@"Cannot attack.");
            }

        }
        self.unitWasSelectedPosition = nil;
    }
    //move
    else if (self.unitWasSelectedPosition && !positionOfSelectedUnit) {
        for (int i = 0; i < self.children.count; i++) {
            //find old sprite which was selected
            CCSprite *node = (CCSprite *) [self.children objectAtIndex:i];
            NSLog(@"Checking node: %@", NSStringFromCGPoint(node.position));
            //calculate old CGPoint by using old game coordinates
            CGPoint oldPoint = CGPointMake([self.unitWasSelectedPosition[0] integerValue] * self.horizontalStep + self.horizontalStep/2, [self.unitWasSelectedPosition[1] integerValue] * self.verticalStep + self.verticalStep + self.verticalStep / 2);
            //calculate new position in game coordinates
            NSArray *newGameCoordinates = [GameLogic cocosToGameCoordinate:touchPoint];
            if (CGRectContainsPoint(node.boundingBox, oldPoint)) {
                NSLog(@"found sprite");
                if ([GameLogic canMoveFrom:self.unitWasSelectedPosition to:newGameCoordinates forPlayerID:self.currentPlayerID inGame:self.gameObj]) {
                    //run animation of sprite's move. When animation is done - do necessary tasks to update gameObj with new coordinates.
                    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:0.5f position:[GameLogic gameToCocosCoordinate:newGameCoordinates]];
                    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
                        //update gameObj dictionary with new position of unit
                        //add gameObj to arrayOfMoves
                        //this array contains initial position of unit and its target action;
                        //we need to add only coordinates to array of moves.
                        NSArray *arrayWithoutBool = @[self.unitWasSelectedPosition[0], self.unitWasSelectedPosition[1]];
                        NSArray *arrayOfPositionsInMove = @[arrayWithoutBool, newGameCoordinates];
                        NSDictionary *newDictOfGame = [GameLogic applyMove:arrayOfPositionsInMove toGame:self.gameObj forPlayerID:self.currentPlayerID];
                        self.gameObj = [[GameDictProcessor alloc] initWithDictOfGame:newDictOfGame];
                        [self.arrayOfMoves addObject:arrayOfPositionsInMove];
                        [self.arrayOfStates addObject:self.gameObj.dictOfGame];
                        [self removeAllChildren];
                        [self initObject];
                        self.unitWasSelectedPosition = nil;
                    }];
                    [self.selectedSprite runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
                    
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
    else if (!self.unitWasSelectedPosition && positionOfSelectedUnit) {
        //remember only if friendly unit was selected;
        NSNumber *nFriendlyUnit = (NSNumber *) positionOfSelectedUnit[2];
        BOOL friendlyUnit = [nFriendlyUnit boolValue];
        if (friendlyUnit) {
            self.unitWasSelectedPosition = positionOfSelectedUnit;
            [Animator animateSpriteSelection:self.selectedSprite];
            NSArray *arr = [Animator createHealthBarsForFieldInGame:self.gameObj];
            for (int i = 0; i < arr.count; i++) {
                [self addChild:arr[i]];
            }
        }
    }
    //placing new unit on board
    else if (self.bankSelected && !positionOfSelectedUnit) {
        NSArray *proposedPosition = [NSMutableArray arrayWithArray:[GameLogic cocosToGameCoordinate:touchPoint]];
        [self placeNewUnitOnBoardForGame:self.gameObj unitName:self.unitNameSelectedInBank proposedPosition:proposedPosition forPlayerID:self.currentPlayerID];
    }
}

//places new unit on board from bank and creates new GameDictProcessor which is assigned to self
-(void) placeNewUnitOnBoardForGame:(GameDictProcessor *) gameObjLocal unitName:(NSString *) unitName proposedPosition:(NSArray *) proposedPositionFromCGPoint forPlayerID:(NSString *) playerID{
    if ([gameObjLocal checkBankQtyForPlayerID:self.currentPlayerID unit:unitName]) {
        NSLog(@"Placing new unit");
        //calculate if final destination is from two allowed positions for left/right player.
        NSSet *allowedCoordinates = [GameLogic getCoordinatesForNewUnitForGame:gameObjLocal forPlayerID:playerID];
        NSMutableArray *proposedPosition = [NSMutableArray arrayWithArray:proposedPositionFromCGPoint];
        if ([allowedCoordinates containsObject:proposedPosition]) {
            NSLog(@"Placing unit. Specified valid final coordinate.");
            NSDictionary *newDictOfGame = [GameLogic placeNewUnit:unitName forGame:gameObjLocal forPlayerID:playerID atPosition:proposedPosition];
            //pay attention that we add array with only one object - array of final destination
            //in future we will have to check if there is only one member in arrayOfMoves - it means we are placing new unit on board
            /////// [proposedPosition addObject:self.unitNameSelectedInBank];
            [self.arrayOfMoves addObject:proposedPosition];
            self.gameObj = [[GameDictProcessor alloc] initWithDictOfGame:newDictOfGame];
            self.bankSelected = NO;
            //[self placeUnit:[UkraineInfo infantry] forLeftArmy:[[self.gameObj leftPlayerID] isEqualToString:self.currentPlayerID]  nationName:@"ukraine"];
            self.unitNameSelectedInBank = nil;
            [self.arrayOfStates addObject:gameObjLocal.dictOfGame];
            [self removeAllChildren];
            [self initObject];
        }
        else {
            NSLog(@"Placing unit failed: specified final coordinate which is not allowed.");
            return;
        }
    }
    else {
        NSLog(@"Not enough qty for unit %@", self.unitNameSelectedInBank);
        self.unitNameSelectedInBank = nil;
        self.unitWasSelectedPosition = NO;
    }

}


-(void) replayMoves {
    
    NSArray *arrayLastMoves = [self.gameObj arrayOfPreviousMoves];
    GameDictProcessor *initialGameObj = [[GameDictProcessor alloc] initWithDictOfGame:[[self.downloadedGameObj initialTable] objectForKey:@"game"]];
    self.gameObj = initialGameObj;
    [self removeAllChildren];
    [self initObject];
    [self makeMoveFromReplay:self.gameObj arrayOfMoves:[NSMutableArray arrayWithArray:arrayLastMoves]];
}

-(void) makeMoveFromReplay:(GameDictProcessor *) gameObject arrayOfMoves:(NSMutableArray *) arrayLastMoves {
    if (arrayLastMoves.count == 0) {
        self.unitNameSelectedInBank = nil;
        self.unitWasSelectedPosition = nil;
        self.bankSelected = nil;
        self.arrayOfMoves = [[NSMutableArray alloc] init];
        self.arrayOfStates = [[NSMutableArray alloc] init];
        [self.arrayOfStates addObject:self.downloadedGameObj.dictOfGame];
        [self removeAllChildren];
        self.gameObj = self.downloadedGameObj;
        [self initObject];
        return;
    }
    else {
        NSArray *move = [arrayLastMoves objectAtIndex:0];
        if ([move[0] isKindOfClass:[NSArray class]]) {
            NSLog(@"kuku");
            [arrayLastMoves removeObjectAtIndex:0];
            [self makeMoveFromReplay:self.gameObj arrayOfMoves:arrayLastMoves];
        }
        else {
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self placeNewUnitOnBoardForGame:self.gameObj unitName:@"infantry" proposedPosition:move forPlayerID:[self.gameObj oppositePlayerID:self.currentPlayerID]];
                [arrayLastMoves removeObjectAtIndex:0];
                [self makeMoveFromReplay:self.gameObj arrayOfMoves:arrayLastMoves];
            });
            
        }

    }
}


@end