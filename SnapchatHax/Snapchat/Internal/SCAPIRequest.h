//
//  SCAPIRequest.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCAPIConfiguration.h"

@interface SCAPIRequest : NSMutableURLRequest {
    SCAPIConfiguration * encryption;
}

+ (NSString *)timestampString;
+ (NSString *)encodeQueryParam:(NSString *)param;
+ (NSString *)encodeQuery:(NSDictionary *)dict;

- (id)initWithConfiguration:(SCAPIConfiguration *)enc
                       path:(NSString *)path
                      token:(NSString *)token
                 dictionary:(NSDictionary *)dict;

@end
