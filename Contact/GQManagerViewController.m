//
//  SettingViewController.m
//  Contact
//
//  Created by gap on 2018/5/8.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "GQManagerViewController.h"
#import "ContactsObjc.h"
#import "GQContactModel.h"
#import "AuthTipView.h"
#import "GQSortViewController.h"
#import "NoPhoneViewController.h"

#define SCREEN_WIDTH                        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                       ([UIScreen mainScreen].bounds.size.height)


@interface GQManagerViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSMutableArray *sameNameArray;
@property (nonatomic, strong)NSMutableArray *samePhoneArray;
//@property (nonatomic, strong)NSMutableArray *noNameArray;
@property (nonatomic, strong)NSMutableArray *noPhoneArray;
@property (nonatomic, strong)AuthTipView *authTipView;
@property (nonatomic, strong)NSArray *totalArray;
@end

@implementation GQManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"clean", nil);
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __block NSMutableArray *allAddress = [NSMutableArray arrayWithCapacity:0];
    [ContactsObjc allAddressBook:^(NSArray *contacts) {
        allAddress = [[NSMutableArray alloc] initWithArray:contacts];
    } authorizationFailure:^{
        self.authTipView.hidden = NO;
        return ;
    }];
    
    NSArray *addressArray = [NSArray arrayWithArray:allAddress];
    self.sameNameArray = [[[NSMutableArray alloc] init] mutableCopy];
    self.samePhoneArray = [[[NSMutableArray alloc] init] mutableCopy];
//    self.noNameArray = [[[NSMutableArray alloc] init] mutableCopy];
    self.noPhoneArray = [[NSMutableArray alloc] init];
    [allAddress enumerateObjectsUsingBlock:^(GQContactModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        if ([model.fullName isEqualToString:@"*无姓名"]) {
//            [self.noNameArray addObject:model];
//        }
        
        if (model.mobileArray.count == 0) {
            [self.noPhoneArray addObject:model];
        }
        
        __block NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        __block NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        __block BOOL isDup = NO;
        
        __block NSMutableDictionary *phoneDic = [[NSMutableDictionary alloc] init];
        __block NSMutableArray *phoneArray = [[NSMutableArray alloc] init];
        
        [addressArray enumerateObjectsUsingBlock:^(GQContactModel *obj, NSUInteger index, BOOL * _Nonnull stop) {
            
            if (index == idx) {
                *stop = YES;
                return ;
            }
            
            for (NSString *phone in model.mobileArray) {
                if ([obj.mobileArray containsObject:phone]) {
                    [phoneArray addObject:obj];
                    [phoneArray addObject:model];
                    [phoneDic setObject:phoneArray forKey:@"data"];
                    [phoneDic setObject:phone forKey:@"key"];
                    [self.samePhoneArray addObject:phoneDic];
                }
            }
            
            if ([model.fullName isEqualToString:obj.fullName] && idx != index && idx > index && ![obj.fullName isEqualToString:@"*无姓名 "]) {
                [tmpArray addObject:obj];
                isDup = YES;
            }
            
        }];
        
        if (isDup) {
            [tmpArray addObject:model];
//            [dic setObject:tmpArray forKey:model.fullName];
            [dic setObject:model.fullName forKey:@"key"];
            [dic setObject:tmpArray forKey:@"data"];
            [self.sameNameArray addObject:dic];
        }
        
        NSLog(@"same name = %@,same phone :%@, no name %@",self.sameNameArray,self.samePhoneArray,self.noPhoneArray);
    }];
    self.totalArray = @[self.sameNameArray,self.samePhoneArray,self.noPhoneArray];
    
    [self.tableView reloadData];
    
}

- (AuthTipView *)authTipView {
    if (!_authTipView) {
        _authTipView = [[AuthTipView alloc] initWithFrame:self.view.frame];
        _authTipView.hidden = YES;
        [self.view addSubview:_authTipView];
    }
    
    return _authTipView;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.sectionIndexColor = [UIColor grayColor];
//        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = NSLocalizedString(@"duplicateName", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",self.sameNameArray.count];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"duplicatePhone", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",self.samePhoneArray.count];
        
    } else {
        
        cell.textLabel.text = NSLocalizedString(@"noPhoneNumber", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",self.noPhoneArray.count];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array = self.totalArray[indexPath.row];
    if (array.count == 0) {
        NSLog(@"恭喜，没有需要清理的联系人");
        
    } else {
        
        if (indexPath.row == 2) {
            NoPhoneViewController *vc = [[NoPhoneViewController alloc] initWithData:self.noPhoneArray];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSArray *typeArray = @[@"0",@"1",@"2"];
            GQSortViewController *viewController = [[GQSortViewController alloc] initWithType:[typeArray[indexPath.row] integerValue] data:self.totalArray[indexPath.row]];
            viewController.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
        
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
