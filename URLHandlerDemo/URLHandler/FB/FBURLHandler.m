//
//  FBURLHandler.m
//  FBAppContext
//
//  Created by koujun on 2022/8/31.
//  Copyright © 2022 Fenbi. All rights reserved.
//

#import "FBURLHandler.h"
#import "FBURLHandlerProtocol.h"
#import "FBURLHelper.h"

#define kReplacementStart @"{"
#define kReplacementEnd @"}"
#define kIntegerRequiredPrefix @"!"

@interface FBURLHandler()<FBURLHandlerProtocol>
@property (nonatomic, readwrite) NSUInteger matchedPatternIndex;
@end

@implementation FBURLHandler

+(NSString*)description {
    return [NSString stringWithFormat:@"%@ url:%@ usage:%@ requiredKeys:%@, optionalKeys:%@",[super description], [self patterns], [self usage],[self requiredKeys], [self optionalKeys]];
}

+(NSString*)usage {
    return @"base url handler";
}

+(NSArray<NSString*>*)patterns {
    return nil;
}

+(FBURLHandlerType)type {
    return FBURLHandlerTypeNative;
}

+(NSArray<NSString*>*)requiredKeys {
    if ([[self patterns] count]) {
        NSArray * patternComps = [[self patterns][0] pathComponents];
        NSMutableArray *result = [NSMutableArray array];
        
        NSUInteger count = [patternComps count];
        
        for (int i = 0; i < count; i++) {
            NSString *p = patternComps[i];
            if ([p hasPrefix:kReplacementStart] && [p hasSuffix:kReplacementEnd]) {
                NSString *key = [p substringWithRange:NSMakeRange(1, p.length-2)];
                [result addObject:key];
            }
        }
        NSArray *additional = [self additionalRequiredKeys];
        if ([additional count]) {
            [result addObjectsFromArray:additional];
        }
        return result;
    }
    return nil;
}

+(NSArray<NSString*>*)optionalKeys {
    return nil;
}

+(NSArray<NSString*>*)additionalRequiredKeys {
    return nil;
}

+ (void)parseURLQuery:(NSString*)query toParameters:(NSMutableDictionary*)parameters {
    if([query length]) {
        NSArray *kvs = [query componentsSeparatedByString:@"&"];
        for (NSString *item in kvs) {
            NSRange range = [item rangeOfString:@"="];
            if (range.location != NSNotFound) {
                NSString *key = [item substringToIndex:range.location];
                NSString *value = [item substringFromIndex:range.location+1];
                value = [FBURLHelper urlDecode:value];
                if (key && value) {
                    parameters[key]=value;
                }
            }
        }
    }
}

- (void)handleUrl:(NSURL*)url navi:(UINavigationController*)navi parameters:(NSDictionary<NSString*,NSString*>*_Nullable)parameters {
    
}

//+(NSArray<NSString*>*)patternComponents:(NSString*)pattern {
//    NSURL *patternUrl = [NSURL URLWithString:pattern];
//    NSArray * patternComps = patternUrl.pathComponents;
//    if (patternUrl == nil) {
//        patternComps = [pattern pathComponents];
//    }
//    return patternComps;
//}
//
//+ (BOOL)isConflictWithHandler:(Class)handlerClass {
//    for (NSString* pattern in [self patterns]) {
//        NSArray<NSString*>* pcs = [self patternComponents:pattern];
//        for (NSString* checkPattern in [handlerClass patterns]) {
//            NSArray<NSString*>* cpcs = [handlerClass patternComponents:checkPattern];
//            BOOL conflict = NO;
//            if ([pcs count] == [cpcs count]) {
//                conflict = YES;
//                for (NSUInteger idx = 0; idx < [pcs count]; idx++) {
//                    NSString *c = pcs[idx];
//                    NSString *cc = cpcs[idx];
//                    if (![c hasPrefix:kReplacementStart] && ![cc hasPrefix:kReplacementStart]) {
//                        conflict = [c isEqualToString:cc];
//                        if (conflict == NO) {
//                            break;
//                        }
//                    }
//                }
//            }
//
//            if (conflict) {
//                return YES;
//            }
//        }
//    }
//    return NO;
//}

