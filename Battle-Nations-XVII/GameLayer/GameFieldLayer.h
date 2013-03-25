//
//  GameFieldLayer.h
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/17/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"

@interface GameFieldLayer : CCLayer
+(CCScene *) sceneWithDictOfGame:(NSDictionary *) dictOfGame;
@property (strong) NSDictionary *dictOfGame;
@end
