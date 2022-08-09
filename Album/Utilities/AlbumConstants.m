//
//  Constants.m
//  Album
//
//  Created by Airei Fukuzawa on 7/15/22.
//
#import "AlbumConstants.h"
#import <Foundation/Foundation.h>
// Class names
NSString *const classNameFriendship = @"Friendship";
NSString *const classNameImage = @"Image";
NSString *const classNamePin = @"Pin";
NSString *const classNameUserPin = @"UserPin";
NSString *const segueLogin = @"loginSegue";
NSString *const segueSignup = @"signupSegue";
NSString *const segueColorPick = @"colorPickSegue";
NSString *const segueAddFriend = @"addFriendSegue";
NSString *const segueActivities = @"activitiesSegue";
NSString *const segueSettings = @"settingsSegue";
NSString *const segueCompose = @"composeSegue";
NSString *const segueDetails = @"detailsSegue";
NSString *const segueFriendMap = @"friendMapSegue";
// Color codes
NSString *const pinkColor1 = @"FF9A8B";
NSString *const pinkColor2 = @"FF6A8B";
NSString *const pinkColor3 = @"FF99AC";

double const earthR = 6378137;
// Constants for friendship status
int const PENDING = 1;
int const FRIENDED = 2;
int const NOT_FRIEND = 0;
