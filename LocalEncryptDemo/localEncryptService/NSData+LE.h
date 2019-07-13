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
+ (NSString*)le_encodeBase64Data:(NSData *)data;
//解密
+ (NSData*)le_decodeBase64String:(NSString * )input;
//加密
- (NSData *)le_AES128EncryptWithKey:(NSString *)key;
//解密
- (NSData *)le_AES128DecryptWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
