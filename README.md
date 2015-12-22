# Flurry Analytics and Tumblr In-App Sharing Sample - iOS

This project showcases how Flurry Analytics and Tumblr In-App Sharing can be integrated into an iOS app.  It is a simple and fun app that takes Flickr images and uses them as a background for Darth Vader quotes.  Users can swipe left and right to get new image/quote combos.  Lastly, users can click on the Tumblr icon to invoke the Tumblr In-App Sharing so as to share image/quote combos to Tumblr.

## Features

* Integration - Demonstrates integration of Flurry Analytics in an app, along with best practices for integrating Analytics into your iOS app.
* Custom Events - Several custom events (some with params) are used in the ViewController, including Swipe, GetBackgroundImage and GetQuote.
* Tumblr In-App Sharing - From the ViewController, share image/quote combos to Tumblr.
* FlurryLaunchOrigin - In the AppDelegate, you can see the basic use of FlurryLaunchOrigin, a library that allows you to capture the origin of your app’s launch and then log it to Flurry Analytics.

## Prerequisites

* Xcode sufficient to compile apps built for iOS 8.0
* CocoaPods - In order to install 3rd party Pod dependencies, available [here](https://guides.cocoapods.org/using/getting-started.html#toc_3)
* Pods used
  * Flurry-iOS-SDK/FlurrySDK:  Basic Flurry Analytics package
  * Flurry-iOS-SDK/FlurryAds:  Dependency of Tumblr In-App Sharing
  * Flurry-iOS-SDK/TumblrAPI:  Provides Tumblr In-App Sharing
  * FlurryLaunchOrigin:  Library to enable the easy capture of launch source
  * FlickrKit:  A convenient and easy Flickr library made available by David Casserly.  Find out more at http://www.devedup.com.

Code licensed under the zlib license. See LICENSE file for terms.
