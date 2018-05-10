//
//  GQContactHeader.h
//  Contact
//
//  Created by gap on 2018/5/10.
//  Copyright © 2018年 gq. All rights reserved.
//

#ifndef GQContactHeader_h
#define GQContactHeader_h

#define SCREEN_WIDTH                        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                       ([UIScreen mainScreen].bounds.size.height)
#define kBottom_HEIGHT                      (SCREEN_HEIGHT == 812 ? 34 : 0)

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#endif /* GQContactHeader_h */
