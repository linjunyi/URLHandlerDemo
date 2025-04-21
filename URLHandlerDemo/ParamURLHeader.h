//
//  ParamURLHeader.h
//  URLHandlerDemo
//
//  Created by 林君毅 on 2025/4/21.
//

#ifndef ParamURLHeader_h
#define ParamURLHeader_h

#define ParamPageURL "/{courseId}/paramPage"
#define MakeParamPageURL(_courseId, _param1, _param2) \
    URL_CREATE(@ParamPageURL, (@{ \
        @"courseId" : _courseId ?: @"", \
        @"param1" : _param1 ?: @"", \
        @"param2" : _param2 ?: @"", \
    }))

#endif /* ParamURLHeader_h */
