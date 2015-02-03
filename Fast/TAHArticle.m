//
//  TAHArticle.m
//  Fast
//
//  Created by Tom Hutchinson on 20/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "TAHArticle.h"

@implementation TAHArticle

#pragma mark - MTLJSONSerializingDelegate
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"title" : @"title",
             @"abstract" : @"abstract",
             @"url" : @"url",
             @"datepublished" : @"datepublished"};
}

#pragma mark - MTLManagedObjectSerializingDelegate
+ (NSString *)managedObjectEntityName {
    return @"Article";
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{@"title" : @"title",
             @"abstract" : @"abstract",
             @"url" : @"url",
             @"datepublished" : @"datepublished",
             @"primaryTag" : @"primaryTag"};
}

#pragma mark - MTLValueTransformer
+ (NSValueTransformer *)datepublishedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(NSNumber *date) {
        return [NSDate dateWithTimeIntervalSince1970:date.doubleValue];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return dateFormatter;
}

@end
