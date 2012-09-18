//
//  skydiveapp_4_iphoneAppDelegate.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright NA 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropBoxSDK/DropBoxSDK.h>
#import "CommonAppDelegate.h"

@interface SkydiveAppDelegate : CommonAppDelegate <UIApplicationDelegate,
    UITabBarControllerDelegate>
{
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
}

@end
