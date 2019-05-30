//
//  LSLabel.m
//  testCoreText
//
//  Created by gg on 2019/5/13.
//  Copyright © 2019 gg. All rights reserved.
//

#import "LSLabel.h"
#import <objc/runtime.h>
#import <CoreText/CoreText.h>

typedef struct GlyphArcInfo {
    CGFloat            width;
    CGFloat            angle;    // in radians
} GlyphArcInfo;

@implementation LSLabel
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
}
//- (instancetype)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        self.opaque = NO;
//        self.arcSize = 1;
//        self.radius = 20;
//        self.frame = frame;
//    }
//    return self;
//}
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributeString);
    
    self.arcSize = 2;
    self.radius = 20;
    
    // 创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 添加路径
    CGPathAddRect(path, NULL, rect);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, self.attributeString.length), path, self.isVerticalForms ? ((__bridge CFDictionaryRef)@{(id)kCTFrameProgressionAttributeName: @(kCTFrameProgressionLeftToRight)}) : NULL);
    
//    CFRange visibleRange = CTFrameGetVisibleStringRange(frameRef);
//    if (visibleRange.length < self.attributeString.length) {
//        goto release;
//    }
    
    [self drawRunFromFrameRef:frameRef context:context];
release:
    NSLog(@"final_size: %@", NSStringFromCGSize(_final_size));
    CFRelease(frameRef);
    CFRelease(path);
    CFRelease(framesetterRef);
}
- (void)drawRunFromFrameRef:(CTFrameRef)frameRef context:(CGContextRef)context {
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
//    CGContextTranslateCTM(context, CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - self.radius);
    CGContextTranslateCTM(context, self.frame.size.width * 0.5, self.frame.size.height*0.5-self.radius);
    
    CGColorRef color = [[self randomColor] CGColor];
    CGRect test = CGRectMake(0, -50.5, 1, 201);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddRect(context,test);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextStrokeRect(context, test);
    
    test = CGRectMake(-50.5, 0, 201, 1);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddRect(context,test);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextStrokeRect(context, test);
    
    CGContextRotateCTM(context, self.arcSize/2.0);
    
    NSUInteger numberOfLines = self.numberOfLines != 0 ? MIN(lineCount, self.numberOfLines) : lineCount;
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, lineCount), lineOrigins);
    
    _final_size = CGSizeMake(0, 1);
    
    for (int i = 0; i < numberOfLines; i++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        CFIndex count = CFArrayGetCount(runs);
        CGFloat ascent, descent, leading;
        double lineWidth = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading) + 1;
        
        CGContextSetTextPosition(context, lineOrigins[i].x, lineOrigins[i].y);
