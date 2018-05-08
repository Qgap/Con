//
//  GQContactModel.m
//  Contact
//
//  Created by gap on 2018/5/8.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "GQContactModel.h"

@implementation GQContactModel

- (NSMutableArray *)mobileArray {
    if(!_mobileArray) {
        _mobileArray = [NSMutableArray array];
    }
    return _mobileArray;
}

@end
