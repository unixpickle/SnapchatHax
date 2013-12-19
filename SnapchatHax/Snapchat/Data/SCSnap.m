//
//  SCSnap.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "SCSnap.h"

@implementation SCSnap

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        self.user = dictionary[@"sn"];
        self.timestamp = [dictionary[@"ts"] longLongValue];
        self.status = [dictionary[@"st"] longLongValue];
        self.identifier = dictionary[@"id"];
        self.media = [dictionary[@"m"] longLongValue];
        self.tField = [dictionary[@"t"] longLongValue];
    }
    return self;
}

- (BOOL)isImageOrVideo {
    return (self.media < 7 && self.media != 3);
}

#pragma mark - Obj-C Overrides -

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ user=%@, timestamp=%llu, status=%llu, identifier=%@, media=%llu, t=%llu>",
            NSStringFromClass(self.class), self.user, self.timestamp,
            self.status, self.identifier, self.media, self.tField];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SCSnap class]]) return NO;
    return [[((SCSnap *)object) identifier] isEqualToString:self.identifier];
}

@end
