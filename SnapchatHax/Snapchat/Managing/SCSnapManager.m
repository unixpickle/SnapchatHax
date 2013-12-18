//
//  SCSnapManager.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/18/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCSnapManager.h"

@implementation SCSnapManager

@synthesize blobs;
@synthesize snaps;

- (id)init {
    if ((self = [super init])) {
        snaps = [NSMutableArray array];
        fetchers = [NSMutableArray array];
        blobs = [[NSCache alloc] init];
        blobs.totalCostLimit = (1 << 27); // maximum of 2^27 blob bytes
    }
    return self;
}

- (void)cancelAll {
    while (fetchers.count > 0) {
        [fetchers[0] cancel];
        [fetchers removeObjectAtIndex:0];
    }
}

- (void)startFetchingBlobs:(SCAPISession *)session {
    for (SCSnap * s in session.mediaSnaps) {
        __weak SCSnapManager * weakSelf = self;
        __block SCFetcher * f = [session fetchBlob:s.identifier callback:^(NSError * error, SCBlob * blob) {
            [fetchers removeObject:f];
            if (error && ![error.domain isEqualToString:@"SCBlob"]) {
                [weakSelf.delegate scSnapManager:weakSelf failedWithError:error];
            } else {
                if (blob) {
                    [weakSelf.blobs setObject:blob forKey:s.identifier
                                         cost:blob.blobData.length];
                    if (![weakSelf.snaps containsObject:s]) {
                        [weakSelf.snaps addObject:s];
                        [weakSelf.delegate scSnapManagerUpdated:weakSelf];
                    }
                }
                if (!fetchers.count) {
                    [weakSelf.delegate scSnapManagerFinishedLoading:weakSelf];
                }
            }
        }];
        [fetchers addObject:f];
    }
    if (!fetchers.count) {
        [(id)self.delegate performSelector:@selector(scSnapManagerFinishedLoading:)
                                withObject:self afterDelay:0];
    }
}

@end
