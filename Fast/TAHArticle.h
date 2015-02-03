//
//  TAHArticle.h
//  Fast
//
//  Created by Tom Hutchinson on 20/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "MTLManagedObjectAdapter.h"
#import "MTLValueTransformer.h"

@interface TAHArticle : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *abstract;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSDate *datepublished;
@property (copy, nonatomic) NSString *primaryTag;

@end
