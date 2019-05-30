//
//  LGLabel.m
//  testCoreText
//
//  Created by gg on 2019/4/3.
//  Copyright © 2019 gg. All rights reserved.
//

#import "LGLabel.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

#define ARCVIEW_DEBUG_MODE YES

@interface LGLabel ()
@property (assign, nonatomic) CTFrameRef frameRef;
@end

@implementation LGLabel{
    CGFloat             _arcSize;
}

typedef struct GlyphArcInfo {
    CGFloat            width;
    CGFloat            angle;    // in radians
} GlyphArcInfo;

static void PrepareGlyphArcInfo(CTLineRef line, CFIndex glyphCount, GlyphArcInfo *glyphArcInfo, CGFloat arcSizeRad) {
    NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);
    
    // Examine each run in the line, updating glyphOffset to track how far along the run is in terms of glyphCount.
    CFIndex glyphOffset = 0;
    for (id run in runArray) {
        CFIndex runGlyphCount = CTRunGetGlyphCount((__bridge CTRunRef)run);
        
        // Ask for the width of each glyph in turn.
        CFIndex runGlyphIndex = 0;
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            glyphArcInfo[runGlyphIndex + glyphOffset].width = CTRunGetTypographicBounds((__bridge CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
        }
        
        glyphOffset += runGlyphCount;
    }
    
    double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
    
    CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
    glyphArcInfo[0].angle = (prevHalfWidth / lineLength) * arcSizeRad;
    
    // Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
    CFIndex lineGlyphIndex = 1;
    for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
        CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
        CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
        
        glyphArcInfo[lineGlyphIndex].angle = (prevCenterToCenter / lineLength) * arcSizeRad;
        
        prevHalfWidth = halfWidth;
    }
}
//set arc size in degrees (180 = half circle)
-(void)setArcSize:(CGFloat)degrees{
    _arcSize = degrees * M_PI/180.0;
}

//get arc size in degrees
-(CGFloat)arcSize{
    return _arcSize * 180.0/M_PI;
}

- (LGTextLayout *)layout {
    if (!_layout) {
        _layout = [[LGTextLayout alloc] init];
        _layout.numberOfLines = self.numberOfLines;
        _layout.isVerticalForms = self.isVerticalForms;
    }
    return _layout;
}
- (NSRange)visibleRange {
    CFRange range = CTFrameGetVisibleStringRange(self.frameRef);
    NSRange res = NSMakeRange(range.location, range.length);
    return res;
}
- (UIFont *)yy_font {
    LGFontAttribute *attr = self.font.firstObject;
    return attr.value;
}
- (NSNumber *)yy_kern {
    LGFontAttribute *attr = self.fontKern.firstObject;
    return attr.value;
}

- (void)drawRect:(CGRect)rect {
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    self.frameRef = [self.layout prepareFrameRefWithRect:rect fromAttributedString:self.attributeString];
//
    [self.layout drawRunFromFrameRef:self.frameRef context:context];
    return;

    self.arcSize = 120;
    self.radius = 120.0;
    CGContextTranslateCTM(context, CGRectGetMidX(rect), CGRectGetMidY(rect) - self.radius / 2.0);
    
    CGContextRotateCTM(context, _arcSize/2.0);
    
    CTLineRef lineRef = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributeString);
    
    CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
    CFIndex count = CFArrayGetCount(runs);
    
    
    CGPoint textPosition = CGPointMake(0.0, self.radius);
    CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    CFIndex glyphCount = CTLineGetGlyphCount(lineRef);
    GlyphArcInfo *    glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
    PrepareGlyphArcInfo(lineRef, glyphCount, glyphArcInfo, _arcSize);
    
    CFIndex glyphOffset = 0;
    for (int i = 0; i < count; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        for (int j = 0; j < glyphCount; j++) {
            
            CFRange glyphRange = CFRangeMake(j, 1);
            CGContextRotateCTM(context, -(glyphArcInfo[j + glyphOffset].angle));
            
            CGFloat glyphWidth = glyphArcInfo[j + glyphOffset].width;
            CGFloat halfGlyphWidth = glyphWidth / 2.0;
            CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y);
            
            
            textPosition.x -= glyphWidth;
            
            CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
            textMatrix.tx = positionForThisGlyph.x;
            textMatrix.ty = positionForThisGlyph.y;
            CGContextSetTextMatrix(context, textMatrix);
            
            CTRunDraw(run, context, glyphRange);
        }
        glyphOffset += glyphCount;
    }
    free(glyphArcInfo);
    CFRelease(lineRef);
}
- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        CGImageRef image = (__bridge_retained CGImageRef)self.layer.contents;
        if (image != NULL && image) {
            CFRelease(image);
            [self.layer setNeedsDisplay];
        }
    }
    [self.layout getRealLineFromLineSpace:self.lineSpacing];
}
- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    self.layout.numberOfLines = numberOfLines;
}

