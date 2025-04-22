在日常开发中，我们常常需要为每个功能页面分配独立的路由。传统做法通常有两种方案：

1. **集中式管理路由**：实现一个统一的路由类（如 `URLHandler`），在其中集中注册所有路由。新功能上线时，需要手动向该类中添加路由逻辑。
2. **模块化管理路由**：为每个功能实现一个对应的路由类（如 `FunNewURLHandler`），再将该类名添加到 `plist` 或模块静态数组中，统一加载。

第一种方案随着功能数量增长，`URLHandler` 会变得臃肿且耦合度高，维护难度大。第二种方式虽然更合理，但仍然存在一些问题：

- 管理中心化，需要开发者主动注册；
- 会增加类的数量，影响启动速度；
- 注册步骤繁琐，若遗漏注册路径（如 `plist` 或模块静态数组），可能导致路由不生效。

那么是否有一种“去中心化”的方案，使得每个功能页面只需定义自己的路由及处理逻辑，**无需额外注册操作，App 运行时可自动完成注册？**

这正是本文将介绍的实现方式。

## 利用 Mach-O 特性实现自动注册

通过如下方式，我们可以在编译阶段将数据写入 Mach-O 文件的指定段中：

```
__attribute__((used, section("__DATA,__urlhandle")))
```
- ```used```：防止 Release 环境下被链接器优化掉；
- ```section```：指定写入位置，这里是``` __DATA``` 段下的 ```__urlhandle``` 区域。

### 1. 路由结构体定义
```
typedef void(*UrlHandleImp)(NSURL*, UINavigationController*, NSDictionary*);

struct URL_HANDLE {
    const char *url;
    UrlHandleImp handle;
};
```
```url```：存储路由路径；
```handle```：指向路由触发时调用的函数指针。

通过 ```__attribute__``` 声明，将路由所对应的 ```static struct URL_HANDLE ```写入指定 section。App 运行时，使用 ```dyld``` 懒加载读取，构建路由表，并添加至 ```FBURLRouter ```中。

### 2. 路由注册宏定义

为了方便注册路由，定义了一套宏：
```
#define URL_EXPORT(...) \
    URL_EXPORT_WITH_LINE_CODE(__LINE__, __VA_ARGS__)

#define URL_EXPORT_WITH_LINE_CODE(line, ...) \
    static void URL_EXPORT_IMPL_NAME(line)(NSURL *, UINavigationController *, NSDictionary *); \
    url_macro_concat(URL_EXPORT_, url_macro_argcount(__VA_ARGS__))(line, __VA_ARGS__) \
    static void URL_EXPORT_IMPL_NAME(line)(NSURL *url, UINavigationController *navi, NSDictionary *parameters)
```
多参数展开示例（最多支持10个参数）：
```
#define URL_EXPORT_10(line, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    URL_EXPORT_9(line, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    URL_EXPORT_EACH(line, _10, 10)
```
每个url被展开为:
```
#define URL_EXPORT_EACH(line, router, suffix) \
    __attribute__((used, section(FB_URL_EXPORT_SEGMENT "," URL_EXPORT_SECTION))) \
    static const struct URL_HANDLE URL_EXPORT_VAR_NAME(line, suffix) = { \
        (const char *)((char[sizeof(format_to_c_conststring(router))]){format_to_c_conststring(router)}), \
        URL_EXPORT_IMPL_NAME(line), \
    };
```
为了同时支持 NSString* 和 const char*：
```
#define format_to_c_conststring(a) \
(__builtin_choose_expr( \
    __builtin_types_compatible_p(__typeof__(a), NSString*), \
    #a, \
    a \
))

format_to_c_conststring("c")     //展开为 "c"
format_to_c_conststring(@"c")    //展开为 "@/"c/""

//  对于NSString转化的c字符串，读取时需要进行处理
NSString *url =  [NSString stringWithUTF8String:entry.url];
if ([url hasPrefix:@"@\""] && [url hasSuffix:@"\""] && url.length >= 3) {
    url = [url substringWithRange:NSMakeRange(2, url.length-3)];
}
```

```URL_EXPORT``` 最多支持10个参数，宏使用``` __LINE__ ```自动生成唯一函数和变量名，所以在同一源文件中可多次调用 ```URL_EXPORT```。

### 3. 路由加载流程
- 使用```URL_EXPORT```在编译期间将路由注入到 ```__urlhandle```section中
- 在 App 启动时将```AutoRegURLHandler```注册到 ```FBURLRouter```；
- 为了避免影响启动速度，```AutoRegURLHandler```不立即构建路由，延迟至调用 ```+patterns``` 时；
- 构建路由时，使用 dyld 读取 ```__urlhandle``` section中所有的```URL_HANDLE```结构体，构建对应的 ```_InnerURLHandler  ```并加入 ```_RegisterHandlers```，通知添加路由至 ```_RegisterURLs```；
- 我们忽略了系统的动态库，仅处理 .app 下的动态库，同时支持通过修改 ```EXCLUDE_IMAGE_FOR_URL_HANDLE``` 忽略不必要模块（目前默认跳过 SDK 与 dylib）。

## 使用示例
##### 单路由注册
```
URL_EXPORT(@"/setting") {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [navi pushViewController:settingVC animated:YES];
}
```
##### 带参数的路由注册
```
URL_EXPORT("/{courseId}/paramPage") {
    NSString *courseId = parameters[@"courseId"];
    NSString *param1 = parameters[@"param1"];
    NSString *param2 = parameters[@"param2"];
    ParamViewController *vc = [[ParamViewController alloc] initWithCourseId:courseId param1:param1 param2:param2];
    vc.hidesBottomBarWhenPushed = YES;
    [navi pushViewController:vc animated:YES];
}
```
##### 多路由注册
```
#define FuncPageURL_1 @"/func1"
#define FuncPageURL_2 "/func2"
#define FuncPageURL_3 "/func3"

URL_EXPORT(FuncPageURL_1, FuncPageURL_2) {
    if ([url.absoluteString containsString:FuncPageURL_1]) {
        // 转到 func 页面 1
    } else if ([url.absoluteString containsString:FuncPageURL_2]) {
        // 转到 func 页面 2
    }
}
URL_EXPORT(FuncPageURL_3) {
    // 转到 func 页面 3
}
```
## 路由校验机制
```AutoRegURLHandler``` 提供校验方法，用于检查：
- 路由是否注册成功；
- 是否存在重复路由；

##### Debug 环境下使用：
```
#ifdef DEBUG
    NSString *errorString = nil;
    BOOL urlValid = [AutoRegURLHandler checkValid:&errorString];
    NSAssert(urlValid, errorString);
#endif
```

## 📎 项目地址
完整实现与 Demo 示例：
👉 [https://github.com/linjunyi/URLHandlerDemo](https://github.com/linjunyi/URLHandlerDemo)
