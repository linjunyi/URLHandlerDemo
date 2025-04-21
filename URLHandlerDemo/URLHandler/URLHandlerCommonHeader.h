//
//  URLHandlerCommonHeader.h
//  URLHandleDemo
//
//  Created by 林君毅 on 2025/4/18.
//

#ifndef URLHandlerCommonHeader_h
#define URLHandlerCommonHeader_h

#import <UIKit/UIKit.h>
#import "FBURLHandler.h"

typedef void(*UrlHandleImp)(NSURL*, UINavigationController*, NSDictionary*);

struct URL_HANDLE {
    const char *url;
    UrlHandleImp handle;
};

static char* EXCLUDE_IMAGE_FOR_URL_HANDLE[] = {
    "dylib",
};

#define URL_EXPORT_SEGMENT "__DATA"
#define URL_EXPORT_SECTION "__urlhandle"

#define C_URL_CREATE(_url_cstring, _parameters) URL_CREATE(@_url_cstring, _parameters)
#define URL_CREATE(_url, _parameters) [FBURLHandler url:_url withParameters:_parameters ?: @{}]

#define URL_EXPORT(...) \
    static void _url_handle_impl(NSURL *, UINavigationController *, NSDictionary *); \
    url_macro_concat(URL_EXPORT_, url_macro_argcount(__VA_ARGS__))(__VA_ARGS__) \
    static void _url_handle_impl(NSURL *url, UINavigationController *navi, NSDictionary *parameters)

#define URL_EXPORT_0

#define URL_EXPORT_1(_1) \
    URL_EXPORT_EACH(_1, 1)

#define URL_EXPORT_2(_1, _2) \
    URL_EXPORT_1(_1) \
    URL_EXPORT_EACH(_2, 2)

#define URL_EXPORT_3(_1, _2, _3) \
    URL_EXPORT_2(_1, _2) \
    URL_EXPORT_EACH(_3, 3)

#define URL_EXPORT_4(_1, _2, _3, _4) \
    URL_EXPORT_3(_1, _2, _3) \
    URL_EXPORT_EACH(_4, 4)

#define URL_EXPORT_5(_1, _2, _3, _4, _5) \
    URL_EXPORT_4(_1, _2, _3, _4) \
    URL_EXPORT_EACH(_5, 5)

#define URL_EXPORT_6(_1, _2, _3, _4, _5, _6) \
    URL_EXPORT_5(_1, _2, _3, _4, _5) \
    URL_EXPORT_EACH(_6, 6)

#define URL_EXPORT_7(_1, _2, _3, _4, _5, _6, _7) \
    URL_EXPORT_6(_1, _2, _3, _4, _5, _6) \
    URL_EXPORT_EACH(_7, 7)

#define URL_EXPORT_8(_1, _2, _3, _4, _5, _6, _7, _8) \
    URL_EXPORT_7(_1, _2, _3, _4, _5, _6, _7) \
    URL_EXPORT_EACH(_8, 8)

#define URL_EXPORT_9(_1, _2, _3, _4, _5, _6, _7, _8, _9) \
    URL_EXPORT_8(_1, _2, _3, _4, _5, _6, _7, _8) \
    URL_EXPORT_EACH(_9, 9)

#define URL_EXPORT_10(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    URL_EXPORT_9(_1, _2, _3, _4, _5, _6, _7, _8, _9) \
    URL_EXPORT_EACH(_10, 10)


#define URL_EXPORT_EACH(router, suffix) \
    __attribute__((used, section(URL_EXPORT_SEGMENT "," URL_EXPORT_SECTION))) \
    static const struct URL_HANDLE _url_##suffix = { \
        (const char *)((char[sizeof(format_to_c_conststring(router))]){format_to_c_conststring(router)}), \
        _url_handle_impl, \
    }; \

/*
 宏名拼接
 */
#define url_macro_concat(A, B) url_macro_concat_(A, B)
#define url_macro_concat_(A, B) A##B

/*
 将 char* 和 NSString*的参数统一转化成char*
 */
#define format_to_c_conststring(a) \
(__builtin_choose_expr( \
    __builtin_types_compatible_p(__typeof__(a), NSString*), \
    #a, \
    a \
))

/*
 计算宏参数数量，最多支持20个参数
 */
#define url_macro_argcount(...) \
        url_macro_at20(__VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

#define url_macro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) url_macro_head(__VA_ARGS__, 0)

/*
 获取宏第一个参数
 */
#define url_macro_head(HEAD, ...) HEAD


#endif /* URLHandle_h */
