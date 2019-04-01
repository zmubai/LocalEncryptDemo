//
//  LocalEncryptService.m
//  LocalEncryptDemo
//
//  Created by Bennie on 2019/4/1.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "LocalEncryptService.h"
#import "NSData+LE.h"
#import "SAMKeychain.h"

static NSString *LEPriPerfix = @"LEP";
@interface LocalEncryptService ()
@property (nonatomic, strong) NSMutableDictionary *validityPeriods;
@end

@implementation LocalEncryptService
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static LocalEncryptService *service;
    dispatch_once(&onceToken, ^{
        service = LocalEncryptService.new;
        service.validityPeriods = @{}.mutableCopy;
    });
    return service;
}
/*绑定标识和有效期*/
- (void)bindSku:(NSString *)sku validityPeriod:(NSNumber *)seconds
{
    if ([sku isKindOfClass:NSString.class] && [seconds isKindOfClass:NSNumber.class] && seconds.integerValue != 0) {
        [self.validityPeriods setValue:seconds forKey:sku];
    }
}
/*强制清除密码*/
- (void)forceClearPriEncryptKeyWithSkuNum:(NSString *)sku
{
    [SAMKeychain deletePasswordForService:sku account:sku];
}
/*加密并保存*/
- (void)encryptAndSaveInfo:(NSString *)info SkuNum:(NSString *)sku;
{
    NSString *enInfo = [self encodeWithStr:info sku:sku];
    if (enInfo) {
        [[NSUserDefaults standardUserDefaults] setObject:enInfo forKey:[LEPriPerfix stringByAppendingString:sku]];
    }
}
/*解密并获取*/
- (NSString *)decryptAndQueryWithSkuNum:(NSString *)sku error:(NSError **)error;
{
    NSString *enInfo = [[NSUserDefaults standardUserDefaults] objectForKey:[LEPriPerfix stringByAppendingString:sku]];
    if (enInfo) {
        return [self decodeWithStr:enInfo sku:sku error:error];
    }
    return nil;
}

#pragma mark -
- (NSString*)codeKeyWithSuk:(NSString *)sku error:(NSError **)error;
{
    NSString *k = [SAMKeychain passwordForService:sku account:sku];
    NSInteger validityPeriod = [[self.validityPeriods valueForKey:sku] integerValue];
    if (validityPeriod && k.length >= 10) {
        //取以秒位单位时间作比较
        NSString *ktime = [k substringWithRange:NSMakeRange(0, 10)];
        long long last = ktime.longLongValue;
        long long now = (long long)[NSDate date].timeIntervalSince1970;
        ///最近生成的本地秘钥
        if (now - last > validityPeriod || last > now) {
            ///秘钥失效
            k = nil;
            NSLog(@"LocalEncryptService:本地秘钥过期%lld秒",now - last - validityPeriod);
            if (error != NULL) {
                *error = [[NSError alloc]initWithDomain:@"本地秘钥过期" code:-1 userInfo:nil];
            }
        }
        else
        {
            NSLog(@"LocalEncryptService:本地秘钥%lld秒后过期",validityPeriod - (now - last));
        }
    }
    if (!k.length) {
        ///首次随机生成用于信息加密KEY，确保不同手机的加密key是不同的。+可以凭借时间戳设定key的时效性
        NSString *time = [NSString stringWithFormat:@"%lld",(long long)[NSDate date].timeIntervalSince1970*1000];
        k = [time stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)arc4random()]];
        /// add salt
        NSString *salt = nil;
        if ([NSUUID UUID].UUIDString.length >=2) {
            salt = [[NSUUID UUID].UUIDString substringWithRange:NSMakeRange(0, 5)];
        }
        else
        {
            salt = @"xjnkk";
        }
        k = [k stringByAppendingString:salt];
        [SAMKeychain setPassword:k forService:sku account:sku];
        NSLog(@"LocalEncryptService:秘钥重新生成");
    }
    if (k.length >= 16) {
        ///aes128 16字节128位秘钥
        k = [k substringWithRange:NSMakeRange(k.length - 16, 16)];
        NSLog(@"LocalEncryptService:秘钥:%@",k);
    }
    return k;
}
///aes128 + base64
- (NSString*)encodeWithStr:(NSString *)str sku:(NSString *)sku
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = [self codeKeyWithSuk:sku error:nil];
    NSData *aaa = [data AES128EncryptWithKey:key]; // aes加密
    NSLog(@"LocalEncryptService:aes128加密后：%@",aaa);
    NSString *bbb = [NSData encodeBase64Data:aaa];//base64加密
    NSLog(@"LocalEncryptService:base64编码后：%@",bbb);
    return bbb;
}

- (NSString*)decodeWithStr:(NSString *)str sku:(NSString *)sku error:(NSError **)error;
{
    NSData *aaa = [NSData decodeBase64String:str];
    NSLog(@"LocalEncryptService:base64解密后：%@",aaa);
    NSError *kError;
    NSString *key = [self codeKeyWithSuk:sku error:&kError];
    if(kError)
    {
        if (error != NULL) {
            *error = [[NSError alloc]initWithDomain:kError.domain code:kError.code userInfo:kError.userInfo];
        }
        return nil;
    }
    NSData *bbb = [aaa AES128DecryptWithKey:key];
    NSString *ccc = [[NSString alloc]initWithData:bbb encoding:NSUTF8StringEncoding];
    NSLog(@"LocalEncryptService:aes128解密后的：%@",ccc);
    return ccc;
}

@end
