//
//  GitHubAppDelegate.h
//  GitHub
//
//  Created by Simon Maddox on 07/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GitHubViewController;

@interface GitHubAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GitHubViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GitHubViewController *viewController;

@end

