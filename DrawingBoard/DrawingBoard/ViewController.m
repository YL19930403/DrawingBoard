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
#import <AssetsLibrary/AssetsLibrary.h>
#import <SVProgressHUD.h>

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,HandleImageViewDelegate>
@property (weak, nonatomic) IBOutlet YLDrawView *drawView;

/** 图片 */
@property(nonatomic,weak) UIImageView * imageView ;

/** 相册库 */
@property(nonatomic,strong) ALAssetsLibrary * library ;


@end

@implementation ViewController

- (ALAssetsLibrary *) library
{
    if (!_library) {
        _library = [[ALAssetsLibrary alloc] init];
    }
    return _library ;
}

#pragma mark - 自定义相册文件夹
static NSString * const YLGroupNameKey = @"YLGroupNameKey";
static NSString * const YLDefaultGroupName = @"我的画板相册";

- (NSString *)groupName
{
    //先从沙盒中取得名字
    NSString * groupName = [[NSUserDefaults standardUserDefaults] stringForKey:YLGroupNameKey];
    if (groupName == nil) {   //沙盒中没有存储任何文件夹的名字
        groupName = YLDefaultGroupName ;
        
        //存储名字到沙盒中
        [[NSUserDefaults standardUserDefaults] setObject:groupName forKey:YLGroupNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];  //立即同步
    }
    return groupName ;
}


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
    //获得文件夹的名字
    __block NSString * groupName = [self groupName];
    
    //self的弱引用
     __weak typeof(self) weakSelf = self ;
    
    //图片库
    __weak  ALAssetsLibrary * weakLibrary = self.library ;
    
    //创建文件夹
    [weakLibrary addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
        if (group) {   //新创建的文件夹
            [weakSelf addImageToGroup:group];
        }else{     //文件夹已经存在
            [weakLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                NSString * name = [group valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:groupName]) {   //是自己创建的文件夹
                    //添加图片到文件夹中
                    [weakSelf addImageToGroup:group];
                    
                    //停止遍历
                    * stop = YES ;
                }else if ([name isEqualToString:@"Camera Roll"]){
                    //文件夹被用户强制删除了
                    groupName = [groupName stringByAppendingString:@" "];
                    //存储新的名字
                    [[NSUserDefaults standardUserDefaults] setObject:groupName forKey:YLGroupNameKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    //创建新的文件夹
                    [weakLibrary addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
                        //添加图片到文件夹中
                        [weakSelf addImageToGroup:group];
                    } failureBlock:nil];
                }
            } failureBlock:nil];
        }
    } failureBlock:nil];
    
}

/**
 *  添加一张图片到某个文件夹中
 */
- (void) addImageToGroup:(ALAssetsGroup *)group
{
    __weak ALAssetsLibrary * weakLibrary = self.library ;
    //需要保存的图片
    
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
//     UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    CGImageRef CGImage = image.CGImage ;
    [weakLibrary writeImageToSavedPhotosAlbum:CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        [weakLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            //添加一张图片到自定义的文件夹中
            [group addAsset:asset];
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        } failureBlock:nil];
    }];
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
















