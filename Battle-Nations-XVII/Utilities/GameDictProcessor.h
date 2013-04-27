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
@property (strong) NSDictionary *dictOfGame;
@property (strong) NSDictionary *leftArmy;
@property (strong) NSDictionary *rightArmy;
@property (strong) NSArray *arrayLeftField;
@property (strong) NSArray *arrayRightField;
@property (strong) NSArray *leftBank;
@property (strong) NSArray *rightBank;

-(NSArray *) unitPresentAtPosition:(CGPoint ) spritePoint winSize:(CGSize) winSize horizontalStep:(int) hStep verticalStep:(int) vStep currentPlayerID:(NSString *) playerID;
-(NSString *) leftPlayerID;
-(BOOL) isMyTurn:(NSString *) playerID;
-(NSString *) getGameID;
-(void) changeTurnToOtherPlayer;
-(NSArray *) getArrayOfUnitNamesInBankForPlayerID:(NSString *) playerID;
-(NSDictionary *) getBankForPlayerID:(NSString *) playerID;
@end