- (NSParagraphStyle *)getParagraphStyle {
    if (!_paragraphStyle) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = self.lineSpacing ? self.lineSpacing : 1;
        paragraphStyle.paragraphSpacing = self.paragraphSpacing ? self.paragraphSpacing : 5;
        paragraphStyle.alignment = self.alignment ? self.alignment : NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = self.lineBreakMode ? self.lineBreakMode : NSLineBreakByWordWrapping | NSLineBreakByCharWrapping;
        _paragraphStyle = paragraphStyle;
    }
    return _paragraphStyle;
}

- (void)setIsVerticalForms:(BOOL)isVerticalForms {
    _isVerticalForms = isVerticalForms;
    self.layout.isVerticalForms = _isVerticalForms;
    self.numberOfLines = 0;
    [self.attributeString addAttribute:(__bridge NSString *)kCTVerticalFormsAttributeName value:_isVerticalForms ? @YES : @NO range:NSMakeRange(0, self.attributeString.length)];
}

- (NSMutableAttributedString *)attributeString {
    if (!_attributeString) {
        // 绘制的内容属性字符串
        _attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
        
        [self _setCustomAttributeString:_attributeString];
        
        [self setNeedsDisplay];
        
    }
    return _attributeString;
}

- (NSArray <LGFontAttribute *>*)_getObjsWithClass:(Class)clas {
    NSMutableArray *res = [NSMutableArray array];
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = *(ivars + i);
        const char *c_cls = ivar_getTypeEncoding(ivar);
        NSString *str_cls = [[[NSString stringWithUTF8String:c_cls] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""];
        if ([str_cls isEqualToString:NSStringFromClass([NSArray class])]) {
            const char *c_name = ivar_getName(ivar);
            NSString *str_name = [NSString stringWithCString:c_name encoding:NSUTF8StringEncoding];
            NSArray *array = [self valueForKeyPath:str_name];
            
            if ([NSStringFromClass([array.firstObject class]) isEqualToString:NSStringFromClass(clas)]) {
                [res addObjectsFromArray:array];
            }
        }
    }
    
    return res;
}

