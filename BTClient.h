//
// BTClient.h
// BingTranslator
// 
// Created by Árpád Goretity on 18/10/2011.
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "BTDefines.h"


// the Bing Translate API error domain
#define BTErrorDomain @"org.h2co3.bingtranslate"

// error codes
typedef enum {
	BTErrorMalformedRequest		= 1, // JSON syntax error in the URL query string
	BTErrorInvalidLanguage		= 2, // unsupported source/target language
	BTErrorMissingParameter		= 3, // required parameter is missing
	BTErrorAudio			= 4, // audio playback or decoding failed
	BTErrorObjectInconsistency	= 5  // different array/dictionary count for suggestions
} BTError;

@protocol BTClientDelegate;


@interface BTClient: NSObject <AVAudioPlayerDelegate> {
	NSString *appID;
	NSMutableDictionary *context;
	id <BTClientDelegate> delegate;
}

@property (readwrite, retain) NSString *appID;
@property (readwrite, assign) id <BTClientDelegate> delegate; // assign it explicitly

// go to http://www.microsoft.com/web/post/using-the-free-bing-translation-apis
// or http://www.bing.com/developers/appids.aspx to obtain an App ID
- (id) initWithAppID:(NSString *)anID;

// translate a text or array of texts. Language is the language's two-letter code (lowercase).
// array is an NSArray instance containing NSString objects.
- (void) translateText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to;
- (void) translateArray:(NSArray *)array fromLanguage:(NSString *)from toLanguage:(NSString *)to;
- (void) translateText:(NSString *)text toLanguage:(NSString *)to;
- (void) translateArray:(NSArray *)array toLanguage:(NSString *)to;

// http://msdn.microsoft.com/en-us/library/ff512393.aspx
// http://msdn.microsoft.com/en-us/library/ff512394.aspx
// Add translation suggestion for a single entry
// from and to are two-letter codes of the source and target language
// user is a unique identifier for the user who suggested the translation
// (if NULL, use bundle ID)
- (void) addSuggestion:(NSString *)suggestion forText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to;
- (void) addSuggestion:(NSString *)suggestion forText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to userName:(NSString *)user;
// add translation suggestion for an array of entries
// from and to are two-letter codes of the source and target language
// user is a unique identifier for the user who suggested the translation
// (if NULL, uses bundle ID)
- (void) addSuggestions:(NSArray *)suggestions forArray:(NSArray *)array fromLanguage:(NSString *)from toLanguage:(NSString *)to;
- (void) addSuggestions:(NSArray *)suggestions forArray:(NSArray *)array fromLanguage:(NSString *)from toLanguage:(NSString *)to userName:(NSString *)user;

// http://msdn.microsoft.com/en-us/library/ff512405.aspx
// Say it! (speak) - asynchronous; notifies delegate when
// starts and finishes speaking
// language is a two-letter code of the language of the text to be said.
// this method uses AVAudioPlayer in AVFoundation.framework
// to play the audio file at the returned URL
- (void) speakText:(NSString *)text inLanguage:(NSString *)language;
// speaks using an auto-detected language
// takes a bit longer due to the two network round-trips
- (void) speakText:(NSString *)text;

// http://msdn.microsoft.com/en-us/library/ff512396.aspx
// http://msdn.microsoft.com/en-us/library/ff512397.aspx
// Detect language of a single entry
- (void) detectLanguageOfText:(NSString *)text;
// Detect language of each element in an array
- (void) detectLanguagesOfArray:(NSArray *)array;

// http://msdn.microsoft.com/en-us/library/ff512401.aspx
// http://msdn.microsoft.com/en-us/library/ff512400.aspx
// Get list of supported (translateable and speakable) languages
- (void) getTranslationLanguages;
- (void) getSpeechLanguages;

@end


@protocol BTClientDelegate <NSObject>

// The client finished translating a single entry.
// returns the original and the translated text.
- (void) bingTranslateClient:(BTClient *)client translatedText:(NSString *)text translation:(NSString *)translation;
// The client finished translating multiple entries.
// returns the original array of texts and a translation result array.
// The result array contains of NSDictionary objects which will have values
// for the following two keys:
// BTResultKeyTranslation - the actual translated text
// BTResultKeySourceLanguage - if you used a method without specifying
// a source language, this parameter will contain the
// automatically detected one, NULL otherwise
- (void) bingTranslateClient:(BTClient *)client translatedArray:(NSArray *)array translations:(NSArray *)translations;

// suggestion for a single translation has been added
// user is the username associated with the user making the suggestion
- (void) bingTranslateClient:(BTClient *)client addedSuggestion:(NSString *)suggestion forText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to userName:(NSString *)user;
// suggestion for an array of texts has been added
// returns the base array (which are to be translated)
// user is the username associated with the user making the suggestion
- (void) bingTranslateClient:(BTClient *)client addedSuggestions:(NSArray *)suggestions forArray:(NSArray *)array fromLanguage:(NSString *)from toLanguage:(NSString *)to userName:(NSString *)user;

// the client will start to say the specified text in the speified language
// returns the text to be said and the language's two-letter code
- (void) bingTranslateClient:(BTClient *)client willStartSpeakingText:(NSString *)text inLanguage:(NSString *)language;
// the client have finished saying the specified text in the speified language
// returns the client only
- (void) bingTranslateClientFinishedSpeaking:(BTClient *)client;

// The client have detected the language of the specified text.
// language is the two-letter code of the detected language.
- (void) bingTranslateClient:(BTClient *)client detectedLanguage:(NSString *)language ofText:(NSString *)text;
// The client have detected the language of each of the specified array's elements.
// language is the two-letter code of the detected language.
- (void) bingTranslateClient:(BTClient *)client detectedLanguages:(NSArray *)languages ofArray:(NSArray *)array;

// The client obtained the supported languages
- (void) bingTranslateClient:(BTClient *)client receivedTranslationLanguages:(NSArray *)languages;
- (void) bingTranslateClient:(BTClient *)client receivedSpeechLanguages:(NSArray *)languages;

// An error occurred. [error code] will be one of the values of enum BTError
// or a standard Cocoa error code. [error domain] is likewise.
- (void) bingTranslateClient:(BTClient *)client errorOccurred:(NSError *)error;

@end

