//
//  ContactsObjc.h
//

#import <UIKit/UIKit.h>

@class GQContactModel;

typedef void(^AddressBookDictBlock)(NSDictionary<NSString *,NSArray *> *addressBookDict,NSArray *nameKeys);

typedef void(^AuthorizationFailure)(void);

typedef void(^ContactsArray) (NSArray *contacts);

typedef enum : NSUInteger {
    StatusNotDetermined,
    StatusAuthorized,
    StatusDetermined
} AuthorizationStatus;

@interface ContactsObjc : NSObject

@property (nonatomic,assign) AuthorizationStatus authStatus;
@property (nonatomic, strong)NSMutableArray *contactsArray;
@property (nonatomic, strong)NSDictionary *sortDic;
@property (nonatomic, strong)NSArray *nameKeys;
@property (nonatomic,assign) BOOL empt;

+ (instancetype)shareInstance;

- (void)startUp;

+ (void)deleteRecord:(GQContactModel *)model;

- (void)getOrderAddressBook;

@end
