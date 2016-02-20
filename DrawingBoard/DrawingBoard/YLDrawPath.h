//
//  YLDrawPath.h
//  DrawingBoard
//
//  Created by 余亮 on 16/2/20.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLDrawPath : UIBezierPath
@property(nonatomic,strong) UIColor * lineColor ;

+ (instancetype)path ;
@end