- (void)_setCustomAttributeString:(NSMutableAttributedString *)attributeString {
    
    [attributeString beginEditing];
    
    for (LGFontAttribute *attr in [self _getObjsWithClass:[LGFontAttribute class]]) {
        [attributeString addAttribute:attr.attributeName value:attr.value range:attr.range];
    }
    
    [attributeString addAttribute:(__bridge NSString *)kCTParagraphStyleAttributeName value:[self getParagraphStyle] range:NSMakeRange(0, attributeString.length)];
    
    [attributeString endEditing];
    
    /*
     long number = 1;
     CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
     [mabstring addAttribute:(id)kCTCharacterShapeAttributeName value:(id)num range:NSMakeRange(0, 4)];
     */
    /*
     //设置字体属性
     CTFontRef font = CTFontCreateWithName(CFSTR("Georgia"), 40, NULL);
     [mabstring addAttribute:(id)kCTFontAttributeName value:(id)font range:NSMakeRange(0, 4)];
     */
    
     //设置字体简隔 eg:test
//     long number = 30;
//     CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
//    [attributeString addAttribute:(id)kCTKernAttributeName value:@(number) range:NSMakeRange(10, 4)];
    
    
    /*
     long number = 1;
     CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
     [mabstring addAttribute:(id)kCTLigatureAttributeName value:(id)num range:NSMakeRange(0, [str length])];
     */
    /*
     //设置字体颜色
     [mabstring addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:NSMakeRange(0, 9)];
     */
    /*
     //设置字体颜色为前影色
     CFBooleanRef flag = kCFBooleanTrue;
     [mabstring addAttribute:(id)kCTForegroundColorFromContextAttributeName value:(id)flag range:NSMakeRange(5, 10)];
     */
    
    /*
     //设置空心字
     long number = 2;
     CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
     [mabstring addAttribute:(id)kCTStrokeWidthAttributeName value:(id)num range:NSMakeRange(0, [str length])];
     
     //设置空心字颜色
     [mabstring addAttribute:(id)kCTStrokeColorAttributeName value:(id)[UIColor greenColor].CGColor range:NSMakeRange(0, [str length])];
     */
    
    /*
     long number = 1;
     CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
     [mabstring addAttribute:(id)kCTSuperscriptAttributeName value:(id)num range:NSMakeRange(3, 1)];
     */
    
    /*
     //设置斜体字
     CTFontRef font = CTFontCreateWithName((CFStringRef)[UIFont italicSystemFontOfSize:20].fontName, 14, NULL);
     [mabstring addAttribute:(id)kCTFontAttributeName value:(id)font range:NSMakeRange(0, 4)];
     */
    
    /*
     //下划线
     [mabstring addAttribute:(id)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble] range:NSMakeRange(0, 4)];
     //下划线颜色
     [mabstring addAttribute:(id)kCTUnderlineColorAttributeName value:(id)[UIColor redColor].CGColor range:NSMakeRange(0, 4)];
     */
}
- (void)setFont:(NSArray<LGFontAttribute *> *)font {
    _font = font;
    for (LGFontAttribute *attr in _font) {
        attr.attributeName = (__bridge NSString *)kCTFontAttributeName;
    }
}
- (void)setTextForegroundColor:(NSArray<LGFontAttribute *> *)textForegroundColor {
    _textForegroundColor = textForegroundColor;
    for (LGFontAttribute *attr in _textForegroundColor) {
        attr.attributeName = (__bridge NSString *)kCTForegroundColorAttributeName;
    }
}
- (void)setTextBackgroundColor:(NSArray<LGFontAttribute *> *)textBackgroundColor {
    _textBackgroundColor = textBackgroundColor;
    for (LGFontAttribute *attr in _textBackgroundColor) {
        attr.attributeName = (__bridge NSString *)kCTBackgroundColorAttributeName;
    }
}
- (void)setStrokeWidth:(NSArray<LGFontAttribute *> *)strokeWidth {
    _strokeWidth = strokeWidth;
    for (LGFontAttribute *attr in _strokeWidth) {
        attr.attributeName = (__bridge NSString *)kCTStrokeWidthAttributeName;
    }
}
- (void)setStrokeColor:(NSArray<LGFontAttribute *> *)strokeColor {
    _strokeColor = strokeColor;
    for (LGFontAttribute *attr in _strokeColor) {
        attr.attributeName = (__bridge NSString *)kCTStrokeColorAttributeName;
    }
}
- (void)setUnderLine:(NSArray<LGFontAttribute *> *)underLine {
    _underLine = underLine;
    for (LGFontAttribute *attr in _underLine) {
        attr.attributeName = (__bridge NSString *)kCTUnderlineStyleAttributeName;
    }
}
- (void)setUnderLineColor:(NSArray<LGFontAttribute *> *)underLineColor {
    _underLineColor = underLineColor;
    for (LGFontAttribute *attr in _underLineColor) {
        attr.attributeName = (__bridge NSString *)kCTUnderlineColorAttributeName;
    }
}

- (void)setFontKern:(NSArray<LGFontAttribute *> *)fontKern {
    _fontKern = fontKern;
    for (LGFontAttribute *attr in _fontKern) {
        attr.attributeName = (__bridge NSString *)kCTKernAttributeName;
    }
}
- (void)setStrikethroughStyle:(NSArray<LGFontAttribute *> *)strikethroughStyle {
    _strikethroughStyle = strikethroughStyle;
    for (LGFontAttribute *attr in _strikethroughStyle) {
        attr.attributeName = NSStrikethroughStyleAttributeName;
    }
}
//- (void)setVerticalForms:(NSArray<LGFontAttribute *> *)verticalForms {
//    _verticalForms = verticalForms;
//    for (LGFontAttribute *attr in _verticalForms) {
//        attr.attributeName = (__bridge NSString *)kCTVerticalFormsAttributeName;
//        self.layout.isVerticalForms = ((NSNumber *)attr.value).boolValue;
//    }
//}
@end

@implementation LGFontAttribute
+ (instancetype)attributeWithValue:(id)value range:(NSRange)range {
    LGFontAttribute *attr = [[self alloc] init];
    attr.value = value;
    attr.range = range;
    return attr;
}
@end
