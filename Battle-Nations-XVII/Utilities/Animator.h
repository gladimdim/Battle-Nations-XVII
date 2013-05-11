//
//  Animator.h
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 5/11/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface Animator : NSObject
+(void) animateSpriteSelection:(CCSprite *) sprite;
+(void) animateSpriteDeselection:(CCSprite *) sprite;
@end
