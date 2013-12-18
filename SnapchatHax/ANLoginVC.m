//
//  ANLoginVC.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/18/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANLoginVC.h"

@interface ANLoginVC ()

@end

@implementation ANLoginVC

- (id)init {
    if ((self = [super initWithNibName:NSStringFromClass(self.class)
                                bundle:[NSBundle mainBundle]])) {
        self.title = @"Login";
    }
    return self;
}

- (IBAction)loginPressed:(id)sender {
    [button setEnabled:NO];
    SCAPILogin * login = [[SCAPILogin alloc] init];
    login.username = username.text;
    login.password = password.text;
    login.delegate = self;
    [login startLogin];
}

- (void)scAPILogin:(id)sender failedWithError:(NSError *)error {
    [button setEnabled:YES];
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:[error localizedDescription]
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"OK", nil];
    [av show];
}

- (void)scAPILogin:(id)sender succeededWithSession:(SCAPISession *)session {
    [button setEnabled:YES];
    ANSnapsVC * snaps = [[ANSnapsVC alloc] initWithSession:session];
    [self.navigationController pushViewController:snaps animated:YES];
}

@end
