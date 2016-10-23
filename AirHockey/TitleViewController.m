//
//  TitleViewController.m
//  AirHockey
//
//  Created by Mikhail on 22.10.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import "TitleViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface TitleViewController ()

@end

@implementation TitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlay:(UIButton *)sender {
    [(AppDelegate *)[UIApplication sharedApplication].delegate playGame:sender.tag];
}

@end
