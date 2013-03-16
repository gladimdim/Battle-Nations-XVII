//
//  ListOfGamesLayer.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/16/13.
//  Copyright 2013 Dmytro Gladkyi. All rights reserved.
//

#import "ListOfGamesLayer.h"
#import "ListOfGamesGetter.h"

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
	if( (self=[super init]) ) {
        // to avoid a retain-cycle with the menuitem and blocks
        __block id copy_self = self;
        self.getter = [[ListOfGamesGetter alloc] init];
        self.playerID = @"306";
        [self.getter getListOfGamesFor:self.playerID withCallBack:^(NSDictionary *dict) {
            NSLog(@"dict: %@", dict);
            if (dict) {
                NSArray *array = (NSArray *) dict;
                NSLog(@"array count: %i", array.count);
                [self.menu removeAllChildren];
                for (int i = 0; i < array.count; i++) {
                    NSDictionary *game = [array[i] objectForKey:@"game"];
                    NSString *playerLeft = [game valueForKey:@"player_left"];
                    NSString *nationLeft = [[game objectForKey:playerLeft] valueForKey:@"nation"];
                    NSString *leftFlag = [nationLeft isEqualToString:@"ukraine"] ? @"flag_ukraine.png" : @"flag_poland.png";
                    NSString *playerRight = [game valueForKey:@"player_right"];
                    NSString *nationRight = [[game objectForKey:playerRight] valueForKey:@"nation"];
                    NSString *rightFlag = [nationRight isEqualToString:@"ukraine"] ? @"flag_ukraine.png" : @"flag_poland.png";
                    CCMenuItemImage *itemImageLeft = [CCMenuItemImage itemWithNormalImage:leftFlag selectedImage:leftFlag];
                    itemImageLeft.position = ccp(0, 15);
                   /* CCLabelTTF *iconLabel = [CCLabelTTF labelWithString:[game valueForKey:@"game_id"] fontName:@"Arial" fontSize:20];
                    iconLabel.color = ccc3(255, 255, 255);
                    iconLabel.position = ccp(70, 8);
                    iconLabel.tag = 1;
                    */
                    CCMenuItemImage *itemImageRight = [CCMenuItemImage itemWithNormalImage:rightFlag selectedImage:rightFlag];
                    itemImageRight.position = ccp(260, 15);
                    CCMenuItem *item = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"   %@    ", [game valueForKey:@"game_id"]] block:^(id sender)  {
                        NSLog(@"pressed %@", [game valueForKey:@"game_id"]);
                    }];
                    [item addChild:itemImageLeft];
                    [item addChild:itemImageRight];
                    
                   // [item addChild:itemImage];
                    [self.menu addChild:item];

                    
                }
            }
            else {
                CCMenuItemFont *errorItem = [CCMenuItemFont itemWithString:@"Retry"];
                [self.menu addChild:errorItem];
            }
            [self.menu alignItemsVertically];
            [self.menu draw];

        }];
        
        CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Send request" block:^(id sender) {
            NSLog(@"pressed");
            
        }];
        
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Default font size will be 28 points.
        [CCMenuItemFont setFontSize:28];
        
        self.menu = [CCMenu menuWithItems:itemAchievement, nil];
        
        [self.menu alignItemsHorizontallyWithPadding:20];
        [self.menu setPosition:ccp( size.width/2, size.height/2 - 50)];
        
        // Add the menu to the layer
        [self addChild:self.menu];

       
		
		// Achievement Menu Item using blocks
		
        
	}
	return self;
}


@end