//        NSLog(@"第%d行", i+1);
        
        CGPoint textPosition = lineOrigins[i];
        
        CFIndex glyphCount = CTLineGetGlyphCount(lineRef);
        GlyphArcInfo *    glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
        [self prepareGlyphArcInfo:lineRef glyphCount:glyphCount glyphArcInfo:glyphArcInfo arcSizeRad:self.arcSize];
        CFIndex glyphOffset = 0;
        
        
        CGFloat rotates = 1;
        for (int k = 0; k < count; k++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            CFIndex runCount = CTRunGetGlyphCount(run);
            
            // 画一个 run
            for (int j = 0; j < runCount; j++) {
                
                
                if (j == 0) {
                    CGColorRef color = [[self randomColor] CGColor];
                    CGRect test = CGRectMake(0, -50.5, 1, 201);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddRect(context,test);
                    CGContextSetStrokeColorWithColor(context, color);
                    CGContextStrokeRect(context, test);
                    
                    test = CGRectMake(-50.5, 0, 201, 1);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddRect(context,test);
                    CGContextSetStrokeColorWithColor(context, color);
                    CGContextStrokeRect(context, test);
                }
                
                CFRange glyphRange = CFRangeMake(j, 1);
                CGFloat angle = -(glyphArcInfo[j + glyphOffset].angle);
                CGContextRotateCTM(context, angle);
                
//                CGContextTranslateCTM(context, <#CGFloat tx#>, <#CGFloat ty#>)
                
                CGFloat glyphWidth = glyphArcInfo[j + glyphOffset].width;
                CGFloat halfGlyphWidth = glyphWidth / 2.0;
                CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y*0.1);
                NSLog(@"textPosition: %@", NSStringFromCGPoint(textPosition));
                textPosition.x -= glyphWidth;
                
//                CGPoint movePoint = [self calculatFromPoint:CGPointMake(textPosition.x+halfGlyphWidth, positionForThisGlyph.y) angle:rotates+angle];
                rotates += angle;
                
                CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
                textMatrix.tx = positionForThisGlyph.x - 40;
                textMatrix.ty = positionForThisGlyph.y - 40;
                NSLog(@"textMatrix [%f, %f]", textMatrix.tx, textMatrix.ty);
                CGContextSetTextMatrix(context, textMatrix);
                
                CTRunDraw(run, context, glyphRange);
                
                CGRect lineBounds = CTRunGetImageBounds(run, context, glyphRange);
                CGContextSetLineWidth(context, 1.0);
                CGContextAddRect(context,lineBounds);
                CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
                CGContextStrokeRect(context, lineBounds);
                
                if (j == 0) {
                    CGColorRef color = [[UIColor redColor] CGColor];
                    lineBounds = CGRectMake(0, -50.5, 1, 87+51);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddRect(context,lineBounds);
                    CGContextSetStrokeColorWithColor(context, color);
                    CGContextStrokeRect(context, lineBounds);
                    
                    lineBounds = CGRectMake(-50.5, 0, 201, 1);
                    CGContextSetLineWidth(context, 1.0);
                    CGContextAddRect(context,lineBounds);
                    CGContextSetStrokeColorWithColor(context, color);
                    CGContextStrokeRect(context, lineBounds);
                }
            }
            CGContextRotateCTM(context, -rotates);
            
            CGRect lineBounds = CGRectMake(0, 0, 1, 1);
            CGContextSetLineWidth(context, 1.0);
            CGContextAddRect(context,lineBounds);
            CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
            CGContextStrokeRect(context, lineBounds);
            
            glyphOffset += glyphCount;
        }
        free(glyphArcInfo);

//        if (CGSizeEqualToSize(_final_size, CGSizeMake(0, 1))) {
//            _final_size.height += ascent + descent;
//            _final_size.width = MAX(lineWidth, _final_size.width);
//            if (i != numberOfLines - 1) {
//                _final_size.height += self.paragraphStyle.lineSpacing;
//            }
//        }
    }
}

- (CGPoint)calculatFromPoint:(CGPoint)point angle:(CGFloat)ang {
    CGPoint move = CGPointZero;
    CGFloat angle = fabs(ang);
//    CGFloat originX = point.y * cos(angle);
    CGFloat originY = point.y * cos(M_PI_2 - angle);
    CGFloat finalX = originY * cos(angle);
    CGFloat finalY = originY * sin(angle);
    move.x = fabs(finalX);
    move.y = fabs(finalY);
    return move;
}

- (void)testViewWithFrame:(CGRect)frame {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [self randomColor];
    [self addSubview:view];
}
- (UIColor *)randomColor {
    int R = (arc4random() % 256);
    int G = (arc4random() % 256);
    int B = (arc4random() % 256);
    UIColor *color = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
    return color;
}

