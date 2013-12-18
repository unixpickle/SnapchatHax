//
//  SCFetcher.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCFetcher.h"

@implementation SCFetcher

+ (SCFetcher *)fetcherStartedForRequest:(NSURLRequest *)req callback:(SCFetcherBlock)block {
    SCFetcher * fetcher = [[SCFetcher alloc] initWithRequest:req];
    fetcher.callback = block;
    fetcher.parseJSON = YES;
    return fetcher;
}

+ (SCFetcher *)fetcherStartedForRequestNoJSON:(NSURLRequest *)req callback:(SCFetcherBlock)block {
    SCFetcher * fetcher = [[SCFetcher alloc] initWithRequest:req];
    fetcher.callback = block;
    return fetcher;
}

- (id)initWithRequest:(NSURLRequest *)request {
    if ((self = [super init])) {
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    }
    return self;
}

- (void)start {
    data = [NSMutableData data];
}

- (void)cancel {
    data = nil;
    [connection cancel];
    connection = nil;
}

#pragma mark - NSURLConnection -

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.callback(error, nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data {
    [data appendData:_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    connection = nil;
    if (self.parseJSON) {
        NSError * error = nil;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        data = nil;
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return self.callback(error, nil);
        }
        self.callback(nil, dict);
    } else {
        self.callback(nil, [data copy]);
        data = nil;
    }
}

@end
