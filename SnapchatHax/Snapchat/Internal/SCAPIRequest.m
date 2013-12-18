//
//  SCAPIRequest.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCAPIRequest.h"

@implementation SCAPIRequest

+ (NSString *)timestampString {
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    return [NSString stringWithFormat:@"%llu", (unsigned long long)round(time * 1000.0)];
}

+ (NSString *)encodeQueryParam:(NSString *)param {
    NSMutableString * str = [NSMutableString string];
    for (NSInteger i = 0; i < param.length; i++) {
        unichar aChar = [param characterAtIndex:i];
        if (isalnum(aChar)) {
            [str appendFormat:@"%C", aChar];
        } else {
            [str appendFormat:@"%%%02X", (unsigned char)aChar];
        }
    }
    return str;
}

+ (NSString *)encodeQuery:(NSDictionary *)dict {
    NSMutableString * str = [NSMutableString string];
    
    for (NSString * key in dict) {
        if (str.length) [str appendString:@"&"];
        [str appendFormat:@"%@=%@", [self encodeQueryParam:key],
         [self encodeQueryParam:[dict[key] description]]];
    }
    
    return str;
}

- (id)initWithConfiguration:(SCAPIConfiguration *)enc
                       path:(NSString *)path
                      token:(NSString *)token
                 dictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", enc.baseURL, path]]];
        [self setHTTPMethod:@"POST"];
        NSMutableDictionary * jsonBody = [dict mutableCopy];
        NSString * timestamp = self.class.timestampString;
        jsonBody[@"req_token"] = [enc dualHash:[token dataUsingEncoding:NSUTF8StringEncoding]
                                       andHash:[timestamp dataUsingEncoding:NSUTF8StringEncoding]];
        jsonBody[@"timestamp"] = @([timestamp longLongValue]);
        NSData * encoded = [[self.class encodeQuery:jsonBody] dataUsingEncoding:NSASCIIStringEncoding];
        [self setHTTPBody:encoded];
        [self setValue:[NSString stringWithFormat:@"%d", (int)encoded.length]
    forHTTPHeaderField:@"Content-Length"];
        [self setValue:enc.userAgent forHTTPHeaderField:@"User-Agent"];
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}

@end
