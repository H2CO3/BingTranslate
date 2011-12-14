//
// BTClient.m
// BingTranslator
// 
// Created by Árpád Goretity on 18/10/2011.
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <CarbonateJSON/CarbonateJSON.h>
#import "BTClient.h"
#import "NSString+BingTranslate.h"
#import "NSMutableString+BingTranslate.h"
#import "NSArray+BingTranslate.h"
#import "NSDictionary+BingTranslate.h"
#import "NSURLConnection+BingTranslate.h"

#define BTServiceTranslateText @"BTServiceTranslateText"
#define BTServiceTranslateArray @"BTServiceTranslateArray"
#define BTServiceSuggestText @"BTServiceSuggestText"
#define BTServiceSuggestArray @"BTServiceSuggestArray"
#define BTServiceDetectLanguageText @"BTServiceDetectLanguageText"
#define BTServiceDetectLanguageArray @"BTServiceDetectLanguageArray"
#define BTServiceSpeak @"BTServiceSpeak"
#define BTServiceSpeakDownload @"BTServiceSpeakDownload"
#define BTServiceAutoSpeakText @"BTServiceAutoSpeakText"
#define BTServiceGetTranslationLanguages @"BTServiceGetTranslationLanguages"
#define BTServiceGetSpeechLanguages @"BTServiceGetSpeechLanguages"


@implementation BTClient

@synthesize appID;
@synthesize delegate;

// super

- (id) init {
	// one must explicitly set an appID after using this
	self = [self initWithAppID:NULL];
	return self;
}

- (void) dealloc {
	self.appID = NULL;
	[context release];
	[super dealloc];
}

// self

- (id) initWithAppID:(NSString *)anID {
	// the designated initializer
	self = [super init];
	self.appID = anID;
	context = [[NSMutableDictionary alloc] init];
	return self;
}

// Translation methods

