//
//  ContactViewController.m
//  Contact
//
//  Created by gap on 2018/5/8.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "GQContactViewController.h"
#import "ContactsObjc.h"
#import "GQContactModel.h"
#import "AuthTipView.h"

#define SCREEN_WIDTH                        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                       ([UIScreen mainScreen].bounds.size.height)

@interface GQContactViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong)UIButton *cancelBtn;

@property (nonatomic, strong)UIButton *moreBtn;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, copy)NSMutableArray *dataArray;

@property (nonatomic, copy) NSDictionary *contactPeopleDict;
@property (nonatomic, copy) NSArray *keys;
@property (nonatomic, strong)NSIndexPath *indexPath;

@property (nonatomic, getter=isEdit)BOOL edit;

@property (nonatomic, strong)UIButton *deleteBtn;

@property (nonatomic, strong)NSMutableArray *deleteArray;

@property (nonatomic, strong)AuthTipView *authTipView;

@end

@implementation GQContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadData];
}

- (void)loadData {
    
    [self.deleteArray removeAllObjects];
    
    [ContactsObjc getOrderAddressBook:^(NSDictionary<NSString *,NSArray *> *addressBookDict, NSArray *nameKeys) {
        self.contactPeopleDict = addressBookDict;
        self.keys = nameKeys;
        [self.tableView reloadData];
    } authorizationFailure:^{
        
        self.authTipView.hidden = NO;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"请在iPhone的“设置-隐私-通讯录”选项中，允许应用访问您的通讯录"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"知道了"
//                                              otherButtonTitles:nil];
//        [alert show];
    }];
}

- (AuthTipView *)authTipView {
    if (!_authTipView) {
        _authTipView = [[AuthTipView alloc] initWithFrame:self.view.frame];
        _authTipView.hidden = YES;
        [self.view addSubview:_authTipView];
    }
    
    return _authTipView;
}

- (void)setUpUI {
    
    self.navigationItem.title = @"通讯录";
    self.edit = NO;
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelBtn.frame = CGRectMake(20, 10, 17, 23);
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.hidden = YES;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.cancelBtn];
    [self.cancelBtn addTarget:self action:@selector(createContact) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = leftItem;

    self.moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.moreBtn.frame = CGRectMake(20, 10, 17, 23);
    [self.moreBtn setTitle:@"编辑" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreBtn];
    [self.moreBtn addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49) style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.sectionIndexColor = [UIColor grayColor];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];

    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.frame = CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH, 49);
    [self.deleteBtn addTarget:self action:@selector(deleteContacts) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn setBackgroundColor:[UIColor redColor]];
    [self.deleteBtn setTitle:@"DELETE" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteBtn.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.deleteBtn];
    
    self.deleteArray = [[NSMutableArray alloc] init];
}

- (void)deleteContacts {
    if (self.deleteArray.count == 0) {
        NSLog(@"您当前没有选择要删除的联系人");
    } else {
        
        NSString *msg = [NSString stringWithFormat:@"确认删除选中的:%lu个联系人",(unsigned long)self.deleteArray.count];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认", nil];
        [alert show];
    }
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellId"];
    }
    
    NSString *key = _keys[indexPath.section];
    GQContactModel *model = [_contactPeopleDict[key] objectAtIndex:indexPath.row];

    cell.textLabel.text = model.fullName;
    if (model.mobileArray.count > 1) {

        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@,等%ld个号码",model.mobileArray.firstObject,model.mobileArray.count];
    } else {
        cell.detailTextLabel.text = model.mobileArray.firstObject;
    }

    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = _keys[section];
    return [_contactPeopleDict[key] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keys.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _keys[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section  {
    return 0.01;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexpath:%@",indexPath);
    
    if (self.isEdit) {
        NSString *key = _keys[indexPath.section];
        GQContactModel *model = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
        [self.deleteArray addObject:model];
        NSLog(@"以选中:%lu",(unsigned long)self.deleteArray.count);
    } else {
        
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEdit) {
        NSString *key = _keys[indexPath.section];
        GQContactModel *model = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
        if ([self.deleteArray containsObject:model]) {
            [self.deleteArray removeObject:model];
        }

    } else {
        
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *key = _keys[indexPath.section];
        
        GQContactModel *model = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
        [self.deleteArray addObject: model];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"确认删除当前联系人吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认", nil];
        [alert show];
    
    }
    
}

//右侧的索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _keys;
}

- (void)createContact {
    if (self.isEdit) {
        [self editAction];
    }
}

- (void)editAction {
    
    self.edit = !self.isEdit;
    self.deleteBtn.hidden = !self.isEdit;
    [self.tableView setEditing:self.isEdit animated:YES];
    
    if (self.isEdit) {
        self.cancelBtn.hidden = NO;
    } else {
        self.cancelBtn.hidden = YES;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {

        for (GQContactModel *model in self.deleteArray) {
            NSLog(@"model id :%@ , name:%@",model.identifier, model.fullName);
            [ContactsObjc deleteRecord:model];
        }
        
        [self loadData];

    } else {
        if (!self.isEdit) {
            [self.deleteArray removeAllObjects];
        }
    }
}


@end
