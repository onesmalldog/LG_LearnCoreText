//
//  ViewController.m
//  testCoreText
//
//  Created by gg on 2019/4/3.
//  Copyright © 2019 gg. All rights reserved.
//

#import "ViewController.h"
#import "LGLabel.h"
#import <YYText/YYText.h>
#import "GGLabel.h"
#import "LSLabel.h"

typedef enum : NSUInteger {
    ChangeTypeNone = 0,
    ChangeTypeFontSize,
    ChangeTypeFontKern,
    ChangeTypeLineSpacing,
} LabelChangeType;

#define MAX_FONTSIZE 20.0
#define MIN_FONTSIZE 10.0
#define MAX_KERN 20.0
#define MIN_KERN 0.0
#define MAX_LINESPACING 20.0
#define MIN_LINESPACING 0.0


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property ( weak , nonatomic) id label;
@property (assign, nonatomic) LabelChangeType changeType;
@property (strong, nonatomic) YYTextLayout *layout;
@property ( weak , nonatomic) UIView *bgView;
@property (strong, nonatomic) LSLabel *lslabel;
@end

@implementation ViewController {
    CGPoint _oldPoint;
    UIFont *_begainFont;
    CGRect _lastFrame;
    CGFloat _oldSliderValue;
    CGPoint _center;
}
- (void)load_lsLabel {
    LSLabel *label = [[LSLabel alloc] initWithFrame:self.view.bounds];
    label.clipsToBounds = NO;
    label.text = @"abcdefgh";
    //@"听见,冬天的离开,我在某年某月醒过来,我想我等我期待,未来却不能理智安排,-- 阴天,傍晚车窗外,未来有一个人在等待,向左向右向前看,爱要拐几个弯才来,我遇见谁会有怎样的对白,我等的人他在多远的未来,我听见风来自地铁和人海,我排著队拿著爱的号码牌,我往前飞飞过一片时间海,我们也常在爱情里受伤害,我遇见谁会有怎样的对白,我等的人他在多远的未来,我听见风来自地铁和人海,我排著队拿著爱的号码牌,我往前飞飞过一片时间海,我们也常在爱情里受伤害,我看著路梦的入口有点窄,我遇见你是最美丽的意外";
    
    NSRange range = NSMakeRange(0, label.text.length);
    label.fontKern = @[[LSFontAttribute attributeWithValue:@(2) range:range]];
    label.lineSpacing = 5;
    
    label.font = @[[LSFontAttribute attributeWithValue:[UIFont systemFontOfSize:24] range:range]];
    
    label.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:label];
    self.lslabel = label;
    label.frame = self.view.bounds;//CGRectMake(20, 64, 150, self.view.frame.size.height-64-44-40 - 600);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat width = label.final_size.width;//377.81331250000005;
        CGFloat height = label.final_size.height;//650.22499999999991;
        CGFloat x = self.view.center.x - width*0.5;//label.final_size.width*0.5;
        CGFloat y = self.view.center.y - height*0.5;//label.final_size.height*0.5;
        CGRect frame = CGRectMake(x, y, width, height);
//        label.frame = frame;
    });
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self load_lsLabel];
    return;
    
    
    
    _center = self.view.center;
    
//    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    
    LGLabel *label = [[LGLabel alloc] initWithFrame:CGRectMake(20, 100, 350, 700)];
    label.clipsToBounds = NO;
    label.text = @"Welcome to Hell";
    //@"听见,冬天的离开,我在某年某月醒过来,我想我等我期待,未来却不能理智安排,-- 阴天,傍晚车窗外,未来有一个人在等待,向左向右向前看,爱要拐几个弯才来,我遇见谁会有怎样的对白,我等的人他在多远的未来,我听见风来自地铁和人海,我排著队拿著爱的号码牌,我往前飞飞过一片时间海,我们也常在爱情里受伤害,我遇见谁会有怎样的对白,我等的人他在多远的未来,我听见风来自地铁和人海,我排著队拿著爱的号码牌,我往前飞飞过一片时间海,我们也常在爱情里受伤害,我看著路梦的入口有点窄,我遇见你是最美丽的意外";
    NSRange range = NSMakeRange(0, label.text.length);
