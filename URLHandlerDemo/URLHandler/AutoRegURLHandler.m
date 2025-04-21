//
//  AutoRegURLHandler.m
//  URLHandlerDemo
//
//  Created by 林君毅 on 2025/4/21.
//

#import "AutoRegURLHandler.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>

#ifdef __LP64__
typedef uint64_t FBMachOExportValue;
typedef struct section_64 FBMachOExportSection;
#define FBGetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t FBMachOExportValue;
typedef struct section FBMachOExportSection;
#define FBGetSectByNameFromHeader getsectbynamefromheader
#endif

@interface _InnerURLHandler : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) UrlHandleImp handle;

@end

@implementation _InnerURLHandler

@end

static NSMutableArray<NSString*> *_RegisterURLs = nil;
static NSMutableDictionary<NSNumber*, _InnerURLHandler*> *_RegisterHandlers = nil;

@implementation AutoRegURLHandler

#pragma mark - Overwrite

+ (NSArray<NSString*> *)patterns {
    if (_RegisterURLs == nil) {
        [self registerAllURLs];
    }
    return _RegisterURLs;
}

+ (NSString*)usage {
    return @"自动注册路由，使用URL_EXPORT宏进行路由导入";
}

- (void)handleUrl:(NSURL *)url navi:(UINavigationController *)navi parameters:(NSDictionary *)parameters {
    if (self.matchedPatternIndex >= 0 && self.matchedPatternIndex < _RegisterURLs.count) {
        _InnerURLHandler *handler = _RegisterHandlers[@(self.matchedPatternIndex)];
        if (handler && handler.handle) {
            handler.handle(url, navi, parameters);
        }
    }
}

#pragma mark - Public

+ (BOOL)checkValid:(NSString **)errorString {
    if (_RegisterURLs == nil) {
        [self registerAllURLs];
    }
    NSCountedSet<NSString *> *set = [NSCountedSet new];
    for (NSString *url in _RegisterURLs) {
        [set addObject:url];
    }
    BOOL valid = YES;
    NSMutableString *e = [[NSMutableString alloc] initWithString:@"存在重复的路由: "];
    for (NSString *url in set) {
        if ([set countForObject:url] > 1) {
            [e appendFormat:@"%@ ", url];
            valid = NO;
        }
    }
    
    if (valid == NO) {
        *errorString = e;
    }
    return valid;
}

#pragma mark - Private

+ (void)registerAllURLs {
    _RegisterURLs  = [NSMutableArray new];
    _RegisterHandlers = [NSMutableDictionary new];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    NSString *fullAppName = [NSString stringWithFormat:@"/%@.app/", appName];
    char *fullAppNameC = (char *)[fullAppName UTF8String];

    int num = _dyld_image_count();
    int excludeCnt = sizeof(EXCLUDE_IMAGE_FOR_URL_HANDLE) / sizeof(char*);
    for (int i = 0; i < num; i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, fullAppNameC) == NULL) {
            continue;
        }
        for (int j = 0; j < excludeCnt; j++) {
            char *c = EXCLUDE_IMAGE_FOR_URL_HANDLE[j];
            if (strstr(name, c)) {
                continue;;
            }
        }
        
        const struct mach_header *header = _dyld_get_image_header(i);
        
        Dl_info info;
        dladdr(header, &info);
        
        const FBMachOExportValue dliFbase = (FBMachOExportValue)info.dli_fbase;
        const FBMachOExportSection *section = FBGetSectByNameFromHeader(header, URL_EXPORT_SEGMENT, URL_EXPORT_SECTION);
        if (section == NULL) continue;
        int addrOffset = sizeof(struct URL_HANDLE);
        for (FBMachOExportValue addr = section->offset;
             addr < section->offset + section->size;
             addr += addrOffset) {
            
            @try {
                struct URL_HANDLE entry = *(struct URL_HANDLE *)(dliFbase + addr);
                _InnerURLHandler *handle = [_InnerURLHandler new];
                handle.url =  [NSString stringWithUTF8String:entry.url];
                handle.handle = entry.handle;
                if (handle.url.length && handle.handle != NULL) {
                    [_RegisterURLs addObject:handle.url];
                    _RegisterHandlers[@(_RegisterURLs.count-1)] = handle;
                }

            } @catch (NSException *exception) {
            } @finally {
            }
        }
    }
}

    
@end
