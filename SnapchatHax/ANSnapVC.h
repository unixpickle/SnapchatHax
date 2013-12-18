//
//  ANSnapVC.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/18/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCAPISession.h"
#import "SCImageBlob.h"
#import "SCVideoBlob.h"

@interface ANSnapVC : UIViewController <UIDocumentInteractionControllerDelegate> {
    IBOutlet UILabel * typeLabel;
    IBOutlet UILabel * dateLabel;
    IBOutlet UILabel * sizeLabel;
    IBOutlet UILabel * senderLabel;
    NSString * tempFile;
    
    IBOutlet UIActivityIndicatorView * loader;
    IBOutlet UIButton * viewButton;
    SCFetcher * fetcher;
    
    UIDocumentInteractionController * currentDocument;
}

@property (nonatomic, retain) SCSnap * snap;
@property (nonatomic, retain) SCBlob * blob;

- (IBAction)viewPressed:(id)sender;

- (id)initWithSnap:(SCSnap *)snap;
- (id)initWithSnap:(SCSnap *)snap session:(SCAPISession *)session;
- (id)initWithSnap:(SCSnap *)snap blob:(SCBlob *)blob;
- (void)handleBlobLoaded;

@end
