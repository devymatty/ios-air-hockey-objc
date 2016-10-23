//
//  AppDelegate.h
//  Paddies
//
//  Created by Mikhail on 27.07.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)showTitle;
- (void)playGame:(NSInteger)computer;

@end

