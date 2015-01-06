//
//  SCAPI.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCAPIConfiguration.h"

static NSString * hexHash(NSData * input);

@implementation SCAPIConfiguration

+ (NSDictionary *)defaultOptions {
    /**
     * Graciously taken from https://github.com/tlack/snaphax/blob/master/snaphax.php
     */
    return @{@"blob_enc_key": @"M02cnQ51Ji97vwT4",
             @"pattern": @"0001110111101110001111010101111011010001001110011000110001000110",
             @"secret": @"iEk21fuwZApXlz93750dmW22pw389dPwOk",
             @"static_token": @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9",
             @"url": @"https://feelinsonice-hrd.appspot.com",
             @"user_agent": @"Snapchat/8.1.1 (iPad; iPhone OS 6.0; en_US; gzip)"};
}

+ (SCAPIConfiguration *)defaultAPIConfiguration {
    static SCAPIConfiguration * api = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api = [[SCAPIConfiguration alloc] initWithOptions:[self defaultOptions]];
    });
    return api;
}

- (id)initWithOptions:(NSDictionary *)opts {
    if ((self = [super init])) {
        options = opts;
    }
    return self;
}

- (BOOL)isValidBlobHeader:(NSData *)header {
    if (header.length < 2) return NO;
    unsigned const char * bytes = (unsigned const char *)header.bytes;
    return (bytes[0] == 0 && bytes[1] == 0) ||
           (bytes[0] == 0xff && bytes[1] == 0xd8);
}

- (NSData *)decrypt:(NSData *)data {
    NSData * result = nil;
    
    // setup key
    unsigned char cKey[16];
    bzero(cKey, sizeof(cKey));
    [self.encryptionKey getBytes:cKey length:16];
    
    // setup output buffer
    size_t bufferSize = [data length];
    void * buffer = malloc(bufferSize);
    
    // do decrypt
    size_t decryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode,
                                          cKey,
                                          16,
                                          NULL,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &decryptedSize);
    
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
    } else {
        free(buffer);
        NSLog(@"[ERROR] failed to decrypt| CCCryptoStatus: %d", cryptStatus);
    }
    
    return result;
}

- (NSData *)encrypt:(NSData *)data {
    NSData * result = nil;
    
    // setup key
    unsigned char cKey[16];
    bzero(cKey, sizeof(cKey));
    [self.encryptionKey getBytes:cKey length:16];
    
    // setup output buffer
    size_t bufferSize = [data length] + (data.length % 16);
    void * buffer = malloc(bufferSize);
    
    void * strBuffer = malloc(bufferSize);
    bzero(strBuffer, bufferSize);
    [data getBytes:strBuffer];
    
    // do encrypt
    size_t encSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode,
                                          cKey,
                                          16,
                                          NULL,
                                          strBuffer,
                                          bufferSize,
                                          buffer,
                                          bufferSize,
                                          &encSize);
    free(strBuffer);
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:encSize];
    } else {
        free(buffer);
        NSLog(@"[ERROR] failed to decrypt| CCCryptoStatus: %d", cryptStatus);
    }
    
    return result;
}

- (NSString *)dualHash:(NSData *)value1 andHash:(NSData *)value2 {
    NSMutableData * s1 = [self.secret mutableCopy];
    [s1 appendData:value1];
    NSMutableData * s2 = [value2 mutableCopy];
    [s2 appendData:self.secret];
    NSString * s3 = hexHash(s1);
    NSString * s4 = hexHash(s2);
    
    NSString * pattern = options[@"pattern"];
    NSMutableString * result = [NSMutableString string];
    for (int i = 0; i < pattern.length; i++) {
        if ([pattern characterAtIndex:i] == '0') {
            [result appendFormat:@"%C", [s3 characterAtIndex:i]];
        } else {
            [result appendFormat:@"%C", [s4 characterAtIndex:i]];
        }
    }
    return result;
}

#pragma mark - Properties -

- (NSData *)encryptionKey {
    return [options[@"blob_enc_key"] dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData *)secret {
    return [options[@"secret"] dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSString *)baseURL {
    return options[@"url"];
}

- (NSString *)staticToken {
    return options[@"static_token"];
}

- (NSString *)userAgent {
    return options[@"user_agent"];
}

@end

static NSString * hexHash(NSData * input) {
    unsigned char output[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(input.bytes, (unsigned int)input.length, output);
    NSMutableString * str = [NSMutableString string];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [str appendFormat:@"%02x", output[i]];
    }
    return str;
}
