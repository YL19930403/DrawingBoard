//
//  MBProgressHUD+YL.h
//
//  Created by 余亮 on 16/2/20.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import "MBProgressHUD.h"


@interface MBProgressHUD ()
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
