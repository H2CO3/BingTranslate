//
// NSString+BingTranslate.h
// BingTranslate
//
// Created by Árpád Goretity on 18/10/2011.
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <Foundation/Foundation.h>

#define BTResultKeySourceLanguage @"BTResultKeySourceLanguage"
#define BTResultKeyTranslation @"BTResultKeyTranslation"


@interface NSString (BingTranslate)
+ (NSString *) keyWithObject:(NSObject *)object;
- (NSArray *) translationResults;
- (NSArray *) detectionResults;
- (NSString *) urlEscapedString;
@end

