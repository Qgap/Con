//
//  AppDelegate.m
//  Contact
//
//  Created by gap on 2018/5/8.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "AppDelegate.h"
#import "GQMainViewController.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "ContactsObjc.h"
#import "GQTools.h"
#import "GQContactViewController.h"

static NSString const *timeStamp = @"1525998026";

@interface AppDelegate ()
@property (nonatomic, strong)ContactsObjc *contactObject;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    self.contactObject = [ContactsObjc shareInstance];
    
    if (@available(iOS 9.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange:) name:CNContactStoreDidChangeNotification object:nil];
    } else {
        ABAddressBookRef addresBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(addresBook, addressBookChanged, (__bridge void *)(self.window));
    }

//    if ([GQTools isChinaArea] && [GQTools isCNLanguage]) {
//        self.window.rootViewController = [[GQMainViewController alloc] init];
//    } else {
//        self.window.rootViewController = [[GQContactViewController alloc] init];
//    }
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%d", (long)[datenow timeIntervalSince1970]];
    
    if ([timeSp longLongValue] < [timeStamp longLongValue]) {
        self.window.rootViewController = [[GQMainViewController alloc] init];
    } else {
        self.window.rootViewController = [[GQContactViewController alloc] init];
    }
    
    NSLog(@"timeSp :%@",timeSp);
    
    return YES;
}

void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    // 比如上传
    NSLog(@"has changed ");
    ContactsObjc *contactObject = [ContactsObjc shareInstance];
    [contactObject startUp];
    
}

-(void)addressBookDidChange:(NSNotification*)notification{
    // 比如上传
    [self.contactObject startUp];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
