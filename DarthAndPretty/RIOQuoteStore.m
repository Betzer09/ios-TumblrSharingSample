//
//  RIOQuoteStore.m
//  DarthAndPretty
//
//  Copyright 2015 Yahoo Inc.
//  Licensed under the terms of the zLib license. Please see LICENSE file in the project root for terms.
//

#import "RIOQuoteStore.h"
#import <stdlib.h>
#import "Flurry.h"

@interface RIOQuoteStore ()

@property (nonatomic) NSMutableArray *store;
@property (nonatomic) int lastQuoteIndex;

@end

@implementation RIOQuoteStore

+ (instancetype) sharedStore
{
    static RIOQuoteStore *sharedStore = nil;
    if(!sharedStore)
    {
        sharedStore = [[RIOQuoteStore alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype) init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[RIOQuoteStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype) initPrivate
{
    self = [super init];
    if(self)
    {
        self.store = [[NSMutableArray alloc] initWithObjects:
                      @"You may dispense with the pleasantries, commander. I am here to put you back on schedule. - Darth Vader",
                      @"The ability to destroy a planet is insignificant next to the power of the force. - Darth Vader",
                      @"I hope so for your sake, the emperor is not as forgiving as I am. - Darth Vader",
                      @"I am altering the deal, pray I do not alter it any further… - Darth Vader",
                      @"You underestimate the power of the dark side. - Darth Vader",
                      @"I find your lack of faith disturbing. - Darth Vader",
                      @"Impressive. Most impressive. Obi-Wan has taught you well. You have controlled your fear. Now, release your anger. Only your hatred can destroy me. - Darth Vader",
                      @"I’ve been waiting for you, Obi-wan. We meet again at last. The circle is now complete. When I left you I was but the learner. Now I am the master. - Darth Vader",
                      @"Luke, you can destroy the Emperor. He has foreseen this. It is your destiny. Join me, and together we can rule the galaxy as father and son. - Darth Vader",
                      @"I am your father! - Darth Vader",
                      @"Don't fail me again, Admiral. - Darth Vader",
                      @"Asteroids do not concern me, Admiral! I want that ship, not excuses! - Darth Vader",
                      @"He will join us or die, my master. - Darth Vader",
                      @"The force is with you, young Skywalker, but you are not a Jedi yet. - Darth Vader",
                      @"Calrissian. Take the princess and the Wookie to my ship. - Darth Vader",
                      @"There will be a substantial reward for the one who finds the Millennium Falcon. You are free to use any methods necessary, but I want them alive. No disintegrations. - Darth Vader",
                      @"You know it would be unfortunate if I had to leave a garrison here. - Darth Vader",
                      @"You are beaten. It is useless to resist. Don't let yourself be destroyed as Obi-Wan did. - Darth Vader",
                      @"You have failed me for the last time, Admiral! Captain Piett? - Darth Vader",
                      @"I do not want the Emperor's prize damaged. We will test it on Captain Solo. - Darth Vader",
                      nil];
    }
    
    return self;
}

- (NSString *) getRandomQuote
{
    NSUInteger storeCount = self.store.count;
    int quoteIndex = -1;
    do{
        quoteIndex = arc4random_uniform((unsigned int)self.store.count);
    }
    while(quoteIndex == self.lastQuoteIndex || quoteIndex >= storeCount);
    
    if(quoteIndex < storeCount)
    {
        [Flurry logEvent:@"randomQuote"];
        self.lastQuoteIndex = quoteIndex;
        return [self.store objectAtIndex:quoteIndex];
    }
    
    return nil;
}

- (NSString *) getQuote:(NSUInteger)quoteNumber
{
    if(quoteNumber < self.store.count)
    {
        return [self.store objectAtIndex:quoteNumber];
    }
    
    return nil;
}

@end
