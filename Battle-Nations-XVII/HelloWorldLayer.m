//
//  HelloWorldLayer.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/16/13.
//  Copyright Dmytro Gladkyi 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "ListOfGamesLayer.h"
#import "UserRegister.h"
#import "RegisterLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Battle Nations XVII" fontName:@"Marker Felt" fontSize:56];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		
		
		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// to avoid a retain-cycle with the menuitem and blocks
		__block id copy_self = self;
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemGames = [CCMenuItemFont itemWithString:@"Show games" block:^(id sender) {
            [[CCDirector sharedDirector] pushScene:[CCTransitionFadeDown transitionWithDuration:1.0 scene:[ListOfGamesLayer scene]]];
			//[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ListOfGamesLayer scene] ]];
		}];
        

        CCMenuItem *itemRegister = [CCMenuItemFont itemWithString:@"Register" block:^(id sender) {
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:[RegisterLayer scene]]];
            /*UserRegister *reg = [[UserRegister alloc] init];
            [reg registerUser:@"gladimdim" withEmail:@"gladimdim@gmail.com" callBack:^(BOOL success) {
                NSLog(@"succesfully registered: %@", success ? @"YES" : @"NO");
            }];*/
        }];
		
		
		CCMenu *menu = [CCMenu menuWithItems:itemGames, itemRegister, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:menu];
        
        //set default server and port
        [[NSUserDefaults standardUserDefaults] setObject:@"https://82.196.1.103" forKey:@"server"];
        [[NSUserDefaults standardUserDefaults] setObject:@"8444" forKey:@"port"];
        //[[NSUserDefaults standardUserDefaults] setObject:@"gladimdim" forKey:@"playerID"];
      //  [[NSUserDefaults standardUserDefaults] setObject:@"gl" forKey:@"email"];

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
