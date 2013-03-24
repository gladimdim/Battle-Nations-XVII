//
//  GameLogic.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/23/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "GameLogic.h"
#import "GameDictProcessor.h"
#import "cocos2d.h"

@implementation GameLogic

+(CGPoint) gameToCocosCoordinate:(NSArray *) position hStep:(int) hStep vStep:(int) vStep{
    int x = [position[0] intValue] * hStep;
    int y = [position[1] intValue] * vStep + vStep;
    x = x + hStep /2;
    y = y + vStep / 2;
    NSLog(@"placing sprite at %i %i", x, y);
    return ccp(x, y);
}

+(NSArray *) cocosToGameCoordinate:(CGPoint) position hStep:(int) hStep vStep:(int) vStep{
    NSUInteger x = floor(position.x / hStep);
    NSUInteger y = floor(position.y / vStep) -1;
    NSArray *array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:x], [NSNumber numberWithInteger:y], nil];
    return array;
}

+(NSDictionary *) applyMove:(NSArray *) arrayOfActionsInMove toGame:(GameDictProcessor *) gameObj {
    NSMutableDictionary *dictGame = [NSMutableDictionary dictionaryWithDictionary:gameObj.dictOfGame];
    NSMutableArray *leftField = [NSMutableArray arrayWithArray:[gameObj arrayLeftField]];
    NSArray *initPosition = arrayOfActionsInMove[0];
    NSArray *targetPosition = arrayOfActionsInMove[1];
    for (int i = 0; i < leftField.count; i++) {
        NSString *unitName = [leftField[i] allKeys][0];
        NSMutableDictionary *unitDict = [NSMutableDictionary dictionaryWithDictionary:leftField[i]];
        NSMutableDictionary *unitDetails = [NSMutableDictionary dictionaryWithDictionary:[unitDict objectForKey:unitName]];
        NSMutableArray *position = [NSMutableArray arrayWithArray:[unitDetails objectForKey:@"position"]];
        if (position[0] == initPosition[0] && position[1] == initPosition[1])  {
            [unitDetails setObject:targetPosition forKey:@"position"];
            [unitDict setObject:unitDetails forKey:unitName];
            [leftField setObject:unitDict atIndexedSubscript:i];
//            leftField[i] = unitDict;
            NSString *leftArmyPlayerID = [dictGame valueForKey:@"player_left"];
            NSMutableDictionary *armyDict = [NSMutableDictionary dictionaryWithDictionary:[dictGame objectForKey:leftArmyPlayerID]];
            [armyDict setObject:leftField forKey:@"field"];
            [dictGame setObject:armyDict forKey:leftArmyPlayerID];
            return dictGame;
        }
    }
    return [NSDictionary dictionaryWithDictionary:dictGame];
    
}
@end
