//
//  SCVideoBlob.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCVideoBlob.h"

@implementation SCVideoBlob

- (id)initWithData:(NSData *)data {
    if (data.length < 2) return nil;
    if (((const char *)data.bytes)[0] != 0 || ((const char *)data.bytes)[1] != 0) return nil;
    if ((self = [super init])) {
        self.blobData = data;
    }
    return self;
}

- (NSString *)blobFileExtension {
    return @"mp4";
}

@end
