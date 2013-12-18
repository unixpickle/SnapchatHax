//
//  SCBlob.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCBlob : NSObject

@property (nonatomic, retain) NSData * blobData;

+ (SCBlob *)blobWithData:(NSData *)data;
- (id)initWithData:(NSData *)data;

- (NSString *)blobFileExtension;

@end
