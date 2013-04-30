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
#import "UkraineInfo.h"

@implementation GameLogic

+(CGPoint) gameToCocosCoordinate:(NSArray *) position hStep:(int) hStep vStep:(int) vStep{
    int x = [position[0] intValue] * hStep;
    int y = [position[1] intValue] * vStep + vStep;
    x = x + hStep /2;
    y = y + vStep / 2;
    return ccp(x, y);
}

+(NSArray *) cocosToGameCoordinate:(CGPoint) position hStep:(int) hStep vStep:(int) vStep{
    NSUInteger x = floor(position.x / hStep);
    NSUInteger y = floor(position.y / vStep) -1;
    NSArray *array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:x], [NSNumber numberWithInteger:y], nil];
    return array;
}

//returns updated gameObj. Moves unit from one pos to another
+(NSDictionary *) applyMove:(NSArray *) arrayOfActionsInMove toGame:(GameDictProcessor *) gameObj forPlayerID:(NSString *) playerID {
    NSMutableDictionary *dictGame = [NSMutableDictionary dictionaryWithDictionary:gameObj.dictOfGame];
    NSMutableArray *field = [NSMutableArray arrayWithArray:[gameObj getFieldForPlayerID:playerID]];
    NSArray *initPosition = arrayOfActionsInMove[0];
    NSArray *targetPosition = arrayOfActionsInMove[1];
    for (int i = 0; i < field.count; i++) {
        NSString *unitName = [field[i] allKeys][0];
        NSMutableDictionary *unitDict = [NSMutableDictionary dictionaryWithDictionary:field[i]];
        NSMutableDictionary *unitDetails = [NSMutableDictionary dictionaryWithDictionary:[unitDict objectForKey:unitName]];
        NSMutableArray *position = [NSMutableArray arrayWithArray:[unitDetails objectForKey:@"position"]];
        if (position[0] == initPosition[0] && position[1] == initPosition[1])  {
            [unitDetails setObject:targetPosition forKey:@"position"];
            [unitDict setObject:unitDetails forKey:unitName];
            [field setObject:unitDict atIndexedSubscript:i];
//            leftField[i] = unitDict;
            NSMutableDictionary *armyDict = [NSMutableDictionary dictionaryWithDictionary:[dictGame objectForKey:playerID]];
            [armyDict setObject:field forKey:@"field"];
            [dictGame setObject:armyDict forKey:playerID];
            return dictGame;
        }
    }
    return [NSDictionary dictionaryWithDictionary:dictGame];
    
}

+(BOOL) canMoveFrom:(NSArray *) initPosition to:(NSArray *) destPosition forPlayerID:(NSString *) playerID inGame:(GameDictProcessor *) gameObj {
    NSDictionary *dictArmy = (NSDictionary *) [gameObj.dictOfGame objectForKey:playerID];
    if (dictArmy) {
        NSArray *field = (NSArray *) [dictArmy objectForKey:@"field"];
        for (int i = 0; i < field.count; i++) {
            NSDictionary *topUnit = (NSDictionary *) field[i];
            NSDictionary *unit = [topUnit objectForKey:[topUnit allKeys][0]];
            NSArray *position = (NSArray *) [unit objectForKey:@"position"];
            if (position[0] == initPosition[0] && position[1] == initPosition[1]) {
                NSInteger distance = abs([initPosition[0] integerValue] - [destPosition[0] integerValue]) + fabs( [initPosition[1] integerValue] - [destPosition[1] integerValue]);
                NSInteger rangeMove = [[unit valueForKey:@"range_move"] integerValue];
                return rangeMove >= distance;
            }
            else {
                continue;
            }
        }
    }
    return NO;
}

+(NSDictionary *) placeNewUnit:(NSString *) unitName forGame:(GameDictProcessor *) gameObj forPlayerID:(NSString *) playerID atPosition:(NSArray *) coords {
    NSMutableDictionary *dictBank = [NSMutableDictionary dictionaryWithDictionary:[gameObj getBankForPlayerID:playerID]];
    NSNumber *amountOfUnits = [dictBank objectForKey:unitName];
    amountOfUnits = [NSNumber numberWithInt:[amountOfUnits intValue] - 1];
    [dictBank setObject:amountOfUnits forKey:unitName];
    NSMutableDictionary *dictOfGame = [NSMutableDictionary dictionaryWithDictionary:gameObj.dictOfGame];
    NSMutableDictionary *dictPlayer = [NSMutableDictionary dictionaryWithDictionary:[dictOfGame objectForKey:playerID]];
    [dictPlayer setObject:dictBank forKey:@"bank"];
    NSMutableArray *fieldArray = [NSMutableArray arrayWithArray:[gameObj getFieldForPlayerID:playerID]];
    SEL s = NSSelectorFromString(unitName);
    NSMutableDictionary *dictNewUnit = [NSMutableDictionary dictionaryWithDictionary:[[[UkraineInfo alloc] init] performSelector:s]];
    NSMutableDictionary *dictNaked = [NSMutableDictionary dictionaryWithDictionary:[dictNewUnit objectForKey:unitName]];
    [dictNaked setObject:coords forKey:@"position"];
    //pack coordinates into new unit
    [dictNewUnit setObject:dictNaked forKey:unitName];
    
    //pack new unit into field
    [fieldArray addObject:dictNewUnit];
    //pack new field into player's dict
    [dictPlayer setObject:fieldArray forKey:@"field"];
    //pack new player dict into final dict
    [dictOfGame setObject:dictPlayer forKey:playerID];
    NSLog(@"placing new unit");
    return dictOfGame;
}

+(NSSet *) getCoordinatesForNewUnitForGame:(GameDictProcessor *) gameObj forPlayerID:(NSString *) playerID {
    NSDictionary *dictOfGame = gameObj.dictOfGame;
    NSString *leftPlayer = [dictOfGame valueForKey:@"player_left"];
    if ([playerID isEqualToString:leftPlayer]) {
        return [NSSet setWithObjects:@[@(0), @(1)], @[@(0), @(3)], nil];
    }
    else {
        return [NSSet setWithObjects:@[@(8), @(1)], @[@(8), @(3)], nil];
    }
}

@end
