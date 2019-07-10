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
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _oriTextView.layer.cornerRadius = 5;
    _oriTextView.layer.borderColor = UIColor.grayColor.CGColor;
    _oriTextView.layer.borderWidth = 0.5;
    _timeLabel.text = nil;
}

- (NSString *)query
{
   return [[LocalEncryptService shareInstance] decryptAndQueryWithSkuNum:@"999" error:nil];
}

- (void)save
{
    [[LocalEncryptService shareInstance] encryptAndSaveInfo:@"Love is a touch and yet not a touch.——Jerome David Salinger" SkuNum:@"YingYing"];
}

- (void)showInfo:(NSString *)info title:(NSString *)title
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:info preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:alertAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (IBAction)encodeAction:(id)sender {
    if (self.skuLabel.text.length == 0) {
        [self showInfo:@"请输入sku" title:@"提示"];
        return;
    }
    if (self.oriTextView.text.length == 0) {
        [self showInfo:@"请输入加密内容" title:@"提示"];
        return;
    }
    if(self.validitySecondsLabel.text)
    {
         [[LocalEncryptService shareInstance] bindSku:self.skuLabel.text validityPeriod:@(self.validitySecondsLabel.text.integerValue)];
    }

    NSString *encodeString =  [[LocalEncryptService shareInstance] encryptAndSaveInfo:self.oriTextView.text SkuNum:self.skuLabel.text];

    NSString *encodeInfo = [NSString stringWithFormat:@"\n\n加密后的内容\n%@",encodeString];
    self.oriTextView.text = [self.oriTextView.text stringByAppendingString:encodeInfo];
    [ViewController dispatchSourceTimerWithSeconds:self.validitySecondsLabel.text.integerValue inProgressBlock:^(NSInteger sec) {
        if (sec == 0) {
            self.timeLabel.text = @"密码已过期";
            return ;
        }
        self.timeLabel.text = [NSString stringWithFormat:@"%@s后过期", @(sec)];
    } periodOverBlock:^{
    }];
}


- (IBAction)decodeAction:(id)sender {
    if (self.skuLabel.text.length == 0) {
        [self showInfo:@"请输入sku" title:@"提示"];
        return;
    }
    NSError *error;
    NSString *d = [[LocalEncryptService shareInstance] decryptAndQueryWithSkuNum:self.skuLabel.text error:&error];
    if (error) {
        [self showInfo:error.domain title:@"提示"];
    }
    else
    {
        NSString *decodeInfo = [NSString stringWithFormat:@"\n\n解密后的内容\n%@",d];
        self.oriTextView.text = [self.oriTextView.text stringByAppendingString:decodeInfo];
    }
}

- (IBAction)clearTextF:(id)sender {
    self.oriTextView.text = nil;
    _timeLabel.text = nil;
}
- (IBAction)endEdit:(id)sender {
    [self.view endEditing:YES];
}


+ (void)dispatchSourceTimerWithSeconds:(NSInteger)seconds  inProgressBlock:(void (^)(NSInteger))inProgressBlock periodOverBlock:(void (^)(void))periodOverBlock
{
    NSInteger timeOut = seconds; //default:60
    __block NSInteger second = timeOut;
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (second == 0) {
                if(periodOverBlock) periodOverBlock();
                second = timeOut;
                dispatch_cancel(timer);
            } else {
                second--;
                if(inProgressBlock)inProgressBlock(second);
            }
        });
    });
    dispatch_resume(timer);
}

@end
