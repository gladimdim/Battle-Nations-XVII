//
//  GameLogic.h
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/23/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameDictProcessor.h"

@interface GameLogic : NSObject
+(CGPoint) gameToCocosCoordinate:(NSArray *) position hStep:(int) hStep vStep:(int) vStep;

+(NSArray *) cocosToGameCoordinate:(CGPoint) position hStep:(int) hStep vStep:(int) vStep;
+(NSDictionary *) applyMove:(NSArray *) arrayOfActionsInMove toGame:(GameDictProcessor *) gameObj forPlayerID:(NSString *) playerID;
+(BOOL) canMoveFrom:(NSArray *) initPosition to:(NSArray *) destPosition forPlayerID:(NSString *) playerID inGame:(GameDictProcessor *) gameObj;
@end
