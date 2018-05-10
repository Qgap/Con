//
//  ContactsObjc.h
//

#import <UIKit/UIKit.h>

@class GQContactModel;

typedef void(^AddressBookDictBlock)(NSDictionary<NSString *,NSArray *> *addressBookDict,NSArray *nameKeys);

typedef void(^AuthorizationFailure)(void);

typedef void(^ContactsArray) (NSArray *contacts);

@interface ContactsObjc : NSObject

@property (nonatomic,assign) BOOL granted;
@property (nonatomic, strong)NSMutableArray *contactsArray;
@property (nonatomic, strong)NSDictionary *sortDic;
@property (nonatomic, strong)NSArray *nameKeys;

+ (instancetype)shareInstance;

- (void)startUp;

+ (void)deleteRecord:(GQContactModel *)model;

- (void)getOrderAddressBook;

@end