- (void) translateText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to {
	NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/Translate?appId=%@&text=%@&to=%@", self.appID, [text urlEscapedString], to];
	if (from != NULL) {
		[urlString appendFormat:@"&from=%@", from];
	}
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceTranslateText, @"type", text, @"original", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

- (void) translateArray:(NSArray *)array fromLanguage:(NSString *)from toLanguage:(NSString *)to {
	NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/TranslateArray?appId=%@&texts=%@&to=%@", self.appID, [array escapedJsonString], to];
	if (from != NULL) {
		[urlString appendFormat:@"&from=%@", from];
	}
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceTranslateArray, @"type", array, @"original", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

- (void) translateText:(NSString *)text toLanguage:(NSString *)to {
	[self translateText:text fromLanguage:NULL toLanguage:to];
}

- (void) translateArray:(NSArray *)array toLanguage:(NSString *)to {
	[self translateArray:array fromLanguage:NULL toLanguage:to];
}

// Translation suggestion methods

- (void) addSuggestion:(NSString *)suggestion forText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to {
	[self addSuggestion:suggestion forText:text fromLanguage:from toLanguage:to userName:NULL];
}

- (void) addSuggestion:(NSString *)suggestion forText:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to userName:(NSString *)user {
	NSString *userName = (user != NULL) ? user : [[NSBundle mainBundle] bundleIdentifier];
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/AddTranslation?appId=%@&user=%@&rating=5&originalText=%@&translatedText=%@&from=%@&to=%@", self.appID, userName, [text urlEscapedString], [suggestion urlEscapedString], from, to];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceSuggestText, @"type", text, @"original", suggestion, @"suggestion", from, @"from", to, @"to", userName, @"user", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

- (void) addSuggestions:(NSArray *)suggestions forArray:(NSArray *)array fromLanguage:(NSString *)from toLanguage:(NSString *)to {
	[self addSuggestions:suggestions forArray:array fromLanguage:from toLanguage:to userName:NULL];
}

- (void) addSuggestions:(NSArray *)suggestions forArray:(NSArray *)array fromLanguage:(NSString *)from toLanguage:(NSString *)to userName:(NSString *)user {
	if ([array count] != [suggestions count]) {
		// error: one has to provide the same amount
		// of suggestions as of the original texts
		NSError *error = [[NSError alloc] initWithDomain:BTErrorDomain code:BTErrorObjectInconsistency userInfo:NULL];
		[delegate bingTranslateClient:self errorOccurred:error];
		[error release];
		return;
	}
	NSString *userName = (user != NULL) ? user : [[NSBundle mainBundle] bundleIdentifier];
	NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:userName, @"User", NULL];
	NSMutableArray *translations = [[NSMutableArray alloc] init];
	for (int i = 0; i < [array count]; i++) {
		NSDictionary *propertyDict = [[NSDictionary alloc] initWithObjectsAndKeys:[array objectAtIndex:i], @"OriginalText", [suggestions objectAtIndex:i], @"TranslatedText", @"5", @"Rating", NULL];
		[translations addObject:propertyDict];
		[propertyDict release];
	}
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/AddTranslationArray?appId=%@&translations=%@&options=%@&from=%@&to=%@", self.appID, [translations escapedJsonString], [options escapedJsonString], from, to];
	[translations release];
	[options release];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceSuggestArray, @"type", array, @"original", suggestions, @"suggestion", from, @"from", to, @"to", userName, @"user", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

// Speech methods

- (void) speakText:(NSString *)text inLanguage:(NSString *)language {
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/Speak?appId=%@&text=%@&language=%@", self.appID, [text urlEscapedString], language];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	NSString *key = [NSString keyWithObject:connection];
	[urlString release];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceSpeak, @"type", text, @"original", language, @"language", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

- (void) speakText:(NSString *)text {
	// first of all, detect the language of text
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/Detect?appId=%@&text=%@", self.appID, [text urlEscapedString]];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	// BTServiceAutoSpeakText means that we are using this as an internal method
	// so no delegate notifications should be sent
	// instead - [self speakText:inLanguage:] will be invoked
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceAutoSpeakText, @"type", text, @"original", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

// Language detection methods

- (void) detectLanguageOfText:(NSString *)text {
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/Detect?appId=%@&text=%@", self.appID, [text urlEscapedString]];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceDetectLanguageText, @"type", text, @"original", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

- (void) detectLanguagesOfArray:(NSArray *)array {
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/DetectArray?appId=%@&texts=%@", self.appID, [array escapedJsonString]];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceDetectLanguageArray, @"type", array, @"original", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

// Getting supported languages

- (void) getTranslationLanguages {
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/GetLanguagesForTranslate&appId=%@", self.appID];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceGetTranslationLanguages, @"type", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

- (void) getSpeechLanguages {
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.microsofttranslator.com/V2/Ajax.svc/GetLanguagesForSpeak&appId=%@", self.appID];
	NSURLConnection *connection = [NSURLConnection connectionWithUrlString:urlString delegate:self];
	[urlString release];
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [[NSMutableData alloc] init];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", BTServiceGetSpeechLanguages, @"type", NULL];
	[data release];
	[context setObject:dict forKey:key];
	[dict release];
}

// NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData {
	NSString *key = [NSString keyWithObject:connection];
	NSMutableData *data = [(NSDictionary *)[context objectForKey:key] objectForKey:@"data"];
	[data appendData:newData];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSString *key = [NSString keyWithObject:connection];
	[context removeObjectForKey:key];
	[delegate bingTranslateClient:self errorOccurred:error];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	// communication with the server has succeeded
	// get the connection's ID
	NSString *key = [NSString keyWithObject:connection];
	// and its context dictionary
	NSDictionary *dict = [context objectForKey:key];
	// and the associated received data
	NSMutableData *data = [dict objectForKey:@"data"];
	// type of the operation the server executed
	NSString *type = [dict objectForKey:@"type"];
	// the server responds with UTF-8 strings
	NSMutableString *result = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	// first see if the response is one of the server's error messages
	if ([result hasPrefix:@"\"ArgumentOutOfRangeException:"]) {
		// user specified an invalid language code
		NSError *error = [[NSError alloc] initWithDomain:BTErrorDomain code:BTErrorInvalidLanguage userInfo:NULL];
		[delegate bingTranslateClient:self errorOccurred:error];
		[error release];
	} else if ([result hasPrefix:@"\"ArgumentNullException:"]) {
		// text to be translated or target language is missing
		NSError *error = [[NSError alloc] initWithDomain:BTErrorDomain code:BTErrorMissingParameter userInfo:NULL];
		[delegate bingTranslateClient:self errorOccurred:error];
		[error release];
	} else if ([result hasPrefix:@"\"There was an error deserializing the object of type"]) {
		// malformed request
		NSError *error = [[NSError alloc] initWithDomain:BTErrorDomain code:BTErrorMalformedRequest userInfo:NULL];
		[delegate bingTranslateClient:self errorOccurred:error];
		[error release];
	} else {
		// no errors were encountered
		if ([type isEqualToString:BTServiceTranslateText]) {
			// single translation
			[result unescapeJson];
			[delegate bingTranslateClient:self translatedText:[dict objectForKey:@"original"] translation:result];
		} else if ([type isEqualToString:BTServiceTranslateArray]) {
			// multiple translation
			NSArray *resultArray = [result translationResults];
			[delegate bingTranslateClient:self translatedArray:[dict objectForKey:@"original"] translations:resultArray];
		} else if ([type isEqualToString:BTServiceSuggestText]) {
			// suggest text
			// we don't expect any response (there isn't even any)
			// so just notify the delegate
			[delegate bingTranslateClient:self addedSuggestion:[dict objectForKey:@"suggestion"] forText:[dict objectForKey:@"original"] fromLanguage:[dict objectForKey:@"from"] toLanguage:[dict objectForKey:@"to"] userName:[dict objectForKey:@"user"]];
		} else if ([type isEqualToString:BTServiceSuggestArray]) {
			// suggest multiple texts
			// we don't expect any response (there isn't even any)
			// so just notify the delegate
			[delegate bingTranslateClient:self addedSuggestions:[dict objectForKey:@"suggestion"] forArray:[dict objectForKey:@"original"] fromLanguage:[dict objectForKey:@"from"] toLanguage:[dict objectForKey:@"to"] userName:[dict objectForKey:@"user"]];
		} else if ([type isEqualToString:BTServiceDetectLanguageText]) {
			// detect language of a text
			NSString *text = [dict objectForKey:@"original"];
			[result unescapeJson];
			[delegate bingTranslateClient:self detectedLanguage:result ofText:text];
		} else if ([type isEqualToString:BTServiceDetectLanguageArray]) {
			// detect language of multiple texts
			NSArray *texts = [dict objectForKey:@"original"];
			NSArray *languages = [result detectionResults];
			[delegate bingTranslateClient:self detectedLanguages:languages ofArray:texts];
		} else if ([type isEqualToString:BTServiceSpeak]) {
			// speak (say text)
			NSString *text = [dict objectForKey:@"original"];
			NSString *language = [dict objectForKey:@"language"];
			[result unescapeJson];
			// the response is another URL
			// containing the actual audio data
			NSURLConnection *downloadConnection = [NSURLConnection connectionWithUrlString:result delegate:self];
			NSString *downloadKey = [NSString keyWithObject:downloadConnection];
			NSMutableData *downloadData = [[NSMutableData alloc] init];
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:downloadData, @"data", BTServiceSpeakDownload, @"type", text, @"original", language, @"language", NULL];
			[downloadData release];
			[context setObject:dict forKey:downloadKey];
			[dict release];
		} else if ([type isEqualToString:BTServiceSpeakDownload]) {
			// finished downloading speech data
			[delegate bingTranslateClient:self willStartSpeakingText:[dict objectForKey:@"original"] inLanguage:[dict objectForKey:@"language"]];
			// the player will be released by its
			// delegate when it stops playing
			NSError *error = NULL;
			AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
			if (error != NULL) {
				[delegate bingTranslateClient:self errorOccurred:error];
			} else {
				player.volume = 1.0;
				player.delegate = self;
				[player play];
			}
		} else if ([type isEqualToString:BTServiceAutoSpeakText]) {
			// language detection finished,
			// now actually say it
			NSString *text = [dict objectForKey:@"original"];
			[result unescapeJson];
			[self speakText:text inLanguage:result];
		} else if ([type isEqualToString:BTServiceGetTranslationLanguages]) {
			NSArray *langs = [result parseJson];
			[delegate bingTranslateClient:self receivedTranslationLanguages:langs];
		} else if ([type isEqualToString:BTServiceGetSpeechLanguages]) {
			NSArray *langs = [result parseJson];
			[delegate bingTranslateClient:self receivedSpeechLanguages:langs];
		}
	}
	// clean up
	[context removeObjectForKey:key];
	[result release];
}

// AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[player release];
	if (flag == YES) {
		[delegate bingTranslateClientFinishedSpeaking:self];
	} else {
		NSError *error = [[NSError alloc] initWithDomain:BTErrorDomain code:BTErrorAudio userInfo:NULL];
		[delegate bingTranslateClient:self errorOccurred:error];
		[error release];
	}
}

- (void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	[player release];
	[delegate bingTranslateClient:self errorOccurred:error];
}

@end