//    label.font = @[[LGFontAttribute attributeWithValue:[UIFont systemFontOfSize:18] range:NSMakeRange(0, 6)]];
//    label.textForegroundColor = @[[LGFontAttribute attributeWithValue:[UIColor brownColor] range:NSMakeRange(8, 12)]];
//    label.textBackgroundColor = @[[LGFontAttribute attributeWithValue:[UIColor brownColor] range:NSMakeRange(24, 8)], [LGFontAttribute attributeWithValue:[UIColor greenColor] range:NSMakeRange(48, 5)]];
    label.numberOfLines = 0;
    label.fontKern = @[[LGFontAttribute attributeWithValue:@(2) range:range]];
    label.lineSpacing = 2;
//    label.underLine = @[[LGFontAttribute attributeWithValue:@(3) range:range]];
//    label.underLineColor = @[[LGFontAttribute attributeWithValue:[UIColor redColor] range:range]];
//    label.strokeWidth = @[[LGFontAttribute attributeWithValue:@(4) range:NSMakeRange(0, label.text.length)]];
//    label.strokeColor = @[[LGFontAttribute attributeWithValue:[UIColor redColor] range:NSMakeRange(0, label.text.length)]];
//    label.verticalForms = @[[LGFontAttribute attributeWithValue:[NSNumber numberWithBool:kCFBooleanTrue] range:NSMakeRange(0, label.text.length)]];
//    label.isVerticalForms = YES;
//    label.strikethroughStyle = @[[LGFontAttribute attributeWithValue:@(5) range:NSMakeRange(0, label.text.length)]];
    label.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:label];
    self.label = label;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"___%@", NSStringFromCGSize(label.layout.final_size));
        label.center = self.view.center;
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.layout.final_size.width, label.layout.final_size.height);
    });
    
    [self initYYLabel];
    
    _oldSliderValue = self.slider.value;
    _oldPoint = CGPointZero;
}
- (void)initYYLabel {
    
    
    GGLabel *yylabel = [[GGLabel alloc] initWithFrame:CGRectMake(0, 100, 300, 400)];
    yylabel.backgroundColor = [UIColor clearColor];
//    yylabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    yylabel.numberOfLines = 0;
//    yylabel.verticalForm = YES;
    NSString* YuJian = @"1234\n5678";
    //@"听见,冬天的离开,我在某年某月醒过来,我想我等我期待,未来却不能理智安排,-- 阴天,傍晚车窗外,未来有一个人在等待,向左向右向前看,爱要拐几个弯才来,我遇见谁会有怎样的对白,我等的人他在多远的未来,我听见风来自地铁和人海,我排著队拿著爱的号码牌,我往前飞飞过一片时间海,我们也常在爱情里受伤害,我遇见谁会有怎样的对白,我等的人他在多远的未来,我听见风来自地铁和人海,我排著队拿著爱的号码牌,我往前飞飞过一片时间海,我们也常在爱情里受伤害,我看著路梦的入口有点窄,我遇见你是最美丽的意外";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:YuJian];
    
    _begainFont = [UIFont systemFontOfSize:20];
    attr.yy_font = _begainFont;
    attr.yy_kern = @(2);
    attr.yy_lineSpacing = 2;
//    [attr yy_setFont:_begainFont range:NSMakeRange(0, YuJian.length)];
//    [attr yy_setKern:@(2) range:NSMakeRange(0, YuJian.length)];
//    [attr yy_setLineSpacing:2 range:NSMakeRange(0, YuJian.length)];
    
//    attr.yy_backgroundColor = [UIColor yellowColor];
//    attr.yy_color = [UIColor blackColor];
//    [attr yy_setColor:[UIColor redColor] range:NSMakeRange(0, YuJian.length)];
//    [attr yy_setBackgroundColor:[UIColor yellowColor] range:NSMakeRange(0, YuJian.length)];
    
    
    
//    [attr yy_setVerticalGlyphForm:YES range:NSMakeRange(0, YuJian.length)];
//    for (int i = 0; i < YuJian.length; i++) {
//        [attr yy_setVerticalGlyphForm:YES range:NSMakeRange(i, 1)];
//    }
    
//
//    NSRange strikethroughRange = NSMakeRange(0, 3);
//    [attr yy_setStrikethroughStyle:NSUnderlineStyleSingle range:strikethroughRange];
//    [attr yy_setStrikethroughColor:[UIColor redColor] range:strikethroughRange];
//
//    [attr yy_setColor:[UIColor cyanColor] range:NSMakeRange(21, 7)];
//
//    [attr yy_setColor:[UIColor cyanColor] range:NSMakeRange(39, 21)];
//
//
//    [attr yy_setVerticalGlyphForm:YES range:NSMakeRange(0, YuJian.length)];
    
    yylabel.attributedText = attr;
    
    [self.view addSubview:yylabel];
    self.label = yylabel;
    
    [self updateYYLabelWithFontSizeLarge:NO];
    yylabel.frame = CGRectMake(_center.x-yylabel.final_size.width*0.5, _center.y-yylabel.final_size.height*0.5, yylabel.final_size.width, yylabel.final_size.height*2);
    
    UIView *bgView = [[UIView alloc] initWithFrame:yylabel.frame];
    bgView.backgroundColor = [UIColor brownColor];
    [self.view insertSubview:bgView belowSubview:yylabel];
    self.bgView = bgView;
    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 150, 50) cornerRadius:20];
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(0, 0)];
//    [path addQuadCurveToPoint:CGPointMake(yylabel.bounds.size.width, 0) controlPoint:CGPointMake(yylabel.bounds.size.width * 0.5, yylabel.frame.size.height*0.5)];
//    yylabel.exclusionPaths = @[path];
}
- (IBAction)fontSizeBtnClick:(id)sender {
    if (self.changeType != ChangeTypeFontSize) {
        
        self.slider.hidden = NO;
        GGLabel *label = self.label;
        self.slider.value = (label.attributedText.yy_font.pointSize - MIN_FONTSIZE) / (MAX_FONTSIZE - MIN_FONTSIZE);
        _oldSliderValue = self.slider.value;
        self.changeType = ChangeTypeFontSize;
    }
    else {
        if (self.slider.hidden) {
            self.slider.hidden = NO;
            GGLabel *label = self.label;
            self.slider.value = (label.attributedText.yy_font.pointSize - MIN_FONTSIZE) / (MAX_FONTSIZE - MIN_FONTSIZE);
            _oldSliderValue = self.slider.value;
            self.changeType = ChangeTypeFontSize;
        }
        else {
            self.slider.hidden = YES;
        }
    }
}
- (IBAction)fontKernBtnClick:(id)sender {
    if (self.changeType != ChangeTypeFontKern) {
        self.slider.hidden = NO;
        GGLabel *label = self.label;
        self.slider.value = (label.attributedText.yy_kern.floatValue - MIN_KERN) / (MAX_KERN - MIN_KERN);
        _oldSliderValue = self.slider.value;
        self.changeType = ChangeTypeFontKern;
    }
    else {
        if (self.slider.hidden) {
            self.slider.hidden = NO;
            GGLabel *label = self.label;
            self.slider.value = (label.attributedText.yy_kern.floatValue - MIN_KERN) / (MAX_KERN - MIN_KERN);
            _oldSliderValue = self.slider.value;
            self.changeType = ChangeTypeFontKern;
        }
        else {
            self.slider.hidden = YES;
        }
    }
}
- (IBAction)lineSpacingBtnClick:(id)sender {
    if (self.changeType != ChangeTypeLineSpacing) {
        self.slider.hidden = NO;
        GGLabel *label = self.label;
        self.slider.value = (label.attributedText.yy_lineSpacing - MIN_LINESPACING) / (MAX_LINESPACING - MIN_LINESPACING);
        _oldSliderValue = self.slider.value;
        self.changeType = ChangeTypeLineSpacing;
    }
    else {
        if (self.slider.hidden) {
            self.slider.hidden = NO;
            GGLabel *label = self.label;
            self.slider.value = (label.attributedText.yy_lineSpacing - MIN_LINESPACING) / (MAX_LINESPACING - MIN_LINESPACING);
            _oldSliderValue = self.slider.value;
            self.changeType = ChangeTypeLineSpacing;
        }
        else {
            self.slider.hidden = YES;
        }
    }
}
- (IBAction)radiuBtnClick:(id)sender {
}

