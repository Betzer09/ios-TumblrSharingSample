//
//  AppDelegate.m
//  DarthAndPretty
//
//  Copyright 2015 Yahoo Inc.
//  Licensed under the terms of the zLib license. Please see LICENSE file in the project root for terms.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import <FlickrKit/FlickrKit.h>
#import "RIOPhotoStore.h"
#import "ViewController.h"
#import "FlurryTumblr.h"
#import "FlurryLaunchOrigin.h"

@interface AppDelegate ()

@property ViewController *vc;

@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        // **** THIS IS WHERE THE MAGIC HAPPENS ****
        [FlurryLaunchOrigin autoInstrumentDelegate:self];
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Flurry setCrashReportingEnabled:TRUE];
    [Flurry startSession:@"MNYKT97PKT5RQ7FMSX6G"];
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:@"f52a757f2b7136566ae47e57e776a615"  sharedSecret:@"3bf93393c63d56b4"];
    [RIOPhotoStore sharedStore];
    
    // Tumblr initialization
    [FlurryTumblr setConsumerKey:@"ZJIv7SNrKMcct5tdQy7rzzsv3b0pTxBNYWkV548LgbIDIwsnPt" consumerSecret:@"7jsraXodsVSeMHMLtHg5FYyporapRTf2ahJFK2tsnV4x0fYjse"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.vc = [storyboard instantiateInitialViewController];
    
    
    self.window.rootViewController = self.vc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //NSLog(@"opening sourceApplication: %@", sourceApplication);
    //NSLog(@"url scheme: %@", [url scheme]);
    //NSLog(@"url query: %@", [url query]);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [[url query ]componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }
    
    // We will be getting back encoded params here, so we will need to grab them and then
    // decode them
    NSString *encodedQuote = [params objectForKey:@"quote"];
    NSString *encodedImageURL = [params objectForKey:@"image"];
    
    //NSLog(@"quote: %@", encodedQuote);
    //NSLog(@"url: %@", encodedImageURL);
    
   // [self.vc loadImage:[[NSURL alloc] initWithString:encodedImageURL] withQuote:[encodedQuote stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   [self.vc loadImage:[[NSURL alloc] initWithString:encodedImageURL] withQuote:[encodedQuote stringByRemovingPercentEncoding]];
    
    return TRUE;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"%s: Method:     %@", __PRETTY_FUNCTION__, [FlurryLaunchOrigin launchMethod]);
    NSLog(@"%s: Origin:     %@", __PRETTY_FUNCTION__, [FlurryLaunchOrigin launchOrigin]);
    NSLog(@"%s: Properties: %@", __PRETTY_FUNCTION__, [FlurryLaunchOrigin launchProperties]);
    
    NSString *deeplink = [[FlurryLaunchOrigin launchProperties] objectForKey:@"FlurryOriginLaunchPropertyURL"];
    [Flurry addSessionOrigin:[FlurryLaunchOrigin launchOrigin] withDeepLink:deeplink];
    
}

@end
