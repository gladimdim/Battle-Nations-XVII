//
//  RegisterLayer.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 5/4/13.
//  Copyright 2013 Dmytro Gladkyi. All rights reserved.
//

#import "RegisterLayer.h"
#import "UserRegister.h"

@interface RegisterLayer()
@property NSString *username;
@property NSString *email;
@property CCMenuItemFont *itemSuccessfull;
@property CCMenuItemFont *itemRetry;
@property CCMenu *menu;
@end

@implementation RegisterLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	RegisterLayer *layer = [RegisterLayer node];
	
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
        /*		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Battle Nations XVII" fontName:@"Marker Felt" fontSize:56];
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];*/
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"playerID"];
        NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
        if (username) {
            CCMenuItem *item = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"User '%@' for email '%@' already registered.", username, email] block:^(id sender) {
                [[CCDirector sharedDirector] popScene];
            }];
            CCMenuItem *item2 = [CCMenuItemFont itemWithString:@"Re-register" block:^(id sender) {
                [self showUsernameAlert];
            }];
            self.menu = [CCMenu menuWithItems:item, item2, nil];
            [self.menu alignItemsVertically];
            [self addChild:self.menu];
        }
        else {
            [self showUsernameAlert];
        }
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

-(void) showUsernameAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username" message:@"Enter username" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Next", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void) showEmailAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Enter email addresss" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Register", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[CCDirector sharedDirector] popScene];
    }
    else {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *value = textField.text;
        if (!self.username) {
            if (textField.text.length > 0) {
                self.username = value;
                [self showEmailAlert];
            }
            else {
                [self showUsernameAlert];
            }
        }
        else {
            if (value.length > 0) {
                self.email = value;
                [self registerUser];
            }
            else {
                [self showEmailAlert];
            }
        }
    }
}

-(void) registerUser {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
    UserRegister *reg = [[UserRegister alloc] init];
    [reg registerUser:self.username withEmail:self.email deviceToken:deviceToken callBack:^(NSDictionary *message) {
        NSLog(@"succesfully registered: %@", message);
        NSString *result = [message objectForKey:@"result"];

        if ([result isEqualToString:@"success"]) {
            [[NSUserDefaults standardUserDefaults] setObject:self.username forKey:@"playerID"];
            [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"email"];
            [[CCDirector sharedDirector] popScene];
        }
        else {
            CCMenuItem *item = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%@. Retry", result] block:^(id sender) {
                //clear previous username and email saved in memory
                self.username = nil;
                self.email = nil;
                [self showUsernameAlert];
            }];
            CCMenuItem *back = [CCMenuItemFont itemWithString:@"Back" block:^(id sender) {
                [[CCDirector sharedDirector] popScene];
            }];
            [self.menu removeAllChildren];
            [self.menu addChild:item];
            [self.menu addChild:back];
            [self.menu alignItemsVertically];
        }
    }];
}
@end
