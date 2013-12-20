//
//  SCAPISession.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCAPISession.h"

@implementation SCAPISession

+ (NSArray *)parseSnaps:(NSArray *)jsonSnaps {
    NSMutableArray * snaps = [[NSMutableArray alloc] init];
    for (NSDictionary * snap in jsonSnaps) {
        [snaps addObject:[[SCSnap alloc] initWithDictionary:snap]];
    }
    return snaps;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ authToken=%@, snaps=%@>", NSStringFromClass(self.class), self.authToken, self.snaps];
}

#pragma mark - Blobs -

- (SCAPIRequest *)requestForBlob:(NSString *)blobIdentifier {
    NSDictionary * params = @{@"username": self.username,
                              @"id": blobIdentifier};
    return [[SCAPIRequest alloc] initWithConfiguration:self.configuration
                                                  path:@"/bq/blob"
                                                 token:self.authToken
                                            dictionary:params];
}

- (SCFetcher *)fetchBlob:(NSString *)blobIdentifier
                callback:(void (^)(NSError * error, SCBlob * blob))cb {
    NSURLRequest * req = [self requestForBlob:blobIdentifier];
    return [SCFetcher fetcherStartedForRequestNoJSON:req callback:^(NSError * error, id result) {
        if (error) return cb(error, nil);
        SCBlob * blob = [SCBlob blobWithData:result];
        if (!blob) {
            // decrypt the data
            NSData * testData = [self.configuration decrypt:result];
            blob = [SCBlob blobWithData:testData];
        }
        if (!blob) return cb([NSError errorWithDomain:@"SCBlob"
                                                 code:1
                                             userInfo:@{NSLocalizedDescriptionKey: @"Unknown blob type."}], nil);
        cb(nil, blob);
    }];
}

#pragma mark - Events -

- (SCAPIRequest *)requestForSendingEvents:(NSArray *)list snapInfo:(NSDictionary *)info {
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
    NSData * eventsData = [NSJSONSerialization dataWithJSONObject:list options:0 error:nil];
    NSDictionary * req = @{@"username": self.username,
                           @"json": [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding],
                           @"events": [[NSString alloc] initWithData:eventsData encoding:NSUTF8StringEncoding]};
    return [[SCAPIRequest alloc] initWithConfiguration:self.configuration
                                                  path:@"/bq/update_snaps"
                                                 token:self.authToken
                                            dictionary:req];
}

- (SCFetcher *)markSnapViewed:(NSString *)blobId time:(NSTimeInterval)delay callback:(void (^)(NSError * error))cb {
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    NSDictionary * timeInfo = @{@"t": @(ts),
                                @"sv": @(delay)};
    NSDictionary * snapInfo = @{blobId: timeInfo};
    NSArray * events = @[@{@"eventName": @"SNAP_VIEW", @"params": @{@"id": blobId}, @"ts": @(ts - delay)},
                         @{@"eventName": @"SNAP_EXPIRED", @"params": @{@"id": blobId}, @"ts": @(ts)}];
    return [SCFetcher fetcherStartedForRequestNoJSON:[self requestForSendingEvents:events snapInfo:snapInfo]
                                      callback:^(NSError * error, id result) {
                                          cb(error);
                                      }];
}

- (SCFetcher *)markSnapScreenshot:(NSString *)blobId time:(NSTimeInterval)delay callback:(void (^)(NSError * error))cb {
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    NSDictionary * timeInfo = @{@"t": @(ts),
                                @"sv": @(delay),
                                @"c": @(3)};
    NSDictionary * snapInfo = @{blobId: timeInfo};
    NSArray * events = @[@{@"eventName": @"SNAP_SCREENSHOT", @"params": @{@"id": blobId}, @"ts": @(ts - delay)}];
    return [SCFetcher fetcherStartedForRequestNoJSON:[self requestForSendingEvents:events snapInfo:snapInfo]
                                      callback:^(NSError * error, id result) {
                                          cb(error);
                                      }];
}

#pragma mark - Extra -

- (SCFetcher *)reloadAll:(void (^)(NSError * error))callback {
    NSDictionary * reqArgs = @{@"username": self.username};
    NSURLRequest * req = [[SCAPIRequest alloc] initWithConfiguration:self.configuration
                                                                path:@"/bq/all_updates"
                                                               token:self.authToken
                                                          dictionary:reqArgs];
    return [SCFetcher fetcherStartedForRequest:req callback:^(NSError * error, id result) {
        if (error) return callback(error);
        NSDictionary * dict = result;
        if (dict[@"updates_response"]) {
            dict = dict[@"updates_response"];
            self.snaps = [self.class parseSnaps:dict[@"snaps"]];
            self.authToken = dict[@"auth_token"];
        } else if (dict[@"snaps"]) {
            self.snaps = [self.class parseSnaps:dict[@"snaps"]];
        }
        callback(nil);
    }];
}

- (NSArray *)mediaSnaps {
    NSMutableArray * snaps = [NSMutableArray array];
    
    for (SCSnap * snap in self.snaps) {
        if ([snap isImageOrVideo]) {
            [snaps addObject:snap];
        }
    }
    
    return snaps;
}

@end
