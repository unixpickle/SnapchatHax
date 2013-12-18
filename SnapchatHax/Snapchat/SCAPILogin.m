//
//  SCAPILogin.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCAPILogin.h"

@implementation SCAPILogin

- (id)init {
    self = [self initWithConfiguration:[SCAPIConfiguration defaultAPIConfiguration]];
    return self;
}

- (id)initWithConfiguration:(SCAPIConfiguration *)configuration {
    if ((self = [super init])) {
        self.configuration = configuration;
        responseData = [NSMutableData data];
    }
    return self;
}

- (void)startLogin {
    NSDictionary * post = @{@"username": self.username,
                            @"password": self.password};
    SCAPIRequest * req = [[SCAPIRequest alloc] initWithConfiguration:self.configuration
                                                                path:@"/bq/login"
                                                               token:self.configuration.staticToken
                                                          dictionary:post];
    connection = [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)cancel {
    [connection cancel];
    connection = nil;
}

#pragma mark - Connection -

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate scAPILogin:self failedWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    connection = nil;
    NSError * error = nil;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [self.delegate scAPILogin:self failedWithError:error];
    }
    if (![dict[@"auth_token"] isKindOfClass:[NSString class]]) {
        return [self.delegate scAPILogin:self failedWithError:[NSError errorWithDomain:@"SCAPILogin"
                                                                                  code:1
                                                                              userInfo:@{NSLocalizedDescriptionKey:@"Invalid username or password."}]];
    }
    
    SCAPISession * session = [[SCAPISession alloc] init];
    session.authToken = dict[@"auth_token"];
    session.configuration = self.configuration;
    session.snaps = [SCAPISession parseSnaps:dict[@"snaps"]];
    session.username = self.username;
    [self.delegate scAPILogin:self succeededWithSession:session];
}

@end
