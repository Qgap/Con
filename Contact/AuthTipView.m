//
//  TipView.m
//  Contact
//
//  Created by gap on 2018/5/9.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "AuthTipView.h"

@implementation AuthTipView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 200, 300, 60)];
        tipLabel.text = @"请在iPhone的“设置-隐私-通讯录”选项中，允许应用访问您的通讯录";
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.numberOfLines = 0;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tipLabel];
        
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingBtn setTitle:@"去设置" forState:UIControlStateNormal];
        [settingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [settingBtn addTarget:self action:@selector(authContact) forControlEvents:UIControlEventTouchUpInside];
        settingBtn.layer.borderWidth = 1;
        settingBtn.frame = CGRectMake(100, 100, 100, 30);
        [self addSubview:settingBtn];
        
    }
    return self;
}

- (void)authContact {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Privacy&path=Contacts"]];

}

@end
