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

- (SCFetcher *)reloadAll:(void (^)(NSError * error))callback {
    NSDictionary * reqArgs = @{@"username": self.username};
    NSURLRequest * req = [[SCAPIRequest alloc] initWithConfiguration:self.configuration
                                                                path:@"/bq/all_updates"
                                                               token:self.authToken
                                                          dictionary:reqArgs];
    return [SCFetcher fetcherStartedForRequest:req callback:^(NSError * error, id result) {
        if (error) return callback(error);
        NSDictionary * dict = result;
        if (dict[@"update_response"]) {
            dict = dict[@"update_response"];
            self.snaps = [self.class parseSnaps:dict[@"snaps"]];
            self.authToken = dict[@"auth_token"];
        }
        callback(nil);
    }];
}

- (NSArray *)mediaSnaps {
    NSMutableArray * snaps = [NSMutableArray array];
    
    for (SCSnap * snap in self.snaps) {
        if (snap.media == SCSnapTypeImage || snap.media == SCSnapTypeVideo) {
            [snaps addObject:snap];
        }
    }
    
    return snaps;
}

@end
