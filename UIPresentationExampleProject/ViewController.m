//
//  ViewController.m
//  UIPresentationExampleProject
//
//  Created by Steven Chien on 11/4/14.
//  Copyright (c) 2014 stevenchien. All rights reserved.
//

#import "ViewController.h"
//#import "ExplodeView.h"
#import "objc/runtime.h"
#import "TransitionViewDelegate.h"
#import "ViewController2.h"

typedef void(^GESTURE_Tapped)(void);
static NSString *GESTURE_BLOCK = @"GESTURE_BLOCK";

@interface UIView (PrivateExtensions)

-(void)setTappedGestureWithBlock:(GESTURE_Tapped)block;

@end

@interface ViewController () {
    TransitionViewDelegate *transitionDelegate;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    transitionDelegate = [[TransitionViewDelegate alloc] init];
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    currentImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    // Do any additional setup after loading the view, typically from a nib.
//    __unsafe_unretained typeof(self) weakSelf = self;
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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"sf"] ofType:@"jpg"];
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
    ViewController2 *two = [[ViewController2 alloc] init];
    two.transitioningDelegate = transitionDelegate;
    two.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:two animated:YES completion:nil];
}

@end

@implementation UIView (PrivateExtensions)

-(void)setTappedGestureWithBlock:(GESTURE_Tapped)block
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.numberOfTapsRequired=1;
    [self addGestureRecognizer:tap];
    
    objc_setAssociatedObject(self,&GESTURE_BLOCK,block, OBJC_ASSOCIATION_COPY);
}

-(void)tapped:(UIGestureRecognizer *)gesture
{
    if (gesture.state==UIGestureRecognizerStateEnded)
    {
        GESTURE_Tapped block = (GESTURE_Tapped)objc_getAssociatedObject(self, &GESTURE_BLOCK);
        
        if (block)
        {
            block();
            block = nil;
        }
    }
}

@end
