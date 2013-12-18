//
//  SCBlob.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCBlob.h"
#import "SCImageBlob.h"
#import "SCVideoBlob.h"

@implementation SCBlob

+ (SCBlob *)blobWithData:(NSData *)data {
    NSArray * blobs = @[SCImageBlob.class, SCVideoBlob.class];
    for (Class c in blobs) {
        id val = [[c alloc] initWithData:data];
        if (val) return val;
    }
    return nil;
}

- (id)initWithData:(NSData *)data {
    return nil;
}

- (NSString *)blobFileExtension {
    return @"txt";
}

@end
