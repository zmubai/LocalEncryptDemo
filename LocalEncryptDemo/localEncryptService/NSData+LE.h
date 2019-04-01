//
//  NSData+LE.h
//  lipstickMachine
//
//  Created by Bennie on 2019/3/28.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (LM)
//加密
+ (NSString*)encodeBase64Data:(NSData *)data;
//解密
+ (NSData*)decodeBase64String:(NSString * )input;
//加密
- (NSData *)AES128EncryptWithKey:(NSString *)key;
//解密
- (NSData *)AES128DecryptWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
