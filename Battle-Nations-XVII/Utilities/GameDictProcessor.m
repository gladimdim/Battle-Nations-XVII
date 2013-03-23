//
//  GameDictProcessor.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/18/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "GameDictProcessor.h"

@interface GameDictProcessor()
@property NSDictionary *dictOfGame;
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

-(BOOL) unitPresentAtPosition:(CGPoint ) spritePoint winSize:(CGSize) winSize horizontalStep:(int) hStep verticalStep:(int) vStep {
    
    NSUInteger x = floor(spritePoint.x / hStep);
    NSUInteger y = floor(spritePoint.y / vStep) - 1;
    NSLog(@"unitPresentAtPos x: %i, y: %i", x, y);
    for (int i = 0; i < self.arrayLeftField.count; i++) {
        NSString *unitName = [self.arrayLeftField[i] allKeys][0];
        NSDictionary *unitDetails = [self.arrayLeftField[i] objectForKey:unitName];
        NSArray *position = [unitDetails objectForKey:@"position"];
        NSUInteger posX = (NSUInteger) [position[0] integerValue];
        NSUInteger posY = (NSUInteger) [position[1] integerValue];
        if (posX == x && posY == y) {
            return true;
        }
    }
    for (int i = 0; i < self.arrayRightField.count; i++) {
        NSString *unitName = [self.arrayRightField[i] allKeys][0];
        NSDictionary *unitDetails = [self.arrayRightField[i] objectForKey:unitName];
        NSArray *position = [unitDetails objectForKey:@"position"];
        if ((int)position[0] == x && (int)position[1] == y) {
            return true;
        }
    }
    return false;
}
@end
