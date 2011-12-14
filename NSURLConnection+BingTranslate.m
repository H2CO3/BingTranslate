//
// NSURLConnection+BingTranslate.m
// BingTranslate
//
// Created by Árpád Goretity on 18/10/2011.
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "NSURLConnection+BingTranslate.h"


@implementation NSURLConnection (BingTranslate)

+ (NSURLConnection *) connectionWithUrlString:(NSString *)urlString delegate:(NSObject *)delegate {
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
	[url release];
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:delegate];
	[urlRequest release];
	return connection;
}

@end

