//
//  MergeSamePhoneViewController.m
//  Contact
//
//  Created by gap on 2018/5/10.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "MergeSamePhoneViewController.h"
#import "ContactsObjc.h"
#import "GQContactModel.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>

@interface MergeSamePhoneViewController ()
@property (nonatomic, strong)NSDictionary *dataDic;
@property (nonatomic, strong)NSMutableArray *nameArray;
@property (nonatomic, strong)NSMutableArray *phoneArray;
@property (nonatomic, strong)NSString *selectName;
@property (nonatomic, strong)NSMutableArray *selectPhoneArray;

@end

@implementation MergeSamePhoneViewController

- (id)initWithData:(NSDictionary *)data {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.dataDic = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView registerClass:[UITableViewCell class ] forCellReuseIdentifier:@"CELLID"];
    
    self.nameArray = [[NSMutableArray alloc] init];
    self.phoneArray = [[NSMutableArray alloc] init];
    
    
    self.selectPhoneArray = [[NSMutableArray alloc] init];
    
    
    NSArray *contactArray = self.dataDic[@"data"];
    [contactArray enumerateObjectsUsingBlock:^(GQContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0) {
            self.selectName = obj.fullName;
        }
        if (![self.nameArray containsObject:obj.fullName]) {
            [self.nameArray addObject:obj.fullName];
        }
        
        [obj.mobileArray enumerateObjectsUsingBlock:^(NSString *phone, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.phoneArray addObject:phone];
            [self.selectPhoneArray addObject:phone];
        
        }];
    }];
    
    [self.tableView reloadData];
    
    UIButton *mergeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    mergeBtn.frame = CGRectMake(20, 10, 17, 23);
    [mergeBtn setTitle:NSLocalizedString(@"merge", nil) forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:mergeBtn];
    [mergeBtn addTarget:self action:@selector(mergeContact) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = rightItem;
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView setEditing:YES animated:YES];
    
}

- (void)mergeContact {

    if (self.selectPhoneArray.count == 0) {
        return;
    }
    
    if (@available(iOS 9.0, *)) {
        CNMutableContact *mutableContact = [[CNMutableContact alloc] init];
        mutableContact.givenName = self.selectName;
        
        NSMutableArray *phoneNumbers = [NSMutableArray arrayWithCapacity:3];
        
        for (NSString *phone in self.selectPhoneArray) {
            CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
            
            [phoneNumbers addObject:phoneNumber];
        }
        
        mutableContact.phoneNumbers = phoneNumbers;
        
        // 创建联系人请求
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
        [saveRequest addContact:mutableContact toContainerWithIdentifier:nil];
        
        CNContactStore *store = [[CNContactStore alloc] init];
        BOOL result = [store executeSaveRequest:saveRequest error:nil];
        
        if (result) {
            for (GQContactModel *model in self.dataDic[@"data"]) {
                [ContactsObjc deleteRecord:model];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    } else {

        ABRecordRef people = ABPersonCreate();
    
        ABRecordSetValue(people, kABPersonFirstNameProperty, (__bridge CFTypeRef)(self.selectName), NULL);
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        
        for (NSString *phone in self.phoneArray) {
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(phone), kABPersonPhoneMainLabel, NULL);
        }
        
        // 3. 拿到通讯录
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        
        // 4. 将联系人添加到通讯录中
        ABAddressBookAddRecord(book, people, NULL);
        
        // 5. 保存通讯录
        ABAddressBookSave(book, NULL);
    }
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == 0)) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.nameArray.count;
    } else {
        return self.phoneArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELLID" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.nameArray[indexPath.row];
    } else {
        cell.textLabel.text = self.phoneArray[indexPath.row];
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSArray *array = @[@"姓名（单选）", @"电话号码（多选）"];
    NSArray *array = @[NSLocalizedString(@"mergeName", nil),NSLocalizedString(@"mergePhone", nil)];
    return array[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.selectName = self.nameArray[indexPath.row];
        
        if (self.nameArray.count > 1) {

            for (int i = 0; i < [tableView numberOfRowsInSection:0]; i++) {
                if (i != indexPath.row) {
                    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
                }
            }
        }

    } else {
        [self.selectPhoneArray addObject:self.phoneArray[indexPath.row]];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (self.nameArray.count == 1) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            return;
        }
    } else {
        NSString *phone = self.phoneArray[indexPath.row];

        if ([self.selectPhoneArray containsObject:phone]) {
            [self.selectPhoneArray removeObjectAtIndex:[self.selectPhoneArray indexOfObject:phone]];
        }
    }
    
}


@end
