//
//  ShareView.m
//  PopStart_Demo
//
//  Created by tian on 14-9-16.
//  Copyright (c) 2014年 tian. All rights reserved.
//

#import "ShareView.h"
#import "UIImage+BlurredFrame.h"

#define THMenuViewTag 1999
#define THMenuViewColumnCount 3
#define THMenuViewImageHeight 90
#define THMenuViewTitleHeight 20
#define THMenuViewHideButtonHeight 40
#define THMenuViewVerticalPadding 10
#define THMenuViewHorizontalMargin 10
#define THMenuViewAnimationTime 0.3
#define THMenuViewAnimationBounciness 0.10
#define THMenuViewAnimationInterval (THMenuViewAnimationTime / 5.0)

@interface THMenuItemButton : UIButton

+ (id)menuItemButtonWithTitle:(NSString *)title andIcon:(UIImage *)icon andSelectBlock:(THMenuViewSelectedBlock)block;

@property (nonatomic,assign) THMenuViewSelectedBlock selectedBlock;

@end

@implementation THMenuItemButton

+ (id)menuItemButtonWithTitle:(NSString *)title andIcon:(UIImage *)icon andSelectBlock:(THMenuViewSelectedBlock)block{
    THMenuItemButton *button = [THMenuItemButton buttonWithType:UIButtonTypeCustom];
    [button setImage:icon forState:UIControlStateNormal];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;

    button.selectedBlock = block;

    return button;
}

- (void)layoutSubviews{

    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, THMenuViewImageHeight, THMenuViewImageHeight);
    self.titleLabel.frame = CGRectMake(0, THMenuViewImageHeight, THMenuViewImageHeight, THMenuViewTitleHeight);
//    self.frame = CGRectMake(0, 0, THMenuViewImageHeight, THMenuViewImageHeight+THMenuViewTitleHeight);
}


@end
#pragma mark----------------------------------

@interface ShareView ()
{

    NSMutableArray *_buttons;

}

@property (nonatomic,strong) UIImage *backgroundImage;
@property (nonatomic,strong) UIImageView *backgroundImageView;
@property (nonatomic,strong) UIButton *hideButton;
@end

@implementation ShareView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 添加手势点击隐藏视图
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideView)];
        [self addGestureRecognizer:tap];
        [self backgroundBlurred];
        _buttons = [[NSMutableArray alloc] initWithCapacity:6];
        
        [self hideButtonView];
    }
    return self;
}

#pragma mark-背景模糊
- (void)backgroundBlurred{
    // 创建背景视图
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self addSubview:self.backgroundImageView];
    self.backgroundImage = [self _convertViewToImage];
    self.backgroundImage = [self.backgroundImage applyExtraLightEffectAtFrame:self.bounds];
    self.backgroundImageView.image = self.backgroundImage;
}