- (IBAction)resetBtnClick:(id)sender {
    @autoreleasepool {
        GGLabel *label = self.label;
        self.label = nil;
        [label removeFromSuperview];
        [self.bgView removeFromSuperview];
        self.bgView = nil;
    }
    [self initYYLabel];
    self.slider.hidden = YES;
}

- (IBAction)sliderValueChanged:(id)sender {
    
    UISlider *slider = sender;
    if (_oldSliderValue == slider.value) {
        return;
    }
    BOOL isLarge = NO;
    if (_oldSliderValue < slider.value) {
        isLarge = YES;
    }
    else {
        isLarge = NO;
    }
    GGLabel *label = self.label;
    
    switch (self.changeType) {
        case ChangeTypeFontSize: {
            CGFloat size = slider.value * (MAX_FONTSIZE - MIN_FONTSIZE) + MIN_FONTSIZE;
            UIFont *font = label.attributedText.yy_font;
            font = [UIFont fontWithName:font.fontName size:size];
            [self setYYLabelFont:font];
            
        } break;
        case ChangeTypeFontKern: {
            CGFloat kern = slider.value * (MAX_KERN - MIN_KERN) + MIN_KERN;
            [self setYYLabelKern:@(kern)];
        } break;
        case ChangeTypeLineSpacing: {
            CGFloat space = slider.value * (MAX_LINESPACING - MIN_LINESPACING) + MIN_LINESPACING;
            [self setYYLabelLineSpacing:space];
        } break;
            
        default:
            break;
    }
    CGFloat width = label.frame.size.width;
    [label sizeToFit];
    CGRect frame;
    frame.size.width = width;
    frame.size.height = label.final_size.height;
    frame.origin.x = _center.x - frame.size.width*0.5;
    frame.origin.y = _center.y - frame.size.height*0.5;
    self.bgView.frame = frame;
    label.frame = frame;
    
    _oldSliderValue = slider.value;
}