+ (BOOL)isIntegerValue:(NSString*)value {
    if([value length]) {
        NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSRange r = [value rangeOfCharacterFromSet:nonNumbers];
        return r.location == NSNotFound;
    }
    return NO;
}

+ (NSString*)realKey:(NSString*)key {
    if ([key hasPrefix:kIntegerRequiredPrefix]) {
        key = [key substringFromIndex:[kIntegerRequiredPrefix length]];
    }
    return key;
}

+ (BOOL)canHandleUrl:(NSURL*)url pattern:(NSString*)pattern parameters:(NSDictionary**)parameters {
    NSArray *urlComps = [url pathComponents];
    NSURL *patternUrl = [NSURL URLWithString:pattern];
    NSArray * patternComps = patternUrl.pathComponents;
    NSString * patternScheme = patternUrl.scheme;
    NSString * patternHost = patternUrl.host;
    if (patternUrl == nil) {
        patternComps = [pattern pathComponents];
    }
    
    //check scheme if needed
    if ([patternScheme length] && [url.scheme isEqualToString:patternScheme] == NO) {
        return NO;
    }
    
    //check host if needed
    if ([patternHost length] && [url.host isEqualToString:patternHost] == NO) {
        return NO;
    }
    
    //check path if needed
    NSUInteger count = [patternComps count];
    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    if ([urlComps count] == count) {
        for (int i = 0; i < count; i++) {
            NSString *p = patternComps[i];
            if ([p hasPrefix:kReplacementStart] && [p hasSuffix:kReplacementEnd]) {
                NSString *key = [p substringWithRange:NSMakeRange(1, p.length-2)];
                if ([key hasPrefix:kIntegerRequiredPrefix]) {
                    if ([self isIntegerValue:urlComps[i]]) {
                        key = [self realKey:key];
                        output[key]=urlComps[i];
                    } else {
                        return NO;
                    }
                } else {
                    output[key]=urlComps[i];
                }
                
            } else if ([p isEqualToString:urlComps[i]] == NO) {
                return NO;
            }
        }
        
        NSString *query = url.query;
        [self parseURLQuery:query toParameters:output];
        if (parameters) {
            *parameters = output;
        }
        return YES;
    }
    return NO;
}

+(NSUInteger)patternRate:(NSArray<NSString*> *)patternComps {
    if([patternComps count] < 1) {
        return 0;
    }
    
    NSUInteger result = 0;
    NSUInteger unit = 1;
    for (NSInteger idx = [patternComps count]; idx >= 1; idx-- ) {
        if ([patternComps[idx-1] hasPrefix:kReplacementStart] && [patternComps[idx-1] hasSuffix:kReplacementEnd]) {
            if([patternComps[idx-1] hasPrefix:[NSString stringWithFormat:@"%@%@",kReplacementStart,kIntegerRequiredPrefix]]) {
                result += (2 * unit);
            } else {
                result += (1 * unit);
            }
        } else {
            result += (3 * unit);
        }
        unit *= 10;
    }
    return result;
}

+ (NSArray<NSNumber*>*)sortedPatternIndexs:(NSUInteger)pathCompentCount {
    if([[self patterns] count] == 1) {
        return @[@0];
    } else {
        NSMutableDictionary<NSNumber*,NSNumber*> *indexRate = [NSMutableDictionary dictionaryWithCapacity:pathCompentCount];
        NSUInteger idx = 0;
        for (NSString *pattern in [self patterns]) {
            NSURL *patternUrl = [NSURL URLWithString:pattern];
            NSArray * patternComps = patternUrl.pathComponents;
            if (patternUrl == nil) {
                patternComps = [pattern pathComponents];
            }
            
            if([patternComps count] == pathCompentCount) {
                indexRate[@(idx)] = @([self patternRate:patternComps]);
            }
            idx++;
        }
        
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:pathCompentCount];
        for (NSNumber *index in indexRate.allKeys) {
            if([result count] == 0) {
                [result addObject:index];
            } else {
                NSInteger rate = [indexRate[index] integerValue];
                BOOL inserted = NO;
                for (NSUInteger idx = 0; idx < [result count]; idx++) {
                    NSNumber *idxRate = indexRate[result[idx]];
                    if (rate > [idxRate integerValue]) {
                        [result insertObject:index atIndex:idx];
                        inserted = YES;
                        break;
                    }
                }
                if (inserted == NO) {
                    [result addObject:index];
                }
            }
        }
        return result;
    }
}

