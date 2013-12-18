//
//  ANAppDelegate.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCAPILogin.h"

@interface ANAppDelegate : UIResponder <UIApplicationDelegate, SCAPILoginDelegate> {
    SCAPILogin * login;
}

@property (strong, nonatomic) UIWindow *window;

@end
