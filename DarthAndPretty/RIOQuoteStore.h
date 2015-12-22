//
//  RIOQuoteStore.h
//  DarthAndPretty
//
//  Copyright 2015 Yahoo Inc.
//  Licensed under the terms of the zLib license. Please see LICENSE file in the project root for terms.
//

#import <Foundation/Foundation.h>

@interface RIOQuoteStore : NSObject

+ (instancetype) sharedStore;
- (NSString *) getRandomQuote;
- (NSString *) getQuote: (NSUInteger)quoteNumber;

@end
