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
#import "MergeSamePhoneViewController.h"

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
                break;
            case NoNameType:
                self.noNameArray = array;
                break;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        label.text = NSLocalizedString(@"merge", nil);
        [_footerView addSubview:label];
        
    }
    return _footerView;
}

- (void)mergeAction:(UITapGestureRecognizer *)sender {
    
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
                
                [modelArray enumerateObjectsUsingBlock:^(GQContactModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx != 0) {
                        
                        for (NSString *phone in model.mobileArray) {
                            CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile
                                                                          value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
                            
            
                            [phoneNumbers addObject:phoneNumber];
                        }
                        [ContactsObjc deleteRecord:model];
                    }
                    

                }];

                mutableContact.phoneNumbers = phoneNumbers;
                
                CNSaveRequest * saveRequest = [[CNSaveRequest alloc] init];
                [saveRequest updateContact:mutableContact];
                BOOL result = [store executeSaveRequest:saveRequest error:nil];
                if (result) {
                    [self.sameNameArray removeObjectAtIndex:index];
                    [self.tableView reloadData];
                } else {
                    NSLog(@"合并失败");
                }
            } else {
                NSLog(@"暂不支持iOS 8 ～");
            }
            
            
        }
            
            break;
        case SamePhoneType: {
            MergeSamePhoneViewController *vc = [[MergeSamePhoneViewController alloc] initWithData:self.samePhoneArray[index]];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            
            break;
            
        case NoNameType:
            
            break;
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.type == SameNameType) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
        NSArray *array = self.sameNameArray[indexPath.section][@"data"];
        GQContactModel *model = array[indexPath.row];
        
        cell.textLabel.text = model.mobileArray.firstObject;
        return cell;
        
    } else if (self.type == SamePhoneType){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellId"];
        }
        
        NSArray *array = self.samePhoneArray[indexPath.section][@"data"];
        GQContactModel *model = array[indexPath.row];
        cell.textLabel.text = model.fullName;
        if (model.mobileArray.count > 1) {
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@,等%ld个号码",model.mobileArray.firstObject,model.mobileArray.count];
        } else {
            cell.detailTextLabel.text = model.mobileArray.firstObject;
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
        return cell;
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.type) {
        case SameNameType: {
            NSArray *array = self.sameNameArray[section][@"data"];
            return array.count;
        }
            break;
        case SamePhoneType: {
            NSArray *array = self.samePhoneArray[section][@"data"];
            return array.count;
        }
            break;
        case NoNameType: {
            NSArray *array = self.noNameArray[section][@"data"];
            return array.count;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.type) {
        case SameNameType:
            return self.sameNameArray.count;
            break;
        case SamePhoneType:
            return self.samePhoneArray.count;
            break;
        case NoNameType:
            return self.noNameArray.count;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (self.type) {
        case SameNameType:
            return self.sameNameArray[section][@"key"];
            break;
        case SamePhoneType:
            return self.samePhoneArray[section][@"key"];
            break;
        case NoNameType:
            return self.noNameArray[section];
            break;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [self createFooterView];
    view.tag = section;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)createFooterView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mergeAction:)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tapGesture];
    view.backgroundColor = [UIColor whiteColor];

    UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.text = NSLocalizedString(@"merge", nil);
    [view addSubview:label];
    return view;
    
}



@end
