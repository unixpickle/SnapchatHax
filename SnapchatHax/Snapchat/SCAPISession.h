//
//  SCAPISession.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCAPIRequest.h"
#import "SCSnap.h"

@interface SCAPISession : NSObject

@property (nonatomic, retain) SCAPIConfiguration * configuration;
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSArray * snaps;

- (SCAPIRequest *)requestForBlob:(NSString *)blobIdentifier;

@end
