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
NSString *const segueLogin = @"loginSegue";
NSString *const segueSignup = @"signupSegue";
NSString *const segueColorPick = @"colorPickSegue";
NSString *const segueAddFriend = @"addFriendSegue";
NSString *const segueActivities = @"activitiesSegue";
NSString *const segueSettings = @"settingsSegue";
NSString *const segueCompose = @"composeSegue";
NSString *const segueDetails = @"detailsSegue";
NSString *const segueFriendMap = @"friendMapSegue";
CGRect const rect = CGRectMake(0.0f, 0.0f, 57, 57);
// Constants for friendship status
int const PENDING = 1;
int const FRIENDED = 2;
int const NOT_FRIEND = 0;
