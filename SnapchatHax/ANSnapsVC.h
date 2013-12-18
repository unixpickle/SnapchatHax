//
//  ANSnapsVC.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/18/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCAPISession.h"
#import "SCSnapManager.h"
#import "ANSnapVC.h"

@interface ANSnapsVC : UITableViewController <SCSnapManagerDelegate> {
    SCFetcher * reloadFetcher;
    SCSnapManager * snaps;
    
    UIActivityIndicatorView * loader;
    UIBarButtonItem * loadButton;
}

@property (nonatomic, retain) SCAPISession * session;

- (id)initWithSession:(SCAPISession *)session;

- (IBAction)reloadPressed:(id)sender;
- (void)setReloading:(BOOL)reloading;

@end
