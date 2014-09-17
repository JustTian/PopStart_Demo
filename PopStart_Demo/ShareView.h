//
//  ShareView.h
//  PopStart_Demo
//
//  Created by tian on 14-9-16.
//  Copyright (c) 2014年 tian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^THMenuViewSelectedBlock)(void);

@interface ShareView : UIView<UIGestureRecognizerDelegate>

- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(THMenuViewSelectedBlock)block;
- (void)show;

@end
