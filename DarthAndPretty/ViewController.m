//
//  ViewController.m
//  DarthAndPretty
//
//  Copyright 2015 Yahoo Inc.
//  Licensed under the terms of the zLib license. Please see LICENSE file in the project root for terms.
//

#import "ViewController.h"
#import "RIOPhotoStore.h"
#import "RIOQuoteStore.h"
#import <UIKit/UIKit.h>
#import "FlurryTumblr.h"
#import "Flurry.h"

#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *background;
@property (nonatomic, weak) IBOutlet UITextView *quote;
@property (nonatomic, weak) IBOutlet UIButton *tumblrButton;
@property (nonatomic, weak) NSString *quoteText;
@property (nonatomic, weak) NSDictionary *imageDict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [self.quote addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [super viewDidLoad];
    
    // Make the picture fill the view
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.backgroundColor = [UIColor colorWithRed:0.0F green:0.0F blue:0.0F alpha:1.0F];
    
    // Add swipe gesture recognizers
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGestureRecognizer];
    
    // Set up the text view
    self.quote.backgroundColor = [UIColor colorWithWhite:1.0F alpha:0.0F];
    
    // Log a timed event to track view time.  This will be active until a swipe occurs,
    // or the app is exited/backgrounded (which the SDK takes care of automatically).
    [Flurry logEvent:@"View" timed:YES];
    
    // Set up the initial quote and image
    [self getQuote:nil];
    [self getBackgroundImage:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

- (void) loadImage:(NSURL *)url withQuote:(NSString *)quote
{
    [self getBackgroundImage:url];
    [self getQuote:quote];
}

- (void) handleSwipe:(UIGestureRecognizer*)recognizer
{
    // End the timed event we started earlier.  If this event had had parameters, we could update
    // them by passing a new set of params in here.
    [Flurry endTimedEvent:@"View" withParameters:nil];
    
    // This event will show up as a simple count of swipes.  It can later be sliced and diced
    // with Explorer to see which devices have the most swipes.  That should allow you to
    // answer your research question of "Does a large screen device promote swiping more than a
    // small screen device?"
    [Flurry logEvent:@"Swipe"];
    [self getBackgroundImage:nil];
    [self getQuote:nil];
}

- (void) getBackgroundImage:(NSURL *)url
{
    if(url == nil){
        // Params are very useful for capturing detailed data.  Here, we're capturing whether or
        // not the background image was selected at random.  In Explorer, params can be used
        // to powerfully segment your audience.
        [Flurry logEvent:@"GetBackgroundImage"
          withParameters:@{@"random":@"YES"}];
        self.imageDict = [RIOPhotoStore sharedStore].getRandomImage;
    }else{
        [Flurry logEvent:@"GetBackgroundImage"
          withParameters:@{@"random":@"NO",
                           @"url":[url absoluteString]}];
        self.imageDict = [[RIOPhotoStore sharedStore] loadImage:url];
    }
    
    [self.background setImage:[RIOPhotoStore getImageFromDictionary:self.imageDict]];
    self.background.contentMode = UIViewContentModeScaleAspectFill;
}

- (void) getQuote:(NSString *)quote
{
    if(quote == nil)
    {
        // Params are very useful for capturing detailed data.  Here, we're capturing whether or
        // not the background image was selected at random.  In Explorer, params can be used
        // to powerfully segment your audience.
        [Flurry logEvent:@"GetQuote"
          withParameters:@{@"random":@"YES"}];
        self.quoteText = [RIOQuoteStore sharedStore].getRandomQuote;
    }else{
        [Flurry logEvent:@"GetQuote"
          withParameters:@{@"random":@"NO"}];
        self.quoteText = quote;
    }
    
    NSDictionary *stringAttributes = nil;
    
    // If we're on an iPad, we can afford larger text.
    if(IDIOM == IPAD)
    {
        stringAttributes =@{
                            NSStrokeColorAttributeName: [UIColor blackColor],
                            NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSStrokeWidthAttributeName : [[NSNumber alloc] initWithDouble:-5.0],
                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:30]
                            };
    }
    else{
        stringAttributes =@{
                            NSStrokeColorAttributeName: [UIColor blackColor],
                            NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSStrokeWidthAttributeName : [[NSNumber alloc] initWithDouble:-5.0],
                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
                            };
    }
    
    [self.quote setAttributedText:[[NSAttributedString alloc] initWithString:self.quoteText attributes:stringAttributes]];
    [self.quote setTextAlignment:NSTextAlignmentCenter];
}

- (IBAction)shareToTumblr:(id)sender
{
    if([RIOPhotoStore getURLFromDictionary:self.imageDict] != nil){
        [Flurry logEvent:@"ShareToTumblr"];
        FlurryImageShareParameters *imageShareParameters = [[FlurryImageShareParameters alloc] init];
        
        imageShareParameters.imageURL = [RIOPhotoStore getURLFromDictionary:self.imageDict];
        imageShareParameters.imageCaption = self.quoteText;
        
        // Encode the URL and the quote
//        NSString *encodedURL = [[self.imageDict objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedURL = [[self.imageDict objectForKey:@"url"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSString *encodedQuote = [self.quoteText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];        NSString *deeplink = [NSString stringWithFormat:@"darthandpretty://?quote=%@&image=%@", encodedQuote, encodedURL];
        NSLog(@"%@", deeplink);
        imageShareParameters.iOSDeepLink = deeplink;
        
        [FlurryTumblr post:imageShareParameters presentingViewController:self];
    }
}

@end