- (void)_drawRunFromLine:(CTLineRef)lineRef context:(CGContextRef)context {
    
    
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

- (NSArray <LSFontAttribute *>*)_getObjsWithClass:(Class)clas {
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
    
    for (LSFontAttribute *attr in [self _getObjsWithClass:[LSFontAttribute class]]) {
        [attributeString addAttribute:attr.attributeName value:attr.value range:attr.range];
    }
    
    [attributeString addAttribute:(__bridge NSString *)kCTParagraphStyleAttributeName value:[self getParagraphStyle] range:NSMakeRange(0, attributeString.length)];
    
    [attributeString endEditing];
}
- (void)setFont:(NSArray<LSFontAttribute *> *)font {
    _font = font;
    for (LSFontAttribute *attr in _font) {
        attr.attributeName = (__bridge NSString *)kCTFontAttributeName;
    }
}
- (void)setTextForegroundColor:(NSArray<LSFontAttribute *> *)textForegroundColor {
    _textForegroundColor = textForegroundColor;
    for (LSFontAttribute *attr in _textForegroundColor) {
        attr.attributeName = (__bridge NSString *)kCTForegroundColorAttributeName;
    }
}
- (void)setTextBackgroundColor:(NSArray<LSFontAttribute *> *)textBackgroundColor {
    _textBackgroundColor = textBackgroundColor;
    for (LSFontAttribute *attr in _textBackgroundColor) {
        attr.attributeName = (__bridge NSString *)kCTBackgroundColorAttributeName;
    }
}
- (void)setStrokeWidth:(NSArray<LSFontAttribute *> *)strokeWidth {
    _strokeWidth = strokeWidth;
    for (LSFontAttribute *attr in _strokeWidth) {
        attr.attributeName = (__bridge NSString *)kCTStrokeWidthAttributeName;
    }
}
- (void)setStrokeColor:(NSArray<LSFontAttribute *> *)strokeColor {
    _strokeColor = strokeColor;
    for (LSFontAttribute *attr in _strokeColor) {
        attr.attributeName = (__bridge NSString *)kCTStrokeColorAttributeName;
    }
}
- (void)setUnderLine:(NSArray<LSFontAttribute *> *)underLine {
    _underLine = underLine;
    for (LSFontAttribute *attr in _underLine) {
        attr.attributeName = (__bridge NSString *)kCTUnderlineStyleAttributeName;
    }
}
- (void)setUnderLineColor:(NSArray<LSFontAttribute *> *)underLineColor {
    _underLineColor = underLineColor;
    for (LSFontAttribute *attr in _underLineColor) {
        attr.attributeName = (__bridge NSString *)kCTUnderlineColorAttributeName;
    }
}

- (void)setFontKern:(NSArray<LSFontAttribute *> *)fontKern {
    _fontKern = fontKern;
    for (LSFontAttribute *attr in _fontKern) {
        attr.attributeName = (__bridge NSString *)kCTKernAttributeName;
    }
}
- (void)setStrikethroughStyle:(NSArray<LSFontAttribute *> *)strikethroughStyle {
    _strikethroughStyle = strikethroughStyle;
    for (LSFontAttribute *attr in _strikethroughStyle) {
        attr.attributeName = NSStrikethroughStyleAttributeName;
    }
}
- (void)prepareGlyphArcInfo:(CTLineRef)line glyphCount:(CFIndex)glyphCount glyphArcInfo:(GlyphArcInfo *)glyphArcInfo arcSizeRad:(CGFloat)arcSizeRad {
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
    
    CGFloat ascent, descent, leading;
    
    double lineLength = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    _final_size.height += ascent + descent;
    
    CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
    glyphArcInfo[0].angle = (prevHalfWidth / lineLength) * arcSizeRad;
    
    // Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
    CFIndex lineGlyphIndex = 1;
    CGFloat totalAngle = glyphArcInfo[0].angle;
    for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
        CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
        CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
        
        glyphArcInfo[lineGlyphIndex].angle = (prevCenterToCenter / lineLength) * arcSizeRad;
        NSLog(@"angle: %f, width: %f", glyphArcInfo[lineGlyphIndex].angle, glyphArcInfo[lineGlyphIndex].width);
        
        totalAngle = glyphArcInfo[lineGlyphIndex].angle;
        CGFloat offsetW = glyphArcInfo[lineGlyphIndex].width * cos(totalAngle);
        CGFloat offsetH = glyphArcInfo[lineGlyphIndex].width * sin(totalAngle);
        NSLog(@"offset w [%f], h [%f], width [%f]", offsetW, offsetH, glyphArcInfo[lineGlyphIndex].width);
        _final_size.width += offsetW;
        _final_size.height += offsetH;
        
        prevHalfWidth = halfWidth;
    }
    NSLog(@"%@", NSStringFromCGSize(_final_size));
}
@end
@implementation LSFontAttribute
+ (instancetype)attributeWithValue:(id)value range:(NSRange)range {
    LSFontAttribute *attr = [[self alloc] init];
    attr.value = value;
    attr.range = range;
    return attr;
}
@end
