//
//  ViewController.m
//  WebRTC_Demo
//
//  Created by 杨宇航 on 2020/7/22.
//  Copyright © 2020 杨宇航. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)chat:(id)sender {
    [self.navigationController pushViewController:[ChatViewController new] animated:YES];
}


@end
