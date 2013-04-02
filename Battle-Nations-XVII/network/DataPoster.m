//
//  DataPoster.m
//  Battle-Nations-XVII
//
//  Created by Dmytro Gladkyi on 3/31/13.
//  Copyright (c) 2013 Dmytro Gladkyi. All rights reserved.
//

#import "DataPoster.h"

@interface DataPoster ()
@property (copy, nonatomic) void (^callBackBlock) (BOOL);
@property NSMutableData *receivedData;
@end

@implementation DataPoster

-(void) sendMoves:(NSArray *) arrayOfMoves forGame:(GameDictProcessor*) gameObj withCallBack:(void (^) (BOOL)) callBackBlock {
    self.callBackBlock = callBackBlock;
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/v1/make-moves"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:arrayOfMoves forKey:@"request"];
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayOfMoves options:NSJSONReadingAllowFragments error:&err];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
     NSLog(@"request: %@", request);
     NSLog(@"request headers: %@", [request allHTTPHeaderFields]);
     NSLog(@"requet body: %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] );
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    else {
        self.receivedData = nil;
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *string = [[NSString alloc] initWithData:self.receivedData encoding:NSWindowsCP1251StringEncoding];
    //  NSLog(@"response for rate: %@", string);
    if (string) {
        NSError *err;
        NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingAllowFragments error:&err];
        self.callBackBlock(returnDict);
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error during getting list of games: %@", [error localizedDescription]);
    self.callBackBlock(nil);
}
@end
