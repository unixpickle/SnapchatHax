//
//  SCSnap.h
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SCSnapTypeImage = 0,
    SCSnapTypeVideo = 1
} SCSnapType;

@interface SCSnap : NSObject

@property (readwrite) unsigned long long status;
@property (readwrite) unsigned long long timestamp;
@property (readwrite) unsigned long long media;
@property (readwrite) unsigned long long tField;
@property (nonatomic) NSString * identifier;
@property (nonatomic) NSString * user;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
