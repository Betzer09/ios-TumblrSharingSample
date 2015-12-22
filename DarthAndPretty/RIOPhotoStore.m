//
//  RIOPhotoStore.m
//  DarthAndPretty
//
//  Copyright 2015 Yahoo Inc.
//  Licensed under the terms of the zLib license. Please see LICENSE file in the project root for terms.

#import "RIOPhotoStore.h"
#import "FlickrKit.h"
#include <stdlib.h>
#include "Flurry.h"


@interface RIOPhotoStore ()

@property (nonatomic) NSMutableArray *store;
@property (nonatomic) FKFlickrNetworkOperation *todaysInterestingOp;
@property (nonatomic) int lastPicIndex;

@end

@implementation RIOPhotoStore

+ (instancetype) sharedStore
{
    static RIOPhotoStore *sharedStore = nil;
    if(!sharedStore)
    {
        sharedStore = [[RIOPhotoStore alloc] initPrivate];
    }
    
    return sharedStore;
}

+ (UIImage *) getImageFromDictionary:(NSDictionary *)dict
{
    return [dict objectForKey:@"image"];
}

+ (NSString *) getURLFromDictionary:(NSDictionary *)dict
{
    return [dict objectForKey:@"url"];
}

- (instancetype) init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[RIOPhotoStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype) initPrivate
{
    self = [super init];
    [Flurry logEvent:@"createSharedStore"];
    
    if(self)
    {
        self.lastPicIndex = -1;
        self.store = [NSMutableArray array];
        [self addDefaultImages];
        [self addFlickrImages];
        
    }
    
    return self;
}

- (void) addDefaultImages
{
    NSDictionary *carolinabeach = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/carolinabeach" ofType:@"JPG"]],
                              @"image", @"http://static1.squarespace.com/static/5456ac3de4b0b9880b553803/5456d597e4b00956b2012395/55d7394ee4b0ea12462ad78f/1440168277311/2014-11-27+07.17.46.jpg?format=2500w", @"url", nil];
    NSDictionary *cherrystone = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/cherrystone"ofType:@"JPG"]], @"image",
                                 @"http://static1.squarespace.com/static/5456ac3de4b0b9880b553803/5456d597e4b00956b2012395/5456f9c0e4b007efb21083d3/1414986197789/IMG_5124.JPG?format=2500w", @"url", nil];
    NSDictionary *empire = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/empire" ofType:@"JPG"]], @"image",
                             @"http://static1.squarespace.com/static/5456ac3de4b0b9880b553803/5456d597e4b00956b2012395/5456f9c7e4b007efb21083f7/1414986187057/15366423698_ca0cf84e77_o.jpg?format=1500w", @"url", nil];
    NSDictionary *lauden = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/lauden" ofType:@"JPG"]], @"image",
                            @"http://static1.squarespace.com/static/5456ac3de4b0b9880b553803/5456d597e4b00956b2012395/55d7322ae4b06459b2408af5/1440166444239/2014-10-17+17.17.45-3.jpg?format=1500w", @"url", nil];
    NSDictionary *moon = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/moon" ofType:@"JPG"]],
                          @"image",
                          @"http://static1.squarespace.com/static/5456ac3de4b0b9880b553803/5456d597e4b00956b2012395/55d73229e4b07fe20b7bed1e/1440166449887/2014-11-05+18.30.19-3.jpg?format=2500w", @"url", nil];
    NSDictionary *purpletree = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images/purpletree" ofType:@"JPG"]], @"image",
                                @"http://static1.squarespace.com/static/5456ac3de4b0b9880b553803/5456d597e4b00956b2012395/55d73228e4b06459b2408add/1440166444782/2014-11-24+18.36.43.jpg?format=2500w", @"url", nil];
    
    [self.store addObject:carolinabeach];
    [self.store addObject:cherrystone];
    [self.store addObject:empire];
    [self.store addObject:lauden];
    [self.store addObject:moon];
    [self.store addObject:purpletree];
}

- (void) addFlickrImages
{
    FKFlickrInterestingnessGetList *interesting = [[FKFlickrInterestingnessGetList alloc] init];
    interesting.per_page = @"20";
    
    // Create a random date that is at least 7 days in the past from which to pull the photos
    NSDate *photoDate = [NSDate date];
    
    // Set the base, then add a random component, then turn it into seconds.  Also, make it negative.
    int daysToSubtract = 7 + arc4random_uniform(100);
    int secondsToSubtract = daysToSubtract * 24 * 60 * 60 * -1;
    NSDate *pastDate = [photoDate dateByAddingTimeInterval:secondsToSubtract];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    
    interesting.date = [format stringFromDate:pastDate];
    self.todaysInterestingOp = [[FlickrKit sharedFlickrKit] call:interesting completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response) {
                NSMutableArray *photoURLs = [NSMutableArray array];
                for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
                    NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:photoDictionary];
                    if(url != nil){
                        [photoURLs addObject:url];
                    }
                }
                
                for (NSURL *url in photoURLs) {
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    NSURLSession *session = [NSURLSession sharedSession];
                    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                      NSURLResponse *response,
                                                                      NSError *error){
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        [self.store addObject:[[NSDictionary alloc] initWithObjectsAndKeys:image, @"image", [url absoluteString], @"url", nil]];
                    }] resume];
                }
                
            } else {
                /*
                 Iterating over specific errors for each service
                 */
                switch (error.code) {
                    case FKFlickrInterestingnessGetListError_ServiceCurrentlyUnavailable:
                        
                        break;
                    default:
                        break;
                }
                // TODO - Do something useful here... ¯\_(ツ)_/¯
            }
        });
    }];

}

- (UIImage *) getRandomImage
{
    
    NSUInteger storeCount = self.store.count;
    int imageIndex = -1;
    do{
        imageIndex = arc4random_uniform((unsigned int)self.store.count);
    }
    while(imageIndex == self.lastPicIndex || imageIndex >= storeCount);
    
    
    
    if(imageIndex < storeCount)
    {
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%lu", (unsigned long)storeCount], @"store_size",
                                [NSString stringWithFormat:@"%d", imageIndex], @"image_selected_index",
                                [NSString stringWithFormat:@"%d", self.lastPicIndex], @"image_last_selected_index", nil];
        [Flurry logEvent:@"getRandomImage" withParameters:params];
        self.lastPicIndex = imageIndex;
        return [self.store objectAtIndex:imageIndex];
    }
    
    return nil;
}

- (NSDictionary *) getImage: (NSUInteger)index
{
    if(index < self.store.count)
    {
        return [self.store objectAtIndex:index];
    }
    
    return nil;
}

- (NSDictionary *) loadImage:(NSURL *)url
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data,
                                                      NSURLResponse *response,
                                                      NSError *error){
        UIImage *image = [[UIImage alloc] initWithData:data];
        NSDictionary *loadedImage = [[NSDictionary alloc] initWithObjectsAndKeys:image, @"image", [url absoluteString], @"url", nil];
        [self.store addObject: loadedImage];
    }] resume];
    
    // Not entirely sure this is safe...  But it seems to work!
    return [self.store lastObject];
}

@end
