//
// NSMutableString+BingTranslate.m
// BingTranslate
//
// Created by Árpád Goretity on 19/10/2011.
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "NSMutableString+BingTranslate.h"


@implementation NSMutableString (BingTranslate)

- (void) unescapeJson {
	// remove leading and trailing quotes if present
	[self replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, 1)];
	[self replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange([self length] - 1, 1)];
	// resolve \" , \/ and \\ escape sequences
	[self replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:0 range:NSMakeRange(0, [self length])];
	[self replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:0 range:NSMakeRange(0, [self length])];
	[self replaceOccurrencesOfString:@"\\/" withString:@"/" options:0 range:NSMakeRange(0, [self length])];
	// resolve most common \uxxxx sequences
	[self replaceOccurrencesOfString:@"\\u0009" withString:@"\t" options:0 range:NSMakeRange(0, [self length])];
	[self replaceOccurrencesOfString:@"\\u000a" withString:@"\n" options:0 range:NSMakeRange(0, [self length])];
	[self replaceOccurrencesOfString:@"\\u000d" withString:@"\r" options:0 range:NSMakeRange(0, [self length])];
}

@end


