//
//  RepairAnimation.m
//  UIPresentationExampleProject
//
//  Created by Steven Chien on 11/30/14.
//  Copyright (c) 2014 stevenchien. All rights reserved.
//

#import "RepairAnimation.h"
#import "ViewController.h"

@interface LPRepairLayer : CALayer

@property (nonatomic, strong) UIBezierPath *particlePath;

@end

@interface RepairAnimation() {
    id <UIViewControllerContextTransitioning> currentContext;
    CALayer *nextViewLayer;
    int numberOfSubLayers;
}

@end

@implementation RepairAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    currentContext = transitionContext;
    numberOfSubLayers = 0;
    float size = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / 3;
    CGSize imageSize = CGSizeMake(size, size);
    
    CGFloat cols = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / imageSize.width ;
    CGFloat rows = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height / imageSize.height;
    
    int fullColumns = floorf(cols);
    int fullRows = floorf(rows);
    
    CGFloat remainderWidth = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width  -
    (fullColumns * imageSize.width);
    CGFloat remainderHeight = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height -
    (fullRows * imageSize.height );
    
    
    if (cols > fullColumns) fullColumns++;
    if (rows > fullRows) fullRows++;
    
    CGRect originalFrame = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.frame;
    CGRect originalBounds = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.bounds;
    
    
    CGImageRef fullImage = [self imageFromLayer:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer].CGImage;
    
    //if its an image, set it to nil
    if ([self isKindOfClass:[UIImageView class]])
    {
        [(UIImageView*)self setImage:nil];
    }
    
    [[[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    for (int y = 0; y < fullRows; ++y)
    {
        for (int x = 0; x < fullColumns; ++x)
        {
            CGSize tileSize = imageSize;
            
            if (x + 1 == fullColumns && remainderWidth > 0)
            {
                // Last column
                tileSize.width = remainderWidth;
            }
            if (y + 1 == fullRows && remainderHeight > 0)
            {
                // Last row
                tileSize.height = remainderHeight;
            }
            
            CGRect layerRect = (CGRect){{x*imageSize.width, y*imageSize.height},
                tileSize};
            
            CGImageRef tileImage = CGImageCreateWithImageInRect(fullImage,layerRect);
            LPRepairLayer *layer = [LPRepairLayer layer];
            layer.frame = layerRect;
            layer.contents = (__bridge id)(tileImage);
            layer.borderWidth = 0.0f;
            layer.borderColor = [UIColor blackColor].CGColor;
            layer.particlePath = [self pathForLayer:layer parentRect:originalFrame];
            [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer addSublayer:layer];
            CGImageRelease(tileImage);
        }
    }
    [[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer setFrame:originalFrame];
    [[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer setBounds:originalBounds];
    
    
    [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    NSArray *sublayersArray = [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers];
    [sublayersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        LPRepairLayer *layer = (LPRepairLayer *)obj;
        
        //Path
        CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        if (layer.class == LPRepairLayer.class) {
            moveAnim.path = layer.particlePath.CGPath;
        }
        moveAnim.removedOnCompletion = YES;
        moveAnim.fillMode=kCAFillModeForwards;
        NSArray *timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
        [moveAnim setTimingFunctions:timingFunctions];
        
        float r = randomNumber();
        
        NSTimeInterval speed = 1.74*r;
        
        CAKeyframeAnimation *transformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D startingScale = CATransform3DConcat(CATransform3DMakeScale(randomNumber(), randomNumber(), randomNumber()), CATransform3DMakeRotation(M_PI*(1+randomNumber()), randomNumber(), randomNumber(), randomNumber()));
        CATransform3D endingScale = layer.transform;
        
        NSArray *boundsValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:startingScale],
                                 
                                 [NSValue valueWithCATransform3D:endingScale], nil];
        [transformAnim setValues:boundsValues];
        
        NSArray *times = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:speed*.25], nil];
        [transformAnim setKeyTimes:times];
        
        
        timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                           nil];
        [transformAnim setTimingFunctions:timingFunctions];
        transformAnim.fillMode = kCAFillModeForwards;
        transformAnim.removedOnCompletion = NO;
        
        //alpha
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:0.0f];
        opacityAnim.toValue = [NSNumber numberWithFloat:1.0f];
        opacityAnim.removedOnCompletion = NO;
        opacityAnim.fillMode =kCAFillModeForwards;
        
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:moveAnim,transformAnim,opacityAnim, nil];
        animGroup.duration = speed;
        animGroup.fillMode =kCAFillModeForwards;
        animGroup.delegate = self;
        [animGroup setValue:layer forKey:@"animationLayer"];
        [layer addAnimation:animGroup forKey:nil];
        
    }];
}

float randomNumber()
{
    return (float)rand()/(float)RAND_MAX;
}

- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    numberOfSubLayers++;
    if (numberOfSubLayers == [[[currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] count]) {
        NSArray *array = [[[currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] copy];
        for (LPRepairLayer *layer in array) {
            [layer removeFromSuperlayer];
        }
        [currentContext completeTransition:YES];
    }
}

- (UIBezierPath *)pathForLayer:(CALayer *)layer parentRect:(CGRect)rect
{
    UIBezierPath *particlePath = [UIBezierPath bezierPath];
    [particlePath moveToPoint:layer.position];
    
    CGPoint curvePoint = CGPointMake(layer.position.x, layer.position.y);
    if (layer.position.x < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / 4) && layer.position.y < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height / 4))
    {
        curvePoint = CGPointMake(layer.position.x * -2, layer.position.y * -2);
    }
    else if (layer.position.x < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width * 3 / 4) && layer.position.x >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / 4) && layer.position.y < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height / 4))
    {
        curvePoint = CGPointMake(layer.position.x, layer.position.y * -2);
    }
    else if (layer.position.x >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width * 3 / 4) && layer.position.y < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height / 4))
    {
        curvePoint = CGPointMake(layer.position.x * 2, layer.position.y * -2);
    }
    else if (layer.position.x < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / 4) && layer.position.y < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height * 3 / 4) && layer.position.y >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height / 4))
    {
        curvePoint = CGPointMake(layer.position.x * -2, layer.position.y);
    }
    else if (layer.position.x < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width * 3 / 4) && layer.position.x >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / 4) && layer.position.y < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height * 3 / 4) && layer.position.y >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height / 4))
    {
        curvePoint = CGPointMake(layer.position.x, layer.position.y);
    }
    else if (layer.position.x >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width * 3 / 4) && layer.position.y < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height * 3 / 4) && layer.position.y >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height / 4))
    {
        curvePoint = CGPointMake(layer.position.x * 2, layer.position.y);
    }
    else if (layer.position.x < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / 4) && layer.position.y >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height * 3 / 4))
    {
        curvePoint = CGPointMake(layer.position.x * -2, layer.position.y * 2);
    }
    else if (layer.position.x < ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width * 3 / 4) && layer.position.x >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width / 4) && layer.position.y >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height * 3 / 4))
    {
        curvePoint = CGPointMake(layer.position.x, layer.position.y * 2);
    }
    else if (layer.position.x >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.width * 3 / 4) && layer.position.y >= ([currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height * 3 / 4))
    {
        curvePoint = CGPointMake(layer.position.x * 2, layer.position.y * 2);
    }
    CGPoint endPoint = CGPointZero;
    
    float endY = [currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.superview.frame.size.height - [currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.origin.y;
    
    endPoint = CGPointMake(layer.position.x, layer.position.y);
    [particlePath addQuadCurveToPoint:endPoint
                         controlPoint:curvePoint];
    
    return particlePath;
    
}

@end

@implementation LPRepairLayer

@end
