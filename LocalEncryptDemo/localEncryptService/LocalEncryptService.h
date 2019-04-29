//
//  LocalEncryptService.h
//  LocalEncryptDemo
//
//  Created by Bennie on 2019/4/1.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalEncryptService : NSObject
+ (instancetype)shareInstance;
/*绑定标识和有效期*/
- (void)bindSku:(NSString *)sku validityPeriod:(NSNumber *)seconds;
/*强制清除加密秘钥*/
- (void)forceClearPriEncryptKeyWithSkuNum:(NSString *)sku;
/*加密并保存*/
- (NSString *)encryptAndSaveInfo:(NSString *)info SkuNum:(NSString *)sku;
/*解密并获取*/
- (NSString *)decryptAndQueryWithSkuNum:(NSString *)sku error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
