//
//  YLDrawView.h
//  DrawingBoard
//
//  Created by 余亮 on 16/2/20.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLDrawView : UIView
//线条的宽度
@property(nonatomic, assign)CGFloat lineWidth ;
//线条的颜色
@property(nonatomic,strong) UIColor * lineColor ;
//获取选中的照片
@property(nonatomic,strong) UIImage * selectImage ;

//清屏
- (void) clear ;

//撤销
- (void) undo ;

@end
