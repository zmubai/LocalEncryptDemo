//
//  ViewController.m
//  LocalEncryptDemo
//
//  Created by Bennie on 2019/4/1.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "ViewController.h"
#import "LocalEncryptService.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *skuLabel;
@property (weak, nonatomic) IBOutlet UITextField *validitySecondsLabel;
@property (weak, nonatomic) IBOutlet UITextView *oriTextView;
@property (weak, nonatomic) IBOutlet UILabel *deCodeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)query
{
   return [[LocalEncryptService shareInstance] decryptAndQueryWithSkuNum:@"YingYing" error:nil];
}

- (void)save
{
    [[LocalEncryptService shareInstance] encryptAndSaveInfo:@"i still think it luckey to meet you." SkuNum:@"YingYing"];
}

- (void)showInfo:(NSString *)info
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:info message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [al show];
}

- (IBAction)encodeAction:(id)sender {
    if (self.skuLabel.text.length == 0) {
        [self showInfo:@"请输入sku"];
        return;
    }
    if (self.oriTextView.text.length == 0) {
        [self showInfo:@"请输入加密内容"];
        return;
    }
    if(self.validitySecondsLabel.text)
    {
         [[LocalEncryptService shareInstance] bindSku:self.skuLabel.text validityPeriod:@(self.validitySecondsLabel.text.integerValue)];
    }

    NSString *encodeString =  [[LocalEncryptService shareInstance] encryptAndSaveInfo:self.oriTextView.text SkuNum:self.skuLabel.text];
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"加密后内容" message:encodeString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [al show];
    self.oriTextView.text = nil;
}


- (IBAction)decodeAction:(id)sender {
    if (self.skuLabel.text.length == 0) {
        [self showInfo:@"请输入sku"];
        return;
    }
    NSError *error;
    NSString *d = [[LocalEncryptService shareInstance] decryptAndQueryWithSkuNum:self.skuLabel.text error:&error];
    if (error) {
        [self showInfo:error.domain];
    }
    else
    {
        self.deCodeLabel.text = d;
    }
}

- (IBAction)clearTextF:(id)sender {
    self.oriTextView.text = nil;
}
- (IBAction)endEdit:(id)sender {
    [self.view endEditing:YES];
}

@end