+ (BOOL)canHandleUrl:(NSString*)urlString type:(FBURLHandlerType)type parameters:(NSDictionary*_Nullable *_Nullable)parameters {
    return [self canHandleUrl:urlString type:type parameters:parameters matchedIndex:NULL];
}

+ (BOOL)canHandleUrl:(NSString*)urlString type:(FBURLHandlerType)type parameters:(NSDictionary**)parameters matchedIndex:(NSUInteger*)matchedIndex {
    NSURL *aUrl = [NSURL URLWithString:urlString];
    if (aUrl) {
        BOOL handle = NO;
        NSArray<NSNumber*> *sortedIndex = [self sortedPatternIndexs:aUrl.pathComponents.count];
        if ([sortedIndex count]) {
            for (NSNumber *index in sortedIndex) {
                NSString *alias = [self patterns][[index intValue]];
                handle = [self canHandleUrl:aUrl pattern:alias parameters:parameters];
                if (handle) {
                    if (matchedIndex) {
                        *matchedIndex = [index intValue];
                    }
                    return YES;
                }
            }
        }
    }
    return NO;
}

+ (BOOL)canHandleUrl:(NSString*)urlString type:(FBURLHandlerType)type parameters:(NSDictionary**)parameters toURL:(NSURL *__autoreleasing *)URL matchedIndex:(NSUInteger*)matchedIndex {
    if ((type & [self type]) != 0) {
        BOOL handle = [self canHandleUrl:urlString type:type parameters:parameters matchedIndex:matchedIndex];
        if (URL) {
            *URL = [NSURL URLWithString:urlString];
        }
        return handle;
    }
    return NO;
}

+ (NSString*)urlWithParameters:(NSDictionary*_Nullable)parameters {
    NSArray<NSString*> *all = [self patterns];
    return [self _urlWithPatterns:all parameters:parameters];
}

+ (NSString*)url:(NSString *)url withParameters:(NSDictionary*_Nullable)parameters {
    if (url == nil) {
        return nil;
    }
    return [self _urlWithPatterns:@[url] parameters:parameters];
}

+ (NSString *)_urlWithPatterns:(NSArray<NSString*> *)all parameters:(NSDictionary*_Nullable)parameters {
    if ([all count]) {
        NSMutableArray * patternComps = [[all[0] pathComponents] mutableCopy];
        NSMutableString *result = [all[0] mutableCopy];

        NSMutableDictionary *mParameters = nil;
        if (parameters) {
           mParameters = [parameters mutableCopy];
        }

        NSUInteger count = [patternComps count];

        for (int i = 0; i < count; i++) {
            NSString *p = patternComps[i];
            if ([p hasPrefix:kReplacementStart] && [p hasSuffix:kReplacementEnd]) {
                NSString *key = [p substringWithRange:NSMakeRange(1, p.length-2)];
                key = [self realKey:key];
                NSRange range = [result rangeOfString:p];
                id value = mParameters[key];
                BOOL isValidValueType = [value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class];
                if (value && isValidValueType) {
                    [result replaceCharactersInRange:range withString:[value isKindOfClass:NSString.class]?value:[value stringValue]];
                } else {
                    return nil;
                }
                [mParameters removeObjectForKey:key];
            }
        }

        if ([[mParameters allKeys] count]) {
            [result appendString:@"?"];
            for (NSString *key in [mParameters allKeys]) {
                id value = mParameters[key];
                value = [value isKindOfClass:NSString.class]?value:[value stringValue];
                [result appendFormat:@"&%@=%@",key,[FBURLHelper urlEncode:value]];
            }
        }
        return result;
    }
    return nil;
}

+ (BOOL)shouldCreateNavigationControllerWhenHandlePush:(NSString*)route patternIndex:(NSUInteger)index
{
    return YES;
}

@end
