//
//  TransitionViewController.h
//  UIPresentationExampleProject
//
//  Created by Steven Chien on 11/4/14.
//  Copyright (c) 2014 stevenchien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitionViewController : UIPresentationController

- (id)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController;

@end
