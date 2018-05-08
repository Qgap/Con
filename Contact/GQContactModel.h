//
//  GQContactModel.h
//  Contact
//
//  Created by gap on 2018/5/8.
//  Copyright © 2018年 gq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GQContactModel : NSObject

@property (nonatomic, copy)NSString *fullName;

@property (nonatomic, strong)NSMutableArray *mobileArray;

@property (nonatomic, copy)UIImage *headerImage;

@property NSInteger recordID;

@property (nonatomic, copy)NSString *identifier;

@end
