//
//  GameDictProcessor.h
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/18/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameDictProcessor : NSObject

-(GameDictProcessor *) initWithDictOfGame:(NSDictionary *) dictOfGame;

/*-(NSDictionary *) getLeftArmy;
-(NSDictionary *) getRightArmy;
-(NSArray *) getLeftField;
-(NSArray *) getRightField;*/
@property (assign) NSDictionary *leftArmy;
@property (assign) NSDictionary *rightArmy;
@property (assign) NSArray *arrayLeftField;
@property (assign) NSArray *arrayRightField;
-(BOOL) unitPresentAtPosition:(CGPoint ) spritePoint winSize:(CGSize) winSize horizontalStep:(int) hStep verticalStep:(int) vStep;
@end