- (void)scaleLabelToPoint:(CGPoint)point {
    
    CGFloat marginX = point.x - _oldPoint.x;
    CGFloat marginY = point.y - _oldPoint.y;
    
    CGFloat beforeWidth = self.lslabel.frame.size.width;
    CGFloat beforeHeight = self.lslabel.frame.size.height;
    CGFloat beforeSize = beforeWidth * beforeHeight;
    CGFloat afterWidth = beforeWidth+marginX;
    CGFloat afterHeight = beforeHeight+marginY;
    CGFloat afterSize = afterWidth * afterHeight;
    
    if (beforeSize != afterSize) {
        BOOL isLarge = NO;
        if (beforeSize > afterSize) {
            isLarge = NO;
        }
        else if (beforeSize < afterSize) {
            isLarge = YES;
        }
        
//        if (self.lslabel.yy_font.pointSize <= MIN_FONTSIZE && !isLarge) {
//            return;
//        }
        
        self.lslabel.frame = CGRectMake(self.view.center.x-afterWidth*0.5, self.view.center.y-afterHeight*0.5, afterWidth, afterHeight);
        
//        self.lslabel.frame = CGRectMake(self.view.center.x-afterWidth*0.5, self.view.center.y-afterHeight*0.5, self.lslabel.frame.size.width, self.lslabel.frame.size.height);
//        self.bgView.frame = self.lslabel.frame;
    }
    _oldPoint = point;
}
- (void)resetLSLabelFrame {
    CGRect final_frame = CGRectMake(self.view.center.x-self.lslabel.final_size.width*0.5, self.view.center.y-self.lslabel.final_size.height*0.5, self.lslabel.final_size.width, self.lslabel.final_size.height);
    NSLog(@"get_final_size: %@", NSStringFromCGSize(self.lslabel.final_size));
    self.lslabel.frame = final_frame;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject preciseLocationInView:self.view];
    
    if (CGPointEqualToPoint(_oldPoint, CGPointZero)) {
        _oldPoint = point;
        return;
    }
    
    [self scaleLabelToPoint:point];
    return;
    
    CGFloat marginX = point.x - _oldPoint.x;
    CGFloat marginY = point.y - _oldPoint.y;
    
    GGLabel *label = self.label;
    
    CGFloat beforeWidth = label.frame.size.width;
    CGFloat beforeHeight = label.frame.size.height;
    CGFloat beforeSize = beforeWidth * beforeHeight;
    CGFloat afterWidth = beforeWidth+marginX;
    CGFloat afterHeight = beforeHeight+marginY;
    CGFloat afterSize = afterWidth * afterHeight;
    
    
    if (beforeSize != afterSize) {
        BOOL isLarge = NO;
        if (beforeSize > afterSize) {
            isLarge = NO;
        }
        else if (beforeSize < afterSize) {
            isLarge = YES;
        }
        
        if (label.attributedText.yy_font.pointSize <= MIN_FONTSIZE && !isLarge) {
            return;
        }
        
        label.frame = CGRectMake(_center.x-afterWidth*0.5, _center.y-afterHeight*0.5, afterWidth, afterHeight);
        self.bgView.frame = label.frame;
        
        [self updateYYLabelWithFontSizeLarge:isLarge];
        label.frame = CGRectMake(_center.x-afterWidth*0.5, _center.y-afterHeight*0.5, label.frame.size.width, label.frame.size.height);
        self.bgView.frame = label.frame;
    }
    _oldPoint = point;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _oldPoint = CGPointZero;
