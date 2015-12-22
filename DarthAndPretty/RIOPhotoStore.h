//
//  RIOPhotoStore.h
//  DarthAndPretty
//
//  Copyright 2015 Yahoo Inc.
//  Licensed under the terms of the zLib license. Please see LICENSE file in the project root for terms.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RIOPhotoStore : NSObject

+ (instancetype) sharedStore;
+ (UIImage *) getImageFromDictionary: (NSDictionary *)dict;
+ (NSString *) getURLFromDictionary: (NSDictionary *)dict;
- (NSDictionary *) getRandomImage;
- (NSDictionary *) getImage: (NSUInteger)imageNumber;
- (NSDictionary *) loadImage:(NSURL *)url;

@end
