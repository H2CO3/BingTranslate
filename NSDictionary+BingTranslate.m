//
// NSDictionary+BingTranslate.m
// BingTranslate
//
// Created by Árpád Goretity on 21/10/2011.
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "NSDictionary+BingTranslate.h"
#import "NSString+BingTranslate.h"
#import <CarbonateJSON/CarbonateJSON.h>


@implementation NSDictionary (BingTranslate)

- (NSString *) escapedJsonString {
	NSString *json = [self generateJson];
	NSString *ret = [json urlEscapedString];
	return ret;
}

@end