#pragma mark-隐藏触发按钮
- (void)hideButtonView{
    //
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0,self.bounds.size.height-THMenuViewHideButtonHeight,self.bounds.size.width, THMenuViewHideButtonHeight)];
    buttonView.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
    buttonView.layer.shadowOffset = CGSizeMake(6, 6);
    buttonView.backgroundColor = [UIColor whiteColor];
    [self addSubview:buttonView];
    //
    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hideButton setImage:[UIImage imageNamed:@"hide_button.png"] forState:UIControlStateNormal];
    self.hideButton.frame = CGRectMake(buttonView.center.x-THMenuViewHideButtonHeight/2,0, THMenuViewHideButtonHeight, THMenuViewHideButtonHeight);
    self.hideButton.imageView.frame = CGRectMake(0, 0, 32, 32);
    [self.hideButton addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:self.hideButton];
}
#pragma mark-添加按钮
- (void)addMenuItemWithTitle:(NSString *)title andIcon:(UIImage *)icon andSelectedBlock:(THMenuViewSelectedBlock)block{
    
    THMenuItemButton *button = [THMenuItemButton menuItemButtonWithTitle:title andIcon:icon andSelectBlock:block];
    [button addTarget:self action:@selector(buttonTopped:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchCancel|UIControlEventTouchUpInside];
    button.hidden = YES;
    [self addSubview:button];
    [_buttons addObject:button];
   
}
- (void)buttonTopped:(THMenuItemButton *)button{

    

}


#pragma mark-重置动画
- (void)resetAnimation{
    [self pop_removeAllAnimations];

    //按钮旋转动画
    POPSpringAnimation *rotation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.toValue = @(M_PI_4);
    [self.hideButton.layer pop_addAnimation:rotation forKey:@"rotation"];
    
    //展开动画
    NSUInteger columnCount = THMenuViewColumnCount;
//    NSUInteger rowCount = _buttons.count / columnCount + (_buttons.count%columnCount>0?1:0);
    for (NSUInteger index = 0; index<_buttons.count; index++) {
        THMenuItemButton *button = _buttons[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index/columnCount; // 一共多少行
        NSUInteger columnIndex = index%columnCount; //最后一行多少个
        
        CGRect fromRect = CGRectMake(frame.origin.x,frame.origin.y + self.frame.size.height+THMenuViewImageHeight+THMenuViewTitleHeight,frame.size.width,frame.size.height);//实际是获取并且设置每个按钮的中心点
        
        button.frame = fromRect;
        button.hidden = NO;
        //计算动画时间
        double delayInSeconds = rowIndex  * THMenuViewAnimationInterval;
        if (columnIndex == 0) {
            delayInSeconds += THMenuViewAnimationInterval*rowIndex;
        }else if (columnIndex == 2 ){
            delayInSeconds += THMenuViewAnimationInterval*rowIndex+THMenuViewAnimationInterval;
        }
        
        POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        springAnimation.fromValue = [NSValue valueWithCGRect:fromRect];
        springAnimation.toValue = [NSValue valueWithCGRect:frame];
        springAnimation.springBounciness = THMenuViewAnimationBounciness;
        springAnimation.springSpeed = THMenuViewAnimationTime;
        springAnimation.dynamicsFriction = 15;//摩擦力
        springAnimation.beginTime = CACurrentMediaTime() + delayInSeconds;
        springAnimation.completionBlock = ^(POPAnimation *animation,BOOL isFinished){
            if (isFinished) {
                [self pop_animationForKey:@"resetAnimation"];
            }
        };
        [button pop_addAnimation:springAnimation forKey:@"resetAnimation"];

    }
}
#pragma mark-计算每个按钮的位置
- (CGRect)frameForButtonAtIndex:(NSUInteger)index{
    
    NSUInteger columnCount = THMenuViewColumnCount;
    NSUInteger columnIndex =  index % columnCount;
    
    NSUInteger rowCount = _buttons.count / columnCount + (_buttons.count%columnCount>0?1:0);
    NSUInteger rowIndex = index / columnCount;
    
    CGFloat itemHeight = (THMenuViewImageHeight + THMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * THMenuViewHorizontalMargin:0);
    CGFloat offsetY = (self.bounds.size.height - itemHeight) / 2.0;
    CGFloat verticalPadding = (self.bounds.size.width - THMenuViewHorizontalMargin * 2 - THMenuViewImageHeight * 3) / 2.0;
    
    CGFloat offsetX = THMenuViewHorizontalMargin;
    offsetX += (THMenuViewImageHeight+ verticalPadding) * columnIndex;
    
    offsetY += (THMenuViewImageHeight + THMenuViewTitleHeight + THMenuViewVerticalPadding) * rowIndex;
    
    
    return CGRectMake(offsetX, offsetY, THMenuViewImageHeight, (THMenuViewImageHeight+THMenuViewTitleHeight));

}

#pragma mark-转换当前显示View为Image
-(UIImage *)_convertViewToImage
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capturedScreen;
}

#pragma mark-显示
- (void)show
{

    [UIView animateWithDuration:THMenuViewAnimationInterval animations:^{
        
        self.backgroundImageView.alpha = 1.0;
    }];
    
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    [self resetAnimation];
    
}

#pragma mark-隐藏视图
- (void)hideView{
    
    //移除视图前界面动画
    [self dropAnimation];
    double delayInSeconds = THMenuViewAnimationTime  + THMenuViewAnimationInterval * (_buttons.count + 1);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));

    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:THMenuViewAnimationInterval animations:^{
            [self.backgroundImageView setAlpha:0];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    });

}
- (void)dropAnimation{

    POPSpringAnimation *rotation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.toValue = @(0);
    [self.hideButton.layer pop_addAnimation:rotation forKey:@"rotation"];
    //展开动画
    NSUInteger columnCount = THMenuViewColumnCount;
//    NSUInteger rowCount = _buttons.count / columnCount + (_buttons.count%columnCount>0?1:0);
    for (NSUInteger index = 0; index<_buttons.count; index++) {
        THMenuItemButton *button = _buttons[index];
        CGRect frame = [self frameForButtonAtIndex:index];
        NSUInteger rowIndex = index/columnCount; // 一共多少行
        NSUInteger columnIndex = index%columnCount; //最后一行多少个
        
        CGRect toRect = CGRectMake(frame.origin.x,frame.origin.y + self.frame.size.height+(THMenuViewImageHeight+THMenuViewTitleHeight),frame.size.width,frame.size.height);//实际是获取并且设置每个按钮的中心点
        
//        button.frame = fromRect;
//        button.hidden = NO;
        //计算动画时间
        double delayInSeconds = rowIndex  * THMenuViewAnimationInterval;
        if (columnIndex == 0) {
            delayInSeconds += THMenuViewAnimationInterval*rowIndex;
        }else if (columnIndex == 2 ){
            delayInSeconds += THMenuViewAnimationInterval*rowIndex+THMenuViewAnimationInterval;
        }
        
        POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        springAnimation.fromValue = [NSValue valueWithCGRect:frame];
        springAnimation.toValue = [NSValue valueWithCGRect:toRect];
        springAnimation.springBounciness = THMenuViewAnimationBounciness;
        springAnimation.springSpeed = THMenuViewAnimationTime;
        springAnimation.dynamicsFriction = 14;//摩擦力
        springAnimation.beginTime = CACurrentMediaTime() + delayInSeconds;
        springAnimation.completionBlock = ^(POPAnimation *animation,BOOL isFinished){
            if (isFinished) {
                [self pop_animationForKey:@"resetAnimation"];
                button.hidden = YES;
            }
        };
        [button pop_addAnimation:springAnimation forKey:@"resetAnimation"];
        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
