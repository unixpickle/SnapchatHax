//
//  ANLoginVC.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/18/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANSnapsVC.h"
#import "SCAPILogin.h"

@interface ANLoginVC : UIViewController <SCAPILoginDelegate> {
    IBOutlet UITextField * username, * password;
    IBOutlet UIButton * button;
}

- (IBAction)loginPressed:(id)sender;

@end
