//
//  ANSnapsVC.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/18/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANSnapsVC.h"

@interface ANSnapsVC ()

@end

@implementation ANSnapsVC

- (id)initWithSession:(SCAPISession *)session {
    if ((self = [super init])) {
        self.session = session;
        self.title = session.username;
        snaps = [[SCSnapManager alloc] init];
        snaps.delegate = self;
        [snaps startFetchingBlobs:session];
        
        loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loader];
        
        loadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                   target:self
                                                                   action:@selector(reloadPressed:)];
        [self setReloading:YES];
    }
    return self;
}

- (IBAction)reloadPressed:(id)sender {
    reloadFetcher = [self.session reloadAll:^(NSError * error) {
        reloadFetcher = nil;
        if (error) {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[error localizedDescription]
                                                         delegate:nil cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];
            [av show];
            [self setReloading:NO];
        } else {
            [snaps startFetchingBlobs:self.session];
        }
    }];
    [self setReloading:YES];
}

- (void)setReloading:(BOOL)reloading {
    if (reloading) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loader];
        [loader startAnimating];
    } else {
        [loader stopAnimating];
        self.navigationItem.rightBarButtonItem = loadButton;
    }
}

#pragma mark - View Methods -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [snaps.blobs removeAllObjects];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (!self.navigationController) {
        [snaps cancelAll];
        [reloadFetcher cancel];
    }
}

#pragma mark - Table View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return snaps.snaps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"Cell"];
    }
    
    SCSnap * snap = snaps.snaps[indexPath.row];
    cell.textLabel.text = snap.user;
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)snap.timestamp / 1000.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"At %@", [date description]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SCSnap * snap = snaps.snaps[indexPath.row];
    SCBlob * blob = [snaps.blobs objectForKey:snap.identifier];
    ANSnapVC * vc = nil;
    if (blob) vc = [[ANSnapVC alloc] initWithSnap:snap blob:blob];
    else vc = [[ANSnapVC alloc] initWithSnap:snap session:self.session];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SCSnapManager -

- (void)scSnapManagerUpdated:(id)sender {
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(snaps.snaps.count - 1) inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)scSnapManagerFinishedLoading:(id)sender {
    [self setReloading:NO];
}

- (void)scSnapManager:(id)sender failedWithError:(NSError *)e {
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:[e localizedDescription]
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"OK", nil];
    [av show];
    [self setReloading:NO];
}

@end
