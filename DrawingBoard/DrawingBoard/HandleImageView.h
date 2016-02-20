//
//  HandleImageView.h
//  DrawingBoard
//
//  Created by 余亮 on 16/2/20.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HandleImageView ;

@protocol HandleImageViewDelegate <NSObject>

@optional
- (void) handleImageView:(HandleImageView *)handleImageView didHandleImage:(UIImage *)image ;

@end

@interface HandleImageView : UIView

@property(nonatomic,weak) id<HandleImageViewDelegate> delegate ;

@property(nonatomic,strong) UIImage * image ;
@end
