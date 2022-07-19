//
//  AppDelegate.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Set Google Maps keys
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

    NSString *key = [dict objectForKey: @"ggl_map_api_key"];
    [GMSServices provideAPIKey:key];
    
    // Set up Parse
    NSString *appId = [dict objectForKey: @"app_id"];
    NSString *clientKey = [dict objectForKey: @"client_key"];
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

            configuration.applicationId = appId;
            configuration.clientKey = clientKey;
            configuration.server = @"https://parseapi.back4app.com";
        }];

        [Parse initializeWithConfiguration:config];
    
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
