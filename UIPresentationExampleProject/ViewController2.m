//
//  UIViewController+ViewController2.m
//  UIPresentationExampleProject
//
//  Created by Steven Chien on 11/4/14.
//  Copyright (c) 2014 stevenchien. All rights reserved.
//

#import "ViewController2.h"
#import "TransitionViewDelegate.h"
#import "ViewController.h"

@interface ViewController2()
{
    TransitionViewDelegate *transitionDelegate;
}

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    transitionDelegate = [[TransitionViewDelegate alloc] init];
    //    UIGraphicsBeginImageContext(self.view.frame.size);
    //    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    currentImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    // Do any additional setup after loading the view, typically from a nib.
    __unsafe_unretained typeof(self) weakSelf = self;
    // Do any additional setup after loading the view, typically from a nib.
    [self createLetterPressImages];
    //    [self.view setTappedGestureWithBlock:^{
    //        [weakSelf createLetterPressImages];
    //    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createLetterPressImages
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"madbum"] ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    UIImageView *imgV = [[UIImageView alloc] initWithImage:image];
    imgV.frame = self.view.bounds;
    [imgV setContentMode:UIViewContentModeScaleAspectFill];
    [imgV setCenter:self.view.center];
    
    imgV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shatterToViewController)];
    tap.numberOfTapsRequired=1;
    [imgV addGestureRecognizer:tap];
    
    __unsafe_unretained typeof(imgV) weakSelf = imgV;
    [self.view addSubview:imgV];
    
    //    [imgV setTappedGestureWithBlock:^{
    //        [weakSelf explode];
    //        [weakSelf setTappedGestureWithBlock:nil];
    //    }];
}

- (void)shatterToViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    ViewController *one = [[ViewController alloc] init];
//    one.transitioningDelegate = transitionDelegate;
//    one.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:one animated:YES completion:nil];
}

@end
