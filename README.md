### 使用说明
1.相关方法
```
/*绑定标识和有效期*/
- (void)bindSku:(NSString *)sku validityPeriod:(NSNumber *)seconds;
/*强制清除加密秘钥*/
- (void)forceClearPriEncryptKeyWithSkuNum:(NSString *)sku;
/*加密并保存*/
- (void)encryptAndSaveInfo:(NSString *)info SkuNum:(NSString *)sku;
/*解密并获取*/
- (NSString *)decryptAndQueryWithSkuNum:(NSString *)sku error:(NSError **)error;
```
2.关于强制清除加密秘钥

forceClearPriEncryptKeyWithSkuNum这个方法，提供跳过有效期强制刷新加密秘钥的功能。例如重新登录，那么不需要等秘钥过期就可以强制生成新秘钥。
