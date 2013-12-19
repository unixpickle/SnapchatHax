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
    // remove snaps
    NSArray * mediaSnaps = session.mediaSnaps;
    for (int i = 0; i < self.snaps.count; i++) {
        SCSnap * s = self.snaps[i];
        if (![mediaSnaps containsObject:s]) {
            [self.snaps removeObject:s];
            [self.delegate scSnapManager:self deletedAtIndex:i];
            i--;
        }
    }
    for (SCSnap * s in mediaSnaps) {
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
                        
                        // sort it by date
                        [weakSelf.snaps sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                            SCSnap * s1 = obj1, * s2 = obj2;
                            if (s1.timestamp < s2.timestamp) return NSOrderedAscending;
                            if (s1.timestamp > s2.timestamp) return NSOrderedDescending;
                            return NSOrderedSame;
                        }];
                        
                        [weakSelf.delegate scSnapManager:weakSelf
                                         insertedAtIndex:[weakSelf.snaps indexOfObject:s]];
                    }
                } else {
                    if ([weakSelf.snaps containsObject:s]) {
                        NSInteger index = [weakSelf.snaps indexOfObject:s];
                        [weakSelf.snaps removeObject:s];
                        [weakSelf.delegate scSnapManager:self deletedAtIndex:index];
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
