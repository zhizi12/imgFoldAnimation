//
//  BigImgView.m
//  ImgFoldAnimation
//
//  Created by jinglan on 2016/11/1.
//  Copyright © 2016年 zhang. All rights reserved.
//

#import "BigImgView.h"


@interface BigImgView ()

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UIImageView *topImgView;
@property (nonatomic, strong) UIImageView *bottomImgView;
@property (nonatomic, strong) CAGradientLayer *topShadowLayer;
@property (nonatomic, strong) CAGradientLayer *bottomShadowLayer;

@property (nonatomic, assign) NSUInteger initialLocation;
@property (nonatomic, assign) CGPoint initialPoint;
@property (nonatomic, assign) float lastPercent;
@end

@implementation BigImgView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        _lastPercent = 0.0;
    }
    return self;
}

- (void)setupUI{
    [self addSubview:self.topImgView];
    [self addSubview:self.bottomImgView];
    [self addGestureRecognizer];
}

-(void)addGestureRecognizer{

    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];

    [self.topImgView addGestureRecognizer:panGesture];
    
    UIPanGestureRecognizer *panGesture2  =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan2:)];
 
    [self.bottomImgView addGestureRecognizer:panGesture2];
}



-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    //获取手指在PageView中的初始坐标
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"初始化");
        self.initialLocation = location.y;
        self.initialPoint = location;
        [self bringSubviewToFront:self.topImgView];
    }
    
    //添加阴影
    if ([[self.topImgView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] < -M_PI_2) {
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        [CATransaction commit];
    } else {
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        CGFloat opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        self.bottomShadowLayer.opacity = opacity;
        self.topShadowLayer.opacity = opacity;
        [CATransaction commit];
    }
    
    
    
    //如果手指在PageView里面,开始使用POPAnimation
    if([self isLocation:location InView:self]){
        //把一个PI平均分成可以下滑的最大距离份
       CGFloat percent = -M_PI / (self.frame.size.height - self.initialLocation);
        if (_lastPercent == percent) {
            _lastPercent = percent;
            return;
        }
        
        NSLog(@"开始转");
        
          //  CGFloat percent = -M_PI / 200;
        
        NSLog(@"%f",percent);
        
        CABasicAnimation* rotationAnimation;
        //绕哪个轴，那么就改成什么：这里是绕x轴 ---> transform.rotation.x
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
        //旋转角度
        rotationAnimation.fromValue = @((location.y-self.initialLocation)*_lastPercent);
        _lastPercent = percent;

        rotationAnimation.toValue = @((location.y-self.initialLocation)*percent);
        //每次旋转的时间（单位秒）
       // rotationAnimation.duration = 0.01;
       rotationAnimation.cumulative = NO;
        //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
        rotationAnimation.repeatCount = 0;
        [self.topImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        //当松手的时候，自动复原
        if (recognizer.state == UIGestureRecognizerStateEnded ||
            recognizer.state == UIGestureRecognizerStateCancelled) {

            CABasicAnimation* recoverAnimation;
            //绕哪个轴，那么就改成什么：这里是绕x轴 ---> transform.rotation.x
            recoverAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
            //旋转角度
            recoverAnimation.toValue = @(0);
            //每次旋转的时间（单位秒）
            recoverAnimation.duration = 0.40;
            recoverAnimation.cumulative = YES;
            //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
            recoverAnimation.repeatCount = 0;
            [self.topImgView.layer addAnimation:recoverAnimation forKey:@"recoverAnimation"];
 
            self.topShadowLayer.opacity = 0.0;
            self.bottomShadowLayer.opacity = 0.0;
        }
       
    }
    
    //手指超出边界也自动复原
    if (location.y < 0 || (location.y - self.initialLocation)>self.frame.size.height-(self.initialLocation)) {
        recognizer.enabled = NO;
   
        
         CABasicAnimation* recoverAnimation;
         //绕哪个轴，那么就改成什么：这里是绕x轴 ---> transform.rotation.x
         recoverAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
         //旋转角度
         recoverAnimation.toValue = @(0);
         //每次旋转的时间（单位秒）
         recoverAnimation.duration = 0.40;
         recoverAnimation.cumulative = YES;
         //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
         recoverAnimation.repeatCount = 0;
         [self.topImgView.layer addAnimation:recoverAnimation forKey:@"recoverAnimation"];

        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = 0.0;
       
    }
    
    recognizer.enabled = YES;

}

-(BOOL)isLocation:(CGPoint)location InView:(UIView *)view{
    if ((location.x > 0 && location.x < view.bounds.size.width) &&
        (location.y > 0 && location.y < view.bounds.size.height)) {
        return YES;
    }else{
        return NO;
    }
}


-(void)pan2:(UIPanGestureRecognizer *)recognizer{
}
#pragma mark - 设置3D的透视效果
-(CATransform3D)setTransform3D{
    //如果不设置这个值，无论转多少角度都不会有3D效果
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5/-2000;
    return transform;
}

- (UIImage *)cutImageWithID:(NSString *)ID{
    CGRect rect = CGRectMake(0, 0, self.img.size.width, self.img.size.height / 2.0);
    if ([ID isEqualToString:@"bottom"]){
        rect.origin.y = self.img.size.height / 2.0;
    }
    
    CGImageRef imgRef = CGImageCreateWithImageInRect(self.img.CGImage, rect);
    UIImage *cuttedImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return cuttedImage;
}

- (UIImageView *)topImgView{
    if (!_topImgView) {
        
        _topImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
        _topImgView.layer.anchorPoint = CGPointMake(0.5, 1);
        _topImgView.layer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _topImgView.layer.transform   = [self setTransform3D];
        
        _topImgView.contentMode = UIViewContentModeScaleAspectFill;
        _topImgView.image = [self cutImageWithID:@"top"];
        _topImgView.userInteractionEnabled = YES;
        self.topShadowLayer = [CAGradientLayer layer];
        self.topShadowLayer.frame = _topImgView.bounds;
        self.topShadowLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
        self.topShadowLayer.opacity = 0;
        [_topImgView.layer addSublayer:self.topShadowLayer];

    }
    return _topImgView;
}



- (UIImageView *)bottomImgView{
    if (!_bottomImgView) {
         _bottomImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2)];
        _bottomImgView.layer.anchorPoint = CGPointMake(0.5, 0);
        
        _bottomImgView.layer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

        _bottomImgView.layer.transform   = [self setTransform3D];
        
        _bottomImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bottomImgView.image = [self cutImageWithID:@"bottom"];
        _bottomImgView.userInteractionEnabled = YES;
        self.bottomShadowLayer = [CAGradientLayer layer];
        self.bottomShadowLayer.frame = _bottomImgView.bounds;
        self.bottomShadowLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
        self.bottomShadowLayer.opacity = 0;
        [_bottomImgView.layer addSublayer:self.topShadowLayer];

    }
    return _bottomImgView;
}

- (UIImage *)img{
    if (!_img) {
        _img = [UIImage imageNamed:@"backImg"];
    }
    return _img;
}

@end
