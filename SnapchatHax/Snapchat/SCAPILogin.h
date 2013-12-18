//
//  SCAPILogin.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCAPISession.h"

@protocol SCAPILoginDelegate

- (void)scAPILogin:(id)sender failedWithError:(NSError *)error;
- (void)scAPILogin:(id)sender succeededWithSession:(SCAPISession *)session;

@end

@interface SCAPILogin : NSObject <NSURLConnectionDelegate> {
    NSMutableData * responseData;
    NSURLConnection * connection;
}

@property (nonatomic, weak) id<SCAPILoginDelegate> delegate;
@property (nonatomic, weak) SCAPIConfiguration * configuration;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;

- (id)initWithConfiguration:(SCAPIConfiguration *)configuration;
- (void)startLogin;
- (void)cancel;

@end
