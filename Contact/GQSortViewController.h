//
//  GQSortViewController.h
//  Contact
//
//  Created by gap on 2018/5/9.
//  Copyright © 2018年 gq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SameNameType,
    SamePhoneType,
    NoNameType
} MergeType;

@interface GQSortViewController : UIViewController

- (id)initWithType:(MergeType)type data:(NSArray *)array;

@end
