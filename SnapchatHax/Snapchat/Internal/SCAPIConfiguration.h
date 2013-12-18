//
//  SCAPI.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

@interface SCAPIConfiguration : NSObject {
    NSDictionary * options;
}

@property (readonly) NSData * encryptionKey;
@property (readonly) NSData * secret;
@property (readonly) NSString * baseURL;
@property (readonly) NSString * staticToken;
@property (readonly) NSString * userAgent;

+ (NSDictionary *)defaultOptions;
+ (SCAPIConfiguration *)defaultAPIConfiguration;

- (id)initWithOptions:(NSDictionary *)opts;

- (BOOL)isValidBlobHeader:(NSData *)header;
- (NSData *)decrypt:(NSData *)data;
- (NSData *)encrypt:(NSData *)data;
- (NSString *)dualHash:(NSData *)value1 andHash:(NSData *)value2;

@end
