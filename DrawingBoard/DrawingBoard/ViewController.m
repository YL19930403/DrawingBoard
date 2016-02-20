//
//  ViewController.m
//  DrawingBoard
//
//  Created by 余亮 on 16/2/20.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import "ViewController.h"
#import "YLDrawView.h"
#import "MBProgressHUD+YL.h"
#import "HandleImageView.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,HandleImageViewDelegate>
@property (weak, nonatomic) IBOutlet YLDrawView *drawView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)clearScreen:(id)sender {
    [_drawView clear];
}

- (IBAction)undo:(id)sender {
    [_drawView undo];
}

- (IBAction)eraser:(id)sender {
    _drawView.lineColor = [UIColor whiteColor];
}

- (IBAction)pickerPhoto:(id)sender {
    //进入系统相册
       //照片选择器
    UIImagePickerController * imagePickerVC = [[UIImagePickerController alloc] init];
    imagePickerVC.delegate = self ;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum ;
    [self presentViewController:imagePickerVC animated:YES completion:^{
        
    }];
}

- (IBAction)savePhoto:(id)sender {
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(_drawView.bounds.size, NO, 0);
    //取出画板view的layer
    CALayer * layer = _drawView.layer ;
    //渲染上下文
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //从上下文中取出图片
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    
}

#pragma mark  -  UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 获取选择的照片
    UIImage * selectImage = info[UIImagePickerControllerOriginalImage];
    //对选择的照片需要做平移,缩放,旋转等处理
    HandleImageView * handleImageV = [[HandleImageView alloc] initWithFrame:_drawView.bounds];
    
    handleImageV.delegate = self ;
    handleImageV.image = selectImage ;
    
    [_drawView addSubview:handleImageV];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//图片保存完成的时候回调
-  (void)image :(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showSuccess:@"保存失败"];
    }else{
        [MBProgressHUD showSuccess:@"保存成功"];
    }
}

#pragma mark  -  HandleImageViewDelegate
- (void) handleImageView:(HandleImageView *)handleImageView didHandleImage:(UIImage *)image
{
    _drawView.selectImage = image ;
}

#pragma mark  -  换颜色、设线宽
- (IBAction)changeColor:(UIButton *)sender {
    _drawView.lineColor = sender.backgroundColor ;
}

- (IBAction)changeLineWidth:(UISlider *)sender {
    _drawView.lineWidth = sender.value ;
    NSLog(@"%f",sender.value);
}

@end









