//
//  ExplosionAnimation.m
//  UIPresentationExampleProject
//
//  Created by Steven Chien on 11/4/14.
//  Copyright (c) 2014 stevenchien. All rights reserved.
//

#import "ExplosionAnimation.h"

@interface LPParticleLayer : CALayer

@property (nonatomic, strong) UIBezierPath *particlePath;

@end

@interface ExplosionAnimation() {
    id <UIViewControllerContextTransitioning> currentContext;
    CALayer *currentViewLayer;
    CALayer *nextViewLayer;
    CALayer *previousViewLayer;
    NSArray *currentSublayers;
}

@end

@implementation ExplosionAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    currentContext = transitionContext;
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
    
    
    CGImageRef fullImage = [self imageFromLayer:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer].CGImage;
    
    //if its an image, set it to nil
    if ([self isKindOfClass:[UIImageView class]])
    {
        [(UIImageView*)self setImage:nil];
    }
    
    currentSublayers = [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers];
//    [[[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

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
            
            LPParticleLayer *layer = [LPParticleLayer layer];
            layer.frame = layerRect;
            layer.contents = (__bridge id)(tileImage);
            layer.borderWidth = 0.0f;
            layer.borderColor = [UIColor blackColor].CGColor;
            layer.particlePath = [self pathForLayer:layer parentRect:originalFrame];
            [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer addSublayer:layer];
            
            CGImageRelease(tileImage);
        }
    }
    
    
    [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer setFrame:originalFrame];
    [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer setBounds:originalBounds];
    
    
    [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    NSMutableArray *expandedArray = [[[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] mutableCopy];
    NSMutableArray *tempArray = [[[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] mutableCopy];

    for (LPParticleLayer *layer in tempArray) {
        if (layer.class != LPParticleLayer.class) {
            layer.hidden = YES;
            [expandedArray removeObject:layer];
        }
    }
    
    NSArray *sublayersArray = expandedArray;
    
    [sublayersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        LPParticleLayer *layer = (LPParticleLayer *)obj;
        
        //Path
        CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        if (layer.class == LPParticleLayer.class) {
            moveAnim.path = layer.particlePath.CGPath;
        }
        moveAnim.removedOnCompletion = YES;
        moveAnim.fillMode=kCAFillModeForwards;
        NSArray *timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],nil];
        [moveAnim setTimingFunctions:timingFunctions];
        
        float r = randomFloat();
        
        NSTimeInterval speed = 1.74*r;
        
        CAKeyframeAnimation *transformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D startingScale = layer.transform;
        CATransform3D endingScale = CATransform3DConcat(CATransform3DMakeScale(randomFloat(), randomFloat(), randomFloat()), CATransform3DMakeRotation(M_PI*(1+randomFloat()), randomFloat(), randomFloat(), randomFloat()));
        
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
        opacityAnim.fromValue = [NSNumber numberWithFloat:1.0f];
        opacityAnim.toValue = [NSNumber numberWithFloat:0.f];
        opacityAnim.removedOnCompletion = NO;
        opacityAnim.fillMode =kCAFillModeForwards;
        
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:moveAnim,transformAnim,opacityAnim, nil];
        animGroup.duration = speed;
        animGroup.fillMode =kCAFillModeForwards;
        animGroup.delegate = self;
        [animGroup setValue:layer forKey:@"animationLayer"];
        [layer addAnimation:animGroup forKey:nil];
        
        //take it off screen
        [layer setPosition:CGPointMake(0, -1000)];
        
    }];
    nextViewLayer = nil;
    CGImageRef nextImage = [self imageFromLayer:[transitionContext viewForKey:UITransitionContextToViewKey].layer].CGImage;
    nextViewLayer = [transitionContext viewForKey:UITransitionContextToViewKey].layer;
    nextViewLayer.frame = [transitionContext viewForKey:UITransitionContextToViewKey].frame;
    nextViewLayer.contents = (__bridge id)(nextImage);
    nextViewLayer.borderWidth = 0.0f;
    nextViewLayer.borderColor = [UIColor clearColor].CGColor;
    [[currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer addSublayer:nextViewLayer];
    
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:0.0f];
    opacityAnim.toValue = [NSNumber numberWithFloat:1.0f];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:opacityAnim, nil];
    animGroup.duration = 1.75f;
    animGroup.fillMode =kCAFillModeForwards;
    animGroup.delegate = self;
    [animGroup setValue:nextViewLayer forKey:@"animationLayer"];
    [nextViewLayer addAnimation:animGroup forKey:nil];
    
//    UIView *presentedView = [currentContext viewForKey:UITransitionContextToViewKey];
//    [[currentContext containerView] addSubview:presentedView];
//    [currentContext completeTransition:YES];
}

float randomFloat()
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
    LPParticleLayer *layer = [theAnimation valueForKey:@"animationLayer"];
    if (layer == nextViewLayer) {
        if ([[[currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] count]== [currentSublayers count])
        {
//            [[currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view removeFromSuperview];
            UIView *presentedView = [currentContext viewForKey:UITransitionContextToViewKey];
            [[currentContext containerView] addSubview:presentedView];
            for (CALayer *layer in currentSublayers) {
                layer.hidden = NO;
            }
            [currentContext completeTransition:YES];
        }
        else {
            [layer removeFromSuperlayer];
        }
    }
    else if (layer)
    {
        [layer removeFromSuperlayer];
        //make sure we dont have any more
//        if ([[[currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer sublayers] count]==[currentSublayers count])
//        {
////            [[currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view removeFromSuperview];
//            UIView *presentedView = [currentContext viewForKey:UITransitionContextToViewKey];
//            [[currentContext containerView] addSubview:presentedView];
//            for (CALayer *layer in currentSublayers) {
//                layer.hidden = NO;
//            }
//            [currentContext completeTransition:YES];
//        }
//        else
//        {
//            [layer removeFromSuperlayer];
//        }
    }
}

-(UIBezierPath *)pathForLayer:(CALayer *)layer parentRect:(CGRect)rect
{
    UIBezierPath *particlePath = [UIBezierPath bezierPath];
    [particlePath moveToPoint:layer.position];
    
    CGPoint curvePoint = CGPointMake(layer.position.x, layer.position.y);
    CGPoint endPoint = CGPointZero;
    
    float endY = [currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.superview.frame.size.height - [currentContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.origin.y;

    endPoint = CGPointMake(layer.position.x, endY);
    [particlePath addQuadCurveToPoint:endPoint
                         controlPoint:curvePoint];
    
    return particlePath;
    
}

@end

@implementation LPParticleLayer

@end
