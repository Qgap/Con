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
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>

#define SCREEN_WIDTH                        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                       ([UIScreen mainScreen].bounds.size.height)

@interface GQContactViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate,CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate,ABNewPersonViewControllerDelegate,CNContactViewControllerDelegate>

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
        
        [self accessDeniedTip];

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
    
    self.navigationItem.title = NSLocalizedString(@"contacts", @"");
    self.edit = NO;
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelBtn.frame = CGRectMake(20, 10, 17, 23);
    [self.cancelBtn setTitle:NSLocalizedString(@"create", @"") forState:UIControlStateNormal];
//    self.cancelBtn.hidden = YES;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.cancelBtn];
    [self.cancelBtn addTarget:self action:@selector(createContact) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = leftItem;

    self.moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.moreBtn.frame = CGRectMake(20, 10, 17, 23);
    [self.moreBtn setTitle:NSLocalizedString(@"edit", @"") forState:UIControlStateNormal];
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
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];

    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.frame = CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH, 49);
    [self.deleteBtn addTarget:self action:@selector(deleteContacts) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn setBackgroundColor:[UIColor redColor]];
    [self.deleteBtn setTitle:NSLocalizedString(@"delete", @"") forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteBtn.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.deleteBtn];
    
    self.deleteArray = [[NSMutableArray alloc] init];
}

- (void)accessDeniedTip {
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tip", @"") message:NSLocalizedString(@"accessErrorMsg", ) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", ) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self accessDeniedTip];
    }];
    [alertView addAction:action];
    [self presentViewController:alertView animated:YES completion:nil];
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
    return NSLocalizedString(@"delete", @"");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexpath:%@",indexPath);
    
    if (self.isEdit) {
        NSString *key = _keys[indexPath.section];
        GQContactModel *model = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
        [self.deleteArray addObject:model];
        NSLog(@"以选中:%lu",(unsigned long)self.deleteArray.count);
    } else {
//        https://stackoverflow.com/questions/33391950/contact-is-missing-some-of-the-required-key-descriptors-in-ios/34463528
        NSString *key = _keys[indexPath.section];
        GQContactModel *model = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
        if (@available(iOS 9.0, *)) {
            CNContactStore *store = [[CNContactStore alloc]init];
            NSArray *keys = @[CNContactGivenNameKey,
                              CNContactPhoneNumbersKey,
                              CNContactEmailAddressesKey,
                              CNContactIdentifierKey,
                              CNContactViewController.descriptorForRequiredKeys];
            CNMutableContact *mutableContact = [[store unifiedContactWithIdentifier:model.identifier keysToFetch:keys error:nil] mutableCopy];
            CNContactViewController *contactController = [CNContactViewController viewControllerForUnknownContact:mutableContact];
            contactController.hidesBottomBarWhenPushed = YES;
            contactController.delegate = self;
            contactController.allowsActions = YES;
            contactController.allowsEditing = YES;
            [self.navigationController pushViewController:contactController animated:YES];
            
        } else {
            // Fallback on earlier versions
        }
       
        
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tip", @"")
                                                        message:NSLocalizedString(@"deleteContact", )
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"confirm", @""), nil];
        [alert show];
    
    }
    
}

//右侧的索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _keys;
}

#pragma mark - Button Action

- (void)createContact {
    if (self.isEdit) {
        [self editAction];
    } else {
        [self createNewContact];
    }
}

- (void)editAction {
    
    self.edit = !self.isEdit;
    self.deleteBtn.hidden = !self.isEdit;
    [self.tableView setEditing:self.isEdit animated:YES];
    
    if (self.isEdit) {
        [self.cancelBtn setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
        [self.moreBtn setTitle:NSLocalizedString(@"done", @"") forState:UIControlStateNormal];
    } else {
        [self.cancelBtn setTitle:NSLocalizedString(@"create", @"") forState:UIControlStateNormal];
        [self.moreBtn setTitle:NSLocalizedString(@"edit", @"") forState:UIControlStateNormal];
    }
    
}

- (void)createNewContact {
    if (@available(iOS 9.0, *)) {
        CNMutableContact *contact = [[CNMutableContact alloc] init];
       
        CNContactViewController *contactController = [CNContactViewController viewControllerForNewContact:contact];
        contactController.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:contactController];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
        ABRecordRef newPerson = ABPersonCreate();
        picker.displayedPerson = newPerson;
        CFRelease(newPerson);
        picker.newPersonViewDelegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)deleteContacts {
    if (self.deleteArray.count == 0) {
        NSLog(@"您当前没有选择要删除的联系人");
    } else {
        
  
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tip", @"")
                                                        message:NSLocalizedString(@"deleteSelectContacts", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"confirm", @""), nil];
        [alert show];
    }
    
}

#pragma mark - ABNewPersonViewControllerDelegate

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person
{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CNContactViewControllerDelegate

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

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
