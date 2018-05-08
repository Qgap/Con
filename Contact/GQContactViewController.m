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

#define SCREEN_WIDTH                        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                       ([UIScreen mainScreen].bounds.size.height)

@interface GQContactViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong)UIButton *createBtn;

@property (nonatomic, strong)UIButton *moreBtn;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, copy)NSMutableArray *dataArray;

@property (nonatomic, copy) NSDictionary *contactPeopleDict;
@property (nonatomic, copy) NSArray *keys;
@property (nonatomic, strong)NSIndexPath *indexPath;


@end

@implementation GQContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [ContactsObjc getOrderAddressBook:^(NSDictionary<NSString *,NSArray *> *addressBookDict, NSArray *nameKeys) {
        self.contactPeopleDict = addressBookDict;
        self.keys = nameKeys;
        [self.tableView reloadData];
    } authorizationFailure:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在iPhone的“设置-隐私-通讯录”选项中，允许应用访问您的通讯录"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)setUpUI {
    
    self.navigationItem.title = @"通讯录";
    
    self.createBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.createBtn.frame = CGRectMake(20, 10, 17, 23);

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.createBtn];
    [self.createBtn addTarget:self action:@selector(createContact) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.moreBtn.frame = CGRectMake(20, 10, 17, 23);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreBtn];
    [self.createBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.sectionIndexColor = [UIColor grayColor];
    [self.view addSubview:self.tableView];

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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.indexPath = indexPath;
        
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
    NSLog(@"create");
}

- (void)moreAction {
    NSLog(@"more");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        NSString *key = _keys[self.indexPath.section];
        
        
        GQContactModel *model = [_contactPeopleDict[key] objectAtIndex:self.indexPath.row];
        [ContactsObjc deleteRecord:model.recordID];

//        [self.tableView deleteRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        
//        [_contactPeopleDict[key] removeObjectAtIndex:self.indexPath.row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}




@end
