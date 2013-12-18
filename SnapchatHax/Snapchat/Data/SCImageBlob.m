//
//  SCImageBlob.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCImageBlob.h"

@implementation SCImageBlob

- (id)initWithData:(NSData *)data {
    if (data.length < 2) return nil;
    if (((const unsigned char *)data.bytes)[0] != 0xff ||
        ((const unsigned char *)data.bytes)[1] != 0xd8) return nil;
    if ((self = [super init])) {
        self.blobData = data;
    }
    return self;
}

- (NSString *)blobFileExtension {
    return @"jpg";
}

@end
