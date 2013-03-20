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
    }
    return game;
}

-(NSDictionary *) getLeftArmy {
    NSString *leftArmyPlayerID = [self.dictOfGame valueForKey:@"player_left"];
    return [self.dictOfGame objectForKey:leftArmyPlayerID];
}

-(NSDictionary *) getRightArmy {
    NSString *rightArmyPlayerID = [self.dictOfGame valueForKey:@"player_right"];
    return [self.dictOfGame objectForKey:rightArmyPlayerID];
}

-(NSArray *) getLeftField {
    NSArray *arrayOfFieldUnits = [[self getLeftArmy] objectForKey:@"field"];
    return arrayOfFieldUnits;
}

-(NSArray *) getRightField {
    NSArray *arrayOfFieldUnits = [[self getRightArmy] objectForKey:@"field"];
    return arrayOfFieldUnits;
}


@end
