//
//  ContactsObjc.m
//

#import "ContactsObjc.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GQContactModel.h"


@interface ContactsObjc () <CNContactPickerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic)UIViewController *controller;
@property (copy, nonatomic)void (^completion)(NSString *name, NSString * phone);
//@property (nonatomic,assign) BOOL granted;
//@property (nonatomic, strong)NSMutableArray *contactsArray;
//@property (nonatomic, strong)NSMutableDictionary *sortDic;
//@property (nonatomic, strong)NSMutableArray *nameKeys;
@end


static ContactsObjc *contacts = nil;

@implementation ContactsObjc

+ (instancetype)shareInstance {
    static ContactsObjc *contactObject;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contactObject = [[ContactsObjc alloc] init];
        
        
    });
    return contactObject;
}

- (id)init {
    self = [super init];
    if (self) {
        [self startUp];
    }
    return self;
}

- (void)startUp {
    self.contactsArray = [[NSMutableArray alloc] init];
    self.nameKeys = [[NSMutableArray alloc] init];
    self.sortDic = [[NSMutableDictionary alloc] init];
    [self allAddressBook];
    [self getOrderAddressBook];
    
}

static dispatch_queue_t get_all_contacts_queue() {
    static dispatch_queue_t get_all_contacts_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        get_all_contacts_queue = dispatch_queue_create("com.gq.get.contact", DISPATCH_QUEUE_SERIAL);
    });
    
    return get_all_contacts_queue;
}

- (BOOL)granted {
    if (@available(iOS 9.0, *)) {
        
        CNContactStore *store = [[CNContactStore alloc] init];
        
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        
        __block BOOL flag = NO;
        if (status == CNAuthorizationStatusNotDetermined) {
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                flag = granted;
            }];
            return flag;
        } else if (status == CNAuthorizationStatusAuthorized) {
            return YES;
        } else {
            return NO;
        }
    } else {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);

        // 1.获取授权状态
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        __block BOOL flag = NO;
        if (status == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                flag = granted;

            });
        } else if (status == kABAuthorizationStatusAuthorized) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}


- (NSArray *)contactsArray {
    if (_contactsArray.count == 0) {
        [self allAddressBook];
    }
    return _contactsArray;
}

- (NSDictionary *)sortDic {
    if (_sortDic.count == 0) {     
        [self getOrderAddressBook];
    }
        return _sortDic;
}


// 获取通讯录信息
- (void)allAddressBook {
    
    if (!self.granted) {return;}
    
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    if (@available(iOS 9.0, *)) {
        
        CNContactStore *store = [[CNContactStore alloc] init];
 
        NSArray *keys = @[CNContactGivenNameKey,
                          CNContactFamilyNameKey,
                          CNContactPhoneNumbersKey,
                          CNContactIdentifierKey
                          ];
        
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        
        
        [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            GQContactModel *model = [[GQContactModel alloc] init];
            
            NSString *name = [NSString stringWithFormat:@"%@%@", contact.familyName ?:@"", contact.givenName ?:@""];
            
            if (name && name.length > 0) {
                model.fullName = name;
            } else {
                model.fullName = @"*无姓名";
            }
            
            //读取电话多值
            for (CNLabeledValue *value in contact.phoneNumbers) {
                
                CNPhoneNumber *phoneNum = value.value;
                NSString *phone = phoneNum.stringValue;
            
                [model.mobileArray addObject:phone];
            }
            
            model.identifier = contact.identifier;
            
            [dataArray addObject:model];

        }];
        
    } else {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBookRef);
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        
        
        for ( int i = 0; i < numberOfPeople; i++){
            GQContactModel *model = [[GQContactModel alloc] init];
            
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            NSString *name = [NSString stringWithFormat:@"%@%@", lastName ?:@"", firstName ?:@""];
            
            if (name && name.length > 0) {
                
                model.fullName = name;
            } else {
                model.fullName = @"*无姓名";
            }
            
            //读取电话多值
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (int k = 0; k<ABMultiValueGetCount(phone); k++) {
                //获取該Label下的电话值
                NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                if (personPhone && personPhone.length > 0) {
                    [model.mobileArray addObject:personPhone];
                }
            }
        
            model.recordID = ABRecordGetRecordID(person);
            [dataArray addObject:model];
            
        }
    }
    self.contactsArray = dataArray;
    
}

