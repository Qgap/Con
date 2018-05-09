//
//  GQSortViewController.m
//  Contact
//
//  Created by gap on 2018/5/9.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "GQSortViewController.h"
#import "GQContactModel.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import "ContactsObjc.h"

#define SCREEN_WIDTH                        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                       ([UIScreen mainScreen].bounds.size.height)



@interface GQSortViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSMutableArray *sameNameArray;
@property (nonatomic, strong)NSArray *samePhoneArray;
@property (nonatomic, strong)NSArray *noNameArray;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)UIView *footerView;
@property (nonatomic, assign)MergeType type;


@end

@implementation GQSortViewController

- (id)initWithType:(MergeType)type data:(NSArray *)array {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        switch (type) {
            case SameNameType:
                self.sameNameArray = [array mutableCopy];
                break;
            case SamePhoneType:
                self.samePhoneArray = array;
            case NoNameType:
                self.noNameArray = array;
        }
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView reloadData];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49) style:UITableViewStyleGrouped];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.sectionIndexColor = [UIColor grayColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mergeAction:)];
        _footerView.userInteractionEnabled = YES;
        [_footerView addGestureRecognizer:tapGesture];
        _footerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:_footerView.frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.text = @"合并";
        [_footerView addSubview:label];
        
    }
    return _footerView;
}

- (void)mergeAction:(UITapGestureRecognizer *)sender {
    NSLog(@" sender tag :%d",sender.view.tag);
    
    NSInteger index = sender.view.tag;
    switch (self.type) {
        case SameNameType:{
            if (@available(iOS 9.0, *)) {
                NSArray *modelArray = self.sameNameArray[index][@"data"];
                GQContactModel *model = modelArray.firstObject;
                
                CNContactStore *store = [[CNContactStore alloc]init];
                NSArray *keys = @[CNContactGivenNameKey,
                                  CNContactPhoneNumbersKey,
                                  CNContactEmailAddressesKey,
                                  CNContactIdentifierKey];
                CNMutableContact *mutableContact = [[store unifiedContactWithIdentifier:model.identifier keysToFetch:keys error:nil] mutableCopy];

                __block NSMutableArray *phoneNumbers = [mutableContact.phoneNumbers mutableCopy];
                
                NSLog(@"phoneNumbers :%@",phoneNumbers);
                
                [modelArray enumerateObjectsUsingBlock:^(GQContactModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx != 0) {
                        
                        for (NSString *phone in model.mobileArray) {
                            CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile
                                                                          value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
                            
                            NSLog(@"phone :%@",phone);
                            [phoneNumbers addObject:phoneNumber];
                        }
                        [ContactsObjc deleteRecord:model];
                    }
                    

                }];

                mutableContact.phoneNumbers = phoneNumbers;
                
                NSLog(@"mutableContact.phoneNumbers :%@",phoneNumbers);
                CNSaveRequest * saveRequest = [[CNSaveRequest alloc] init];
//                [saveRequest addContact:mutableContact toContainerWithIdentifier:model.identifier];
                [saveRequest updateContact:mutableContact];
                BOOL result = [store executeSaveRequest:saveRequest error:nil];
                if (result) {
                    [self.sameNameArray removeObjectAtIndex:index];
                    [self.tableView reloadData];
                }
                
                
                
            } else {
                NSLog(@"暂不支持iOS 8 ～");
            }
            
            
        }
            
            break;
        case SamePhoneType:
            break;
            
        case NoNameType:
            
            break;
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    NSArray *array = self.sameNameArray[indexPath.section][@"data"];
    GQContactModel *model = array[indexPath.row];
    
    cell.textLabel.text = model.mobileArray.firstObject;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.sameNameArray[section][@"data"];
    return array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sameNameArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sameNameArray[section][@"key"];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    self.footerView.tag = section;
    return self.footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
