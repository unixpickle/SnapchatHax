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
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ user=%@, timestamp=%llu, status=%llu, identifier=%@>",
            NSStringFromClass(self.class), self.user, self.timestamp,
            self.status, self.identifier];
}

@end
