//
//  ContactsObjc.h
//

#import <UIKit/UIKit.h>

@class GQContactModel;

typedef void(^AddressBookDictBlock)(NSDictionary<NSString *,NSArray *> *addressBookDict,NSArray *nameKeys);

typedef void(^AuthorizationFailure)(void);

typedef void(^ContactsArray) (NSArray *contacts);

@interface ContactsObjc : NSObject

+ (void)getContact:(UIViewController *)controller completion:(void (^)(NSString *name, NSString * phone)) completion;

+ (NSArray *)addressBook;

//+ (NSArray *)allAddressBook;
+ (void)allAddressBook:(ContactsArray)contacts authorizationFailure:(AuthorizationFailure)failure;

+ (void)getOrderAddressBook:(AddressBookDictBlock)addressBookInfo authorizationFailure:(AuthorizationFailure)failure;

+ (void)deleteRecord:(GQContactModel *)model;

@end
