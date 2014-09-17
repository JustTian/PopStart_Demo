//
//  ViewController.m
//  PopStart_Demo
//
//  Created by tian on 14-9-15.
//  Copyright (c) 2014年 tian. All rights reserved.
//

#import "ViewController.h"
#import "ShareView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"tab_bar_button_compose_selected.png"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"tab_bar_button_compose_selected.png"] forState:UIControlStateNormal];
    button.frame = CGRectMake((self.view.bounds.size.width - 59)/2.0, (self.view.bounds.size.height - 48)/2.0, 59, 48);
    [button addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}
- (void)showMenu
{
    ShareView *menuView = [[ShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [menuView addMenuItemWithTitle:@"Text" andIcon:[UIImage imageNamed:@"post_type_bubble_text.png"] andSelectedBlock:^{
        NSLog(@"Text selected");
    }];
    [menuView addMenuItemWithTitle:@"Photo" andIcon:[UIImage imageNamed:@"post_type_bubble_photo.png"] andSelectedBlock:^{
        NSLog(@"Photo selected");
    }];
    [menuView addMenuItemWithTitle:@"Quote" andIcon:[UIImage imageNamed:@"post_type_bubble_quote.png"] andSelectedBlock:^{
        NSLog(@"Quote selected");
        
    }];
    [menuView addMenuItemWithTitle:@"Link" andIcon:[UIImage imageNamed:@"post_type_bubble_link.png"] andSelectedBlock:^{
        NSLog(@"Link selected");
        
    }];
    [menuView addMenuItemWithTitle:@"Chat" andIcon:[UIImage imageNamed:@"post_type_bubble_chat.png"] andSelectedBlock:^{
        NSLog(@"Chat selected");
        
    }];
    [menuView addMenuItemWithTitle:@"Video" andIcon:[UIImage imageNamed:@"post_type_bubble_video.png"] andSelectedBlock:^{
        NSLog(@"Video selected");
        
    }];
    
    
    
    [menuView show];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
