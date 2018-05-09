//
//  ContactTableViewCell.m
//  Contact
//
//  Created by gap on 2018/5/9.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "ContactTableViewCell.h"

@interface ContactTableViewCell ()

@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *phoneLabel;
@property (nonatomic, strong)UIButton *selectBtn;

@end

@implementation ContactTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
