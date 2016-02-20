//
//  HandleImageView.m
//  DrawingBoard
//
//  Created by 余亮 on 16/2/20.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import "HandleImageView.h"

@interface HandleImageView () <HandleImageViewDelegate,UIGestureRecognizerDelegate>
@property(nonatomic,strong) UIImageView * imageV ;

@end

@implementation HandleImageView


- (UIImageView *)imageV
{
    if (!_imageV) {
//        UIImageView * imageView= [[UIImageView alloc] init];
//        _imageV = imageView ;
        _imageV = [[UIImageView alloc] init];
        [self addSubview:_imageV];
    }
    return  _imageV ;
}


- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__func__) ;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageV.frame = self.bounds ;
        [self addGesture ];
        self.imageV.userInteractionEnabled = YES ;
    }
    return self ;
}

- (void) addGesture
{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panClick:)];
    [self.imageV addGestureRecognizer:pan];
    
    [self setUpPinch];
    
    [self setUpLongProgress];
    
    [self setUpRotation];
}


- (void) panClick:(UIPanGestureRecognizer *)pan
{
   //获取手指平移的偏移量
    CGPoint offP = [pan translationInView:self.imageV];
    self.imageV.transform = CGAffineTransformTranslate(self.imageV.transform, offP.x, offP.y) ;
    //复位
    [pan setTranslation:CGPointZero inView:self.imageV];
}

- (void)setImage:(UIImage *)image
{
    _image = image ;
    self.imageV.image = image ;
}


#pragma mark  - 添加的手势
- (void) setUpPinch
{
    //捏合手势
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self ;
    [self.imageV addGestureRecognizer:pinch];
}

- (void) pinch:(UIPinchGestureRecognizer *)pinch
{
    self.imageV.transform = CGAffineTransformScale(self.imageV.transform, pinch.scale, pinch.scale);
    //复位
    pinch.scale = 1 ;
}


//是否同时支持多个手势
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES ;
}


- (void) setUpRotation
{
    //旋转手势
    UIRotationGestureRecognizer * rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
    rotation.delegate = self ;
    [self.imageV addGestureRecognizer:rotation] ;
}

- (void) rotation:(UIRotationGestureRecognizer *)rotation
{
    self.imageV.transform = CGAffineTransformRotate(self.imageV.transform, rotation.rotation);
    //复位(每次复位都是相对于上一次而言)
    rotation.rotation = 0 ;
    
}

- (void) setUpLongProgress
{
   //长按手势
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress :)];
    [self.imageV addGestureRecognizer:longPress] ;
}

- (void) longpress:(UILongPressGestureRecognizer *)longPress
{
    //长按手势需要做判断
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.25 animations:^{
            self.imageV.alpha = 0 ;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                self.imageV.alpha = 1 ;
            } completion:^(BOOL finished) {
                 // 把处理图片的View截屏.生成一张新的图片,展示到画板上
                   //开启位图上下文
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1.0);
                //渲染图层
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                //从上下文中取出图片
                UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
                //关闭上下文
                UIGraphicsEndImageContext() ;
                
                //// 处理图片完成的时候通知代理
                if ([_delegate respondsToSelector:@selector(handleImageView:didHandleImage:)]) {
                    [_delegate handleImageView:self didHandleImage:image];
                }
                
                //把处理图片的view移出父控件
                [self removeFromSuperview];
            }];
        }];
    }
}

@end
























