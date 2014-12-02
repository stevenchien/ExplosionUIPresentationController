//
//  TransitionViewDelegate.m
//  UIPresentationExampleProject
//
//  Created by Steven Chien on 11/4/14.
//  Copyright (c) 2014 stevenchien. All rights reserved.
//

#import "TransitionViewDelegate.h"
#import "TransitionViewController.h"
#import "ExplosionAnimation.h"
#import "RepairAnimation.h"

@implementation TransitionViewDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[TransitionViewController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[ExplosionAnimation alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[RepairAnimation alloc] init];
}

@end