//    [self resetYYLabelFrame];
    
    [self resetLSLabelFrame];
}

- (void)resetYYLabelFrame {
    GGLabel *label = self.label;
    if (CGSizeEqualToSize(label.final_size, CGSizeZero)) {
        [label sizeToFit];
        [self resetYYLabelFrame];
        return;
    }
    CGRect frame = label.frame;
    frame.size.width = label.final_size.width;
    frame.size.height = label.final_size.height;
    frame.origin.x = _center.x - frame.size.width*0.5;
    frame.origin.y = _center.y - frame.size.height*0.5;
    label.frame = frame;
    [UIView animateWithDuration:0.35f animations:^{
        self.bgView.frame = frame;
    }];
}

- (void)updateYYLabelWithFontSizeLarge:(BOOL)isLarge {
    
    GGLabel *label = self.label;
    NSRange range = label.textLayout.visibleRange;
    if (isLarge) {
        while (range.length >= label.attributedText.length) {
            UIFont *font = label.attributedText.yy_font;
            CGFloat size = font.pointSize;
            size++;
            if (size > _begainFont.pointSize) {
                return;
            }
            font = [UIFont fontWithName:font.fontName size:size];
            [self setYYLabelFont:font];
            range = label.textLayout.visibleRange;
            if (range.length < label.attributedText.length) {
                size--;
                font = [UIFont fontWithName:font.fontName size:size];
                [self setYYLabelFont:font];
            }
        }
    }
    else {
        while (range.length < label.attributedText.length) {
            UIFont *font = label.attributedText.yy_font;
            CGFloat size = font.pointSize;
            size--;
            if (size < MIN_FONTSIZE) {
                [label sizeToFit];
                return;
            }
            font = [UIFont fontWithName:font.fontName size:size];
            [self setYYLabelFont:font];
            range = label.textLayout.visibleRange;
        }
    }
}
- (void)setYYLabelLineSpacing:(CGFloat)space {
    GGLabel *label = self.label;
    NSMutableDictionary *attrDic = [NSMutableDictionary dictionaryWithDictionary:label.attributedText.yy_attributes];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:label.text attributes:attrDic];
    [attr yy_setLineSpacing:space range:NSMakeRange(0, label.text.length)];
    label.attributedText = attr;
}
- (void)setYYLabelKern:(NSNumber *)kern {
    GGLabel *label = self.label;
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:label.attributedText.yy_attributes];
    if ([attr objectForKey:NSKernAttributeName]) {
        attr[NSKernAttributeName] = kern;
    }
    label.attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:attr];
}
- (void)setYYLabelFont:(UIFont *)font {
    GGLabel *label = self.label;
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:label.attributedText.yy_attributes];
    if ([attr objectForKey:NSFontAttributeName]) {
        attr[NSFontAttributeName] = font;
    }
    label.attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:attr];
}
@end
