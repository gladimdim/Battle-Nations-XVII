//
//  ListOfGamesLayer.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/16/13.
//  Copyright 2013 Dmytro Gladkyi. All rights reserved.
//

#import "ListOfGamesLayer.h"
#import "ListOfGamesGetter.h"
#import "GameFieldLayer.h"
#import "CCScrollLayer.h"
#import "HelloWorldLayer.h"
#import "NewGame.h"

@interface ListOfGamesLayer()
@property NSMutableData *receivedData;
@property ListOfGamesGetter *getter;
@property CCMenu *menu;
@property NSString *playerID;
@end

@implementation ListOfGamesLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ListOfGamesLayer *layer = [ListOfGamesLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(100, 100, 100, 100)]) ) {
        // to avoid a retain-cycle with the menuitem and blocks
        __block id copy_self = self;
        self.getter = [[ListOfGamesGetter alloc] init];
        self.playerID = [[NSUserDefaults standardUserDefaults] stringForKey:@"playerID"];
        self.menu = [[CCMenu alloc] init];
        [self getListOfGames];
        
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Default font size will be 28 points.
        [CCMenuItemFont setFontSize:28];
        [self addStaticItems];

        self.menu.zOrder = 1;
        [self.menu alignItemsHorizontallyWithPadding:20];
        [self.menu setPosition:ccp(size.width/2, size.height/2)];
        
        // Add the menu to the layer
        [self addChild:self.menu];
	}
	return self;
}

-(void) addStaticItems {
    CCMenuItemFont *refreshItem = [CCMenuItemFont itemWithString:NSLocalizedString(@"Refresh", nil) block:^(id sender) {
        [self getListOfGames];
    }];

    CCMenuItemFont *backItem = [CCMenuItemFont itemWithString:NSLocalizedString(@"Back", nil) block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    
    CCMenuItem *itemCreate = [CCMenuItemFont itemWithString:@"I want to play" block:^(id sender) {
       /* NewGame *game = [[NewGame alloc] init];
        [game askForNewGameForUser:[[NSUserDefaults standardUserDefaults] stringForKey:@"playerID"]  withEmail:@"kuku" forNation:@"poland" callBack:^(NSDictionary *returnDict) {
            NSLog(@"created new game: %@", returnDict);
        }];*/
        [self buildMenuForArmySelection];
    }];
    [self.menu addChild:itemCreate];
    [self.menu addChild:refreshItem];
    [self.menu addChild:backItem];
    [self.menu alignItemsVertically];
}

-(void) buildMenuForArmySelection {
    [self.menu removeAllChildren];
    CCMenuItemFont *backItem = [CCMenuItemFont itemWithString:NSLocalizedString(@"Back", nil) block:^(id sender) {
        [self buildMenuForListOfGames];
    }];
    
    CCMenuItemFont *itemUkraine = [CCMenuItemFont itemWithString:NSLocalizedString(@"Ukraine", nil) block:^(id sender) {
        NewGame *game = [[NewGame alloc] init];
        [game askForNewGameForUser:[[NSUserDefaults standardUserDefaults] stringForKey:@"playerID"]  withEmail:@"kuku" forNation:@"ukraine" callBack:^(NSDictionary *returnDict, NSError *err) {
            NSLog(@"created new game: %@", returnDict);
            if (err) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error occurred", nil) message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            else {
                [self  buildMenuForListOfGames];
            }
        }];
    }];
    
    CCMenuItemFont *itemPoland = [CCMenuItemFont itemWithString:NSLocalizedString(@"Poland", nil) block:^(id sender) {
        NewGame *game = [[NewGame alloc] init];
        [game askForNewGameForUser:[[NSUserDefaults standardUserDefaults] stringForKey:@"playerID"]  withEmail:@"kuku" forNation:@"poland" callBack:^(NSDictionary *returnDict, NSError *err) {
            NSLog(@"created new game: %@", returnDict);
            if (err) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error occurred", nil) message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            else {
                [self  buildMenuForListOfGames];
            }
        }];
    }];
    [self.menu addChild:itemUkraine];
    [self.menu addChild:itemPoland];
    [self.menu addChild:backItem];
    
    [self.menu alignItemsVertically];
    [self.menu draw];
}

-(void) buildMenuForListOfGames {
    [self.menu removeAllChildren];
    [self getListOfGames];
}

-(void) getListOfGames {
    [self.getter getListOfGamesFor:self.playerID withCallBack:^(NSDictionary *dict, NSError *err) {
        //if err is not nil - show alert and immediately return.
        if (err) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error occurred", nil) message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.menu removeAllChildren];
            [self addStaticItems];
            return;
        }
        NSLog(@"dict: %@", dict);
        SEL selectorAllKeys = NSSelectorFromString(@"allKeys");
        if ([dict respondsToSelector:selectorAllKeys]) {// && [dict allKeys].count > 1) {
            //CCMenuItemFont *errorItem = [CCMenuItemFont itemWithString:@"Retry"];
            [self.menu removeAllChildren];
            
        }
        else {
            NSArray *array = (NSArray *) dict;
            NSLog(@"array count: %i", array.count);
            [self.menu removeAllChildren];
            for (int i = 0; i < array.count; i++) {
                NSDictionary *game = [array[i] objectForKey:@"game"];
                NSString *playerLeft = [game valueForKey:@"player_left"];
                NSString *nationLeft = [[game objectForKey:playerLeft] valueForKey:@"nation"];
                NSString *leftFlag = [NSString stringWithFormat:@"flag_%@.png", nationLeft];
                NSString *playerRight = [game valueForKey:@"player_right"];
                NSString *nationRight = [[game objectForKey:playerRight] valueForKey:@"nation"];
                NSString *rightFlag = [NSString stringWithFormat:@"flag_%@.png", nationRight];
                CCMenuItemImage *itemImageLeft = [CCMenuItemImage itemWithNormalImage:leftFlag selectedImage:leftFlag];
                itemImageLeft.position = ccp(0, 15);
                CCMenuItemImage *itemImageRight = [CCMenuItemImage itemWithNormalImage:rightFlag selectedImage:rightFlag];
                itemImageRight.position = ccp(260, 15);
                CCMenuItem *item = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"   %@ - %@   ", playerLeft, playerRight] block:^(id sender)  {
                    NSLog(@"pressed %@", [game valueForKey:@"game_id"]);
                    [[CCDirector sharedDirector] pushScene:[CCTransitionFadeDown transitionWithDuration:1.0 scene:[GameFieldLayer sceneWithDictOfGame:game]]];
                }];
                
                
                //determine if it is player's turn
                //BOOL leftArmyTurn = [game objectForKey:@"left_army_turn"];
                // [item setIsEnabled:(leftArmyTurn && [playerLeft isEqualToString:self.playerID])];
                [item addChild:itemImageLeft];
                [item addChild:itemImageRight];
                [self.menu addChild:item];
            }
        }
        [self addStaticItems];
        [self.menu alignItemsVertically];
        [self.menu draw];
    }];

}


@end
