//
//  SCFetcher.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SCFetcherBlock)(NSError * error, id result);

@interface SCFetcher : NSObject <NSURLConnectionDelegate> {
    NSMutableData * data;
    NSURLConnection * connection;
}

@property (readwrite) BOOL parseJSON;
@property (nonatomic, copy) SCFetcherBlock callback;

+ (SCFetcher *)fetcherStartedForRequest:(NSURLRequest *)req callback:(SCFetcherBlock)block;
+ (SCFetcher *)fetcherStartedForRequestNoJSON:(NSURLRequest *)req callback:(SCFetcherBlock)block;

- (id)initWithRequest:(NSURLRequest *)request;
- (void)start;
- (void)cancel;

@end