//// 获取通讯录信息
//+ (NSArray *)addressBook {
//
//    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//
//    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBookRef);
//    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
//
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//
//
//    for ( int i = 0; i < numberOfPeople; i++){
//        GQContactModel *model = [[GQContactModel alloc] init];
//
//        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
//
//        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
//        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
//        NSString *name = [NSString stringWithFormat:@"%@%@", lastName ?:@"", firstName ?:@""];
//
//        if (name && name.length > 0) {
//
//            model.fullName = name;
//        } else {
//            model.fullName = @"*无姓名";
//        }
//
//        //读取电话多值
//        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
//        for (int k = 0; k<ABMultiValueGetCount(phone); k++) {
//            //获取該Label下的电话值
//            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
//
//            if (personPhone && personPhone.length > 0) {
//
//                [model.mobileArray addObject:personPhone];
//            }
//        }
//
//        NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
//        model.headerImage = [UIImage imageWithData:imageData];
//
//        model.recordID = ABRecordGetRecordID(person);
//
//        [dataArray addObject:model];
//    }
//
//
//    return dataArray;
//}

+ (void)deleteRecord:(GQContactModel *)model {
    
    if (@available(iOS 9.0, *)) {
        CNContactStore *store = [[CNContactStore alloc]init];
        NSArray *keys = @[CNContactGivenNameKey,
                          CNContactPhoneNumbersKey,
                          CNContactEmailAddressesKey,
                          CNContactIdentifierKey];
        CNMutableContact *contact = [[store unifiedContactWithIdentifier:model.identifier keysToFetch:keys error:nil] mutableCopy];
        NSError *error;
        if (contact == nil) {return; }
        
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
        [saveRequest deleteContact:contact];
        [store executeSaveRequest:saveRequest error:&error];
        
    } else {
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        ABRecordID recordID = model.recordID;
        ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
        //删除记录
        ABAddressBookRemoveRecord(addressBook, record, &error);
        
        //保存到数据库
        ABAddressBookSave(addressBook, &error);
        CFRelease(addressBook);

    }
}

- (void)getOrderAddressBook {
        // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("addressBook.infoDict", DISPATCH_QUEUE_SERIAL);
    
     dispatch_async(queue, ^{
         NSMutableDictionary *addressBookDict = [NSMutableDictionary dictionary];
        
         [self.contactsArray enumerateObjectsUsingBlock:^(GQContactModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
             
             NSString *firstLetterString = [self getFirstLetterFromString:model.fullName];
             
             if (addressBookDict[firstLetterString]) {
                 [addressBookDict[firstLetterString] addObject:model];
            
             } else {
                 //创建新发可变数组存储该首字母对应的联系人模型
                 NSMutableArray *arrGroupNames = [NSMutableArray arrayWithCapacity:10];
                 
                 [arrGroupNames addObject:model];
                 //将首字母-姓名数组作为key-value加入到字典中
                 [addressBookDict setObject:arrGroupNames forKey:firstLetterString];
             }
             
         }];
             
             //         // 将addressBookDict字典中的所有Key值进行排序: A~Z
             NSArray *nameKeys = [[addressBookDict allKeys] sortedArrayUsingSelector:@selector(compare:)];

             // 将 "#" 排列在 A~Z 的后面
             if ([nameKeys.firstObject isEqualToString:@"#"]) {
                 NSMutableArray *mutableNamekeys = [NSMutableArray arrayWithArray:nameKeys];
                 [mutableNamekeys insertObject:nameKeys.firstObject atIndex:nameKeys.count];
                 [mutableNamekeys removeObjectAtIndex:0];
            
                 self.sortDic = addressBookDict;
                 self.nameKeys = mutableNamekeys;
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ContantsChange" object:nil];
                 return;
             }
         
             // 将排序好的通讯录数据回调到主线程
             self.sortDic = addressBookDict;
             self.nameKeys = [nameKeys mutableCopy];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"ContantsChange" object:nil];

     });
}

- (NSString *)getFirstLetterFromString:(NSString *)aString {
    NSMutableString *mutableString = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSString *pinyinString = [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    // 将拼音首字母装换成大写
    NSString *strPinYin = [[self polyphoneStringHandle:aString pinyinString:pinyinString] uppercaseString];
    // 截取大写首字母
    NSString *firstString = [strPinYin substringToIndex:1];
    // 判断姓名首位是否为大写字母
    NSString * regexA = @"^[A-Z]$";
    NSPredicate *predA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexA];
    // 获取并返回首字母
    return [predA evaluateWithObject:firstString] ? firstString : @"#";
    
}

/**
 多音字处理
 */
- (NSString *)polyphoneStringHandle:(NSString *)aString pinyinString:(NSString *)pinyinString {
    if ([aString hasPrefix:@"长"]) { return @"chang";}
    if ([aString hasPrefix:@"沈"]) { return @"shen"; }
    if ([aString hasPrefix:@"厦"]) { return @"xia";  }
    if ([aString hasPrefix:@"地"]) { return @"di";   }
    if ([aString hasPrefix:@"重"]) { return @"chong";}
    return pinyinString;
}


@end
