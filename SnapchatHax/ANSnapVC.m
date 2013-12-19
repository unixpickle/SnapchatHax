//
//  ANSnapVC.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/18/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANSnapVC.h"

@interface ANSnapVC ()

@end

@implementation ANSnapVC

- (id)initWithSnap:(SCSnap *)snap {
    if ((self = [super initWithNibName:NSStringFromClass(self.class)
                                bundle:[NSBundle mainBundle]])) {
        self.snap = snap;
        self.title = @"Snap";
    }
    return self;
}

- (id)initWithSnap:(SCSnap *)snap session:(SCAPISession *)session {
    if ((self = [self initWithSnap:snap])) {
        // load the data
        self.session = session;
        fetcher = [session fetchBlob:self.snap.identifier callback:^(NSError * error, SCBlob * blob) {
            if (!blob) {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [av show];
            } else {
                fetcher = nil;
                self.blob = blob;
                [self handleBlobLoaded];
            }
        }];
    }
    return self;
}

- (id)initWithSnap:(SCSnap *)snap blob:(SCBlob *)blob session:(SCAPISession *)session {
    if ((self = [self initWithSnap:snap])) {
        self.blob = blob;
        self.session = session;
    }
    return self;
}

- (void)setLoading:(BOOL)flag {
    if (flag) {
        [loader startAnimating];
        [buttonsView setHidden:YES];
    } else {
        [loader stopAnimating];
        [buttonsView setHidden:NO];
    }
}

#pragma mark - Events -

- (IBAction)viewPressed:(id)sender {
    NSURL * theURL = [NSURL fileURLWithPath:tempFile];
    currentDocument = [UIDocumentInteractionController interactionControllerWithURL:theURL];
    currentDocument.delegate = self;
    
    [currentDocument presentOptionsMenuFromRect:CGRectZero
                                         inView:self.view
                                       animated:YES];
}

- (IBAction)markScreenshotPressed:(id)sender {
    [self setLoading:YES];
    fetcher = [self.session markSnapScreenshot:self.snap.identifier time:1 callback:^(NSError * error) {
        if (error) {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [av show];
        }
        [self setLoading:NO];
    }];
}

- (IBAction)markAsReadPressed:(id)sender {
    [self setLoading:YES];
    fetcher = [self.session markSnapViewed:self.snap.identifier time:1 callback:^(NSError * error) {
        if (error) {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [av show];
        }
        [self setLoading:NO];
    }];
}

#pragma mark - Loading -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.blob) [self handleBlobLoaded];
    dateLabel.text = [[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)self.snap.timestamp / 1000.0] description];
    senderLabel.text = self.snap.user;
}

- (void)handleBlobLoaded {
    if (!buttonsView || !typeLabel || !sizeLabel) return;
    
    NSString * fileName = [NSString stringWithFormat:@"%@.%@", self.snap.identifier, [self.blob blobFileExtension]];
    tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [self.blob.blobData writeToFile:tempFile atomically:YES];
    
    [self setLoading:NO];
    typeLabel.text = [self.blob isKindOfClass:[SCImageBlob class]] ? @"Image" : @"Video";
    sizeLabel.text = [NSString stringWithFormat:@"%d KB", (int)self.blob.blobData.length >> 10];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (!self.navigationController) {
        [fetcher cancel];
        if (tempFile) [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
    }
}

#pragma mark - Document Interaction -

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.navigationController;
}

@end
