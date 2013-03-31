//
//  GameDictProcessor.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/18/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "GameDictProcessor.h"
#import "GameLogic.h"

@interface GameDictProcessor()
//@property NSDictionary *dictOfGame;
@end

@implementation GameDictProcessor

-(GameDictProcessor *) initWithDictOfGame:(NSDictionary *) dictOfGame {
    GameDictProcessor *game = [[GameDictProcessor alloc] init];
    
    if (dictOfGame) {
        game.dictOfGame = dictOfGame;
        NSString *leftArmyPlayerID = [game.dictOfGame valueForKey:@"player_left"];
        game.leftArmy = [game.dictOfGame objectForKey:leftArmyPlayerID];
        NSString *rightArmyPlayerID = [game.dictOfGame valueForKey:@"player_right"];
        game.rightArmy = [game.dictOfGame objectForKey:rightArmyPlayerID];
        game.arrayLeftField = [game.leftArmy objectForKey:@"field"];
        game.arrayRightField = [game.rightArmy objectForKey:@"field"];
    }
    return game;
}

//checks if touched point contains friendly/enemy unit.
//Returns array with three objects: first two are game coordinates, the third one is NSNumber with bool value. BOOL represents if friendly unit was selected
-(NSArray *) unitPresentAtPosition:(CGPoint ) spritePoint winSize:(CGSize) winSize horizontalStep:(int) hStep verticalStep:(int) vStep currentPlayerID:(NSString *) playerID {
    NSArray *gameCoordinates = [GameLogic cocosToGameCoordinate:spritePoint hStep:hStep vStep:vStep];
    NSUInteger x = [gameCoordinates[0] integerValue]; //floor(spritePoint.x / hStep);
    NSUInteger y = [gameCoordinates[1] integerValue]; //floor(spritePoint.y / vStep) - 1;
    NSLog(@"unitPresentAtPos x: %i, y: %i", x, y);
    for (int i = 0; i < self.arrayLeftField.count; i++) {
        NSString *unitName = [self.arrayLeftField[i] allKeys][0];
        NSDictionary *unitDetails = [self.arrayLeftField[i] objectForKey:unitName];
        NSArray *position = [unitDetails objectForKey:@"position"];
        NSUInteger posX = (NSUInteger) [position[0] integerValue];
        NSUInteger posY = (NSUInteger) [position[1] integerValue];
        if (posX == x && posY == y) {
            BOOL friendlyUnit = [[self.dictOfGame valueForKey:@"player_left"] isEqualToString:playerID];
            NSMutableArray *arrayToReturn = [NSMutableArray arrayWithArray:position];
            [arrayToReturn addObject:[NSNumber numberWithBool:friendlyUnit]];
            return arrayToReturn;
        }
    }
    for (int i = 0; i < self.arrayRightField.count; i++) {
        NSString *unitName = [self.arrayRightField[i] allKeys][0];
        NSDictionary *unitDetails = [self.arrayRightField[i] objectForKey:unitName];
        NSArray *position = [unitDetails objectForKey:@"position"];
        NSUInteger posX = (NSUInteger) [position[0] integerValue];
        NSUInteger posY = (NSUInteger) [position[1] integerValue];
        if (posX == x && posY == y) {
            BOOL friendlyUnit = [[self.dictOfGame valueForKey:@"player_right"] isEqualToString:playerID];
            NSMutableArray *arrayToReturn = [NSMutableArray arrayWithArray:position];
            [arrayToReturn addObject:[NSNumber numberWithBool:friendlyUnit]];
            return arrayToReturn;
        }
    }
    return nil;
}

-(BOOL) isMyTurn:(NSString *) playerID {
    BOOL leftPlayerTurn = [self.dictOfGame valueForKey:@"left_army_turn"]; //[[self.gameObj.dictOfGame valueForKey:@"left_army_turn"] isEqualToString:@"true"] ? YES: NO;
    return ([playerID isEqualToString:[self.dictOfGame valueForKey:@"player_left"]] && leftPlayerTurn);
}


@end
