//
//  Animator.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 5/11/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "Animator.h"

@implementation Animator
+(void) animateSpriteSelection:(CCSprite *)sprite {
    //fabsf is needed as our scale may have negative values (when sprite is flipped).
    NSLog(@"increase fabs: %f", sprite.scaleX);
    if (sprite && fabsf(sprite.scaleX) <= 1.0) {
        [sprite runAction:[CCScaleBy actionWithDuration:0.3f scale:1.3f]];
    }
}

+(void) animateSpriteDeselection:(CCSprite *)sprite {
    NSLog(@"increase fabs: %f", sprite.scaleX);
    if (sprite && fabsf(sprite.scaleX) > 1.0) {
        [sprite runAction:[CCScaleBy actionWithDuration:0.3f scale:0.76f]];
    }
}

@end
