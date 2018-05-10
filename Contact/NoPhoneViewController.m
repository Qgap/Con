//
//  NoPhoneViewController.m
//  Contact
//
//  Created by gap on 2018/5/10.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "NoPhoneViewController.h"
#import "GQContactModel.h"
#import "ContactsObjc.h"

@interface NoPhoneViewController ()
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSMutableArray *selectArray;
@end

@implementation NoPhoneViewController

- (id)initWithData:(NSArray *)data {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.dataArray = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectArray = [[NSMutableArray alloc] init];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELLID"];
    
    UIButton *mergeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    mergeBtn.frame = CGRectMake(20, 10, 17, 23);
    [mergeBtn setTitle:NSLocalizedString(@"delete", @"") forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:mergeBtn];
    [mergeBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = rightItem;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView setEditing:YES animated:YES];
}

- (void)deleteAction {
    if (self.selectArray.count == 0) {
        NSLog(@"请选择需要删除的");
    } else {
        for (GQContactModel *model in self.selectArray) {
            [ContactsObjc deleteRecord:model];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELLID" forIndexPath:indexPath];
    
    GQContactModel *model = self.dataArray[indexPath.row];
    
    cell.textLabel.text = model.fullName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.selectArray addObject:self.dataArray[indexPath.row]];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    GQContactModel *model = self.dataArray[indexPath.row];
    if ([self.selectArray containsObject:model]) {
        [self.selectArray removeObject:model];
    }
}
@end
