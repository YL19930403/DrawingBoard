//
//  YLDrawView.m
//  DrawingBoard
//
//  Created by 余亮 on 16/2/20.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import "YLDrawView.h"
#import "YLDrawPath.h"

@interface YLDrawView ()
@property(nonatomic,strong)UIBezierPath * path ;
@property(nonatomic,strong)NSMutableArray * paths ;

@end

@implementation YLDrawView

#pragma mark - 懒加载
- (NSMutableArray *)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths ;
}
- (void)drawRect:(CGRect)rect
{
    for (YLDrawPath * path in self.paths) {
        if ([path isKindOfClass:[UIImage class]]) {
            UIImage * image = (UIImage *)path ;
            [image drawAtPoint:CGPointZero];
        }else{
            [path.lineColor set];
            [path stroke];
        }
    }
}

- (void) setSelectImage:(UIImage *)selectImage
{
    _selectImage = selectImage ;
    [self.paths addObject:selectImage];
    [self setNeedsDisplay];
}

//- (void) setLineWidth:(CGFloat)lineWidth
//{
//    _lineWidth = lineWidth ;
//    _path.lineWidth = lineWidth ;
//    [self setNeedsDisplay];
//}

- (void)undo
{
    [self.paths removeLastObject];
    [self setNeedsDisplay];
}

- (void)clear
{
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
}

- (void)awakeFromNib
{
    _lineWidth = 1 ;
    _lineColor = [UIColor blackColor];
}

// 当手指点击view,就需要记录下起始点
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   //获取UITouch
    UITouch * touch = [touches anyObject ];
    //获取起始点
    CGPoint startP = [touch locationInView:self];
    
    //设置起始点
    YLDrawPath * path = [YLDrawPath path];
    path.lineColor = _lineColor ;
    [path moveToPoint:startP];
    
    path.lineWidth = _lineWidth ;
    
    //记录当前正在描述的路径
    _path = path ;
    
    //保存当前的路径
    [self.paths addObject:path];
    
    
}


//每次手指一动的时候调用
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取UITouch
    UITouch * touch = [touches anyObject];
    //获取当前触摸点
    CGPoint currentP = [touch locationInView:self];
    [_path addLineToPoint:currentP];
    //重绘
    [self setNeedsDisplay];
}



@end















