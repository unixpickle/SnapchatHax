//
//  SCAPISession.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCAPIRequest.h"
#import "SCFetcher.h"

#import "SCSnap.h"
#import "SCBlob.h"

@interface SCAPISession : NSObject {
    
}

@property (nonatomic, retain) SCAPIConfiguration * configuration;
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSArray * snaps;

- (SCAPIRequest *)requestForBlob:(NSString *)blobIdentifier;
- (SCFetcher *)fetchBlob:(NSString *)blobIdentifier
                callback:(void (^)(NSError * error, SCBlob * blob))cb;

@end
