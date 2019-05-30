//
//  LGTextLayout.m
//  testCoreText
//
//  Created by gg on 2019/4/23.
//  Copyright © 2019 gg. All rights reserved.
//

#import "LGTextLayout.h"
@interface LGTextLayout ()
@property (assign, nonatomic) CGRect rect;
@end
@implementation LGTextLayout

- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect fromAttributedString:(NSMutableAttributedString *)attrStr {
    
    self.rect = rect;
    self.attributeString = attrStr;
    // 获取framesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    // 创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 添加路径
    CGPathAddRect(path, NULL, rect);
    
//    UIBezierPath *bpath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 200, 400) cornerRadius:50];
//    UIBezierPath *bpath = [UIBezierPath bezierPath];
//    [bpath moveToPoint:CGPointMake(0, 0)];
//    [bpath addQuadCurveToPoint:CGPointMake(rect.size.width, 0) controlPoint:CGPointMake(rect.size.width * 0.5, rect.size.height*0.5)];
//    CGPathRef path = bpath.CGPath;
    
    // 获取frameRef
    // CFRangeMake(0,0) 表示绘制全部文字
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, attrStr.length), path, self.isVerticalForms ? ((__bridge CFDictionaryRef)@{(id)kCTFrameProgressionAttributeName: @(kCTFrameProgressionLeftToRight)}) : NULL);
    
    // 释放内存
    CFRelease(path);
    
    // 释放framesetterRef
    CFRelease(framesetterRef);
    
    return frameRef;
}
#pragma mark Tools
- (CGSize)getRealLineFromLineSpace:(CGFloat)lineSpace {
    if (!self.attributeString) {
        return CGSizeZero;
    }
    CTFrameRef frame = [self prepareFrameRefWithRect:self.rect fromAttributedString:self.attributeString];
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger textRealLine = CFArrayGetCount(lines); //we should always set textRealLine before we user self.numberOfLines
    CGFloat textHeight = 0;
    CGFloat textWidth = 0;
    CGFloat lineAscent, lineDescent, lineLeading;
    NSUInteger numberOfLines = self.numberOfLines != 0 ? MIN(textRealLine, self.numberOfLines) : textRealLine;
    for (int i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat height = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        if (textHeight < height) {
            textHeight = height;
        }
        /**根据苹果官方说法https://developer.apple.com/library/mac/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TypoFeatures/TextSystemFeatures.html#//apple_ref/doc/uid/TP40009459-CH6-BBCFAEGE
         *大部分文字的显示区域应该是处于lineAscent 但是根据我debug得到的数据lineDescent正好是一个汉字的宽度 lineAscent跟lineDescent有关 具体关系不清楚
         *所以我有理由相信竖向显示汉字的区域处于lineDescent，但是行高的计算还是需要加上lineAscent 尽管貌似lineAscent区域没有绘制，或者lineAscent区域只绘制英文？
         *再有lineLeading,根据http://geeklu.com/2013/03/core-text/ 这篇博客说lineLeading就是行间距，但是只是在竖向显示时，这个lineLeading一直是0，所以我们需要额外加上行间距
         **/
        textWidth = textWidth + lineDescent + lineAscent + lineLeading + lineSpace;
        textHeight += textHeight;
    }
    CFRelease(frame);
    CGSize size = CGSizeMake(textWidth, textHeight);
    NSLog(@"___text size[%@], real line[%ld]", NSStringFromCGSize(size), (long)textRealLine);
    return size;
}
- (BOOL)isChinese:(NSString *)s index:(int)index {
    NSString *subString = [s substringWithRange:NSMakeRange(index, 1)];
    const char *cString = [subString UTF8String];
    return strlen(cString) == 3;
}

- (void)_fillBackgroundColorWithRun:(CTRunRef)run attributes:(NSDictionary *)attributes context:(CGContextRef)context {
    UIColor *backgroundColor = attributes[(__bridge NSString *)kCTBackgroundColorAttributeName];
    if (!backgroundColor) {
        return;
    }
    
    // 获取画线的起点
    CGPoint origin = [self _getRunOrigin:run];
    
    CGFloat ascent, descent, leading;
    CGFloat typographicWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
    
    CGPoint pt = CGContextGetTextPosition(context);
    
    // 需要填充颜色的区域
    CGRect rect = CGRectMake(origin.x + pt.x, origin.y + pt.y - descent, typographicWidth, ascent + descent);
    
    const CGFloat *components = CGColorGetComponents(backgroundColor.CGColor);
    NSLog(@"[%f, %f, %f]", components[0], components[1], components[2]);
    CGContextSetRGBFillColor(context, components[0], components[1], components[2], components[3]);
    CGContextFillRect(context, rect);
}
- (CGPoint)_getRunOrigin:(CTRunRef)run {
    CGPoint firstPosition;
    const CGPoint *firstGlyphPosition = CTRunGetPositionsPtr(run);
    if (!firstGlyphPosition) {
        CGPoint positions;
        CTRunGetPositions(run, CFRangeMake(0, 0), &positions);
        firstPosition = positions;
    }
    else {
        firstPosition = *firstGlyphPosition;
    }
    return firstPosition;
}
- (void)_drawStrikethroughStyleWithRun:(CTRunRef)run attributes:(NSDictionary *)attributes context:(CGContextRef)context {
    
    // 1.获取删除线样式
    NSNumber *strikethrough = attributes[NSStrikethroughStyleAttributeName];
    NSUnderlineStyle style = strikethrough.integerValue;
    if (style == NSUnderlineStyleNone) {
        return;
    }
    
    // 2.获得画线的宽度
    CGFloat lineWidth = 1;
    if ((style & NSUnderlineStyleThick) == NSUnderlineStyleThick) {
        lineWidth *= 2;
    }
    
    // 3.获取画线的起点
    CGContextSetLineWidth(context, lineWidth);
    CGPoint firstPosition = [self _getRunOrigin:run];
    
    CGContextBeginPath(context);
    
    // 5.获取定义的线的颜色, 默认为黑色
    UIColor *lineColor = attributes[NSStrikethroughColorAttributeName];
    if (!lineColor) {
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    }
    
    // 6.字体高度, 中间位置为x高度的一半
    UIFont *font = attributes[NSFontAttributeName];
    if (!font) {
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    CGFloat strikeHeight = font.xHeight / 2.0 + firstPosition.y;
    
    // 多行调整
    CGPoint pt = CGContextGetTextPosition(context);
    strikeHeight += pt.y;
    
    // 画线的宽度
    CGFloat typographicWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), nil, nil, nil);
    CGContextMoveToPoint(context, pt.x + firstPosition.x, strikeHeight);
    CGContextAddLineToPoint(context, pt.x + firstPosition.x + typographicWidth, strikeHeight);
    
    CGContextStrokePath(context);
}
#pragma mark Draw Run
- (void)drawRunFromFrameRef:(CTFrameRef)frameRef context:(CGContextRef)context {
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    NSUInteger numberOfLines = self.numberOfLines != 0 ? MIN(lineCount, self.numberOfLines) : lineCount;
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, lineCount), lineOrigins);
    
    _final_size = CGSizeZero;
    
    for (int i = 0; i < numberOfLines; i++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        lineOrigins[i].y = self.rect.size.height - lineOrigins[i].y;
        CGContextSetTextPosition(context, lineOrigins[i].x, lineOrigins[i].y);
        NSLog(@"第%d行", i+1);
        
        CGFloat ascent, descent, leading;
        double lineWidth = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        _final_size.width = MAX(lineWidth, _final_size.width);
        _final_size.height += ascent + descent + leading;
        
        [self _drawRunFromLine:lineRef context:context];
    }
}

- (void)_drawRunFromLine:(CTLineRef)lineRef context:(CGContextRef)context {
    
    CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
    CFIndex count = CFArrayGetCount(runs);
    
    for (int i = 0; i < count; i++) {
        NSLog(@"第%d个run", i+1);
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        
        NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes(run);
        NSLog(@"attributes: \n%@", attributes);
        
        // 背景色
        if (attributes[(__bridge NSString *)kCTBackgroundColorAttributeName]) {
            [self _fillBackgroundColorWithRun:run attributes:attributes context:context];
        }
        
        
        
        // 画一个 run
        CTRunDraw(run, context, CFRangeMake(0, 0));
        
        // 删除线
        if (attributes[NSStrikethroughStyleAttributeName] != NULL) {
            [self _drawStrikethroughStyleWithRun:run attributes:attributes context:context];
        }
    }
}
#pragma mark Draw line
- (void)drawLineFromFrameRef:(CTFrameRef)frameRef {
    if (!frameRef) {
        return;
    }
    // 1.计算当前需要绘制文字的行数
    // 1.1获取lineRef的数组
    CFArrayRef lines = CTFrameGetLines(frameRef);
    // 1.2获取lineRef的个数
    CFIndex lineCount = CFArrayGetCount(lines);
    // 1.3计算需要展示的行数
    NSUInteger numberOfLines = self.numberOfLines != 0 ? MIN(lineCount, self.numberOfLines) : lineCount;
    
    //  2.获取每一行的起始位置数组
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, numberOfLines), lineOrigins);
    
    // 3.遍历需要显示文字的行数，并绘制每一行的现实内容
    for (CFIndex idx = 0; idx < numberOfLines; idx ++) {
        // 3.0获取图形上下文和每一行对应的lineRef
        CGContextRef context = UIGraphicsGetCurrentContext();
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, idx);
        
        // 3.1设置文本的起始绘制位置
        CGContextSetTextPosition(context, lineOrigins[idx].x, lineOrigins[idx].y);
        
        // 3.2设置是否需要完整绘制一行文字的标记
        BOOL shouldDrawLine = YES;
        
        // 3.3处理最后一行
        if (idx == numberOfLines - 1 && self.numberOfLines != 0) {
            // 3.3.1.处理最后一行的文字绘制
//            [self drawLastLineWithLineRef:lineRef];
            
            // 3.3.2标记不用完整的去绘制一行文字
            shouldDrawLine = NO;
        }
        
        // 3.4绘制完整的一行文字
        if (shouldDrawLine) {
            CTLineDraw(lineRef, context);
        }
    }
}
//- (void)drawLastLineWithLineRef:(CTLineRef)lineRef {
//    // 1.获取当前行在文本中的范围
//    CFRange lastLineRange = CTLineGetStringRange(lineRef);
//    // 2.比较最后显示行的最后一个文字的长度和文本的总长度
//    // -> 最后一个文字的长度 < 文本的总长度
//    // -> 用户设置了限制文本长度，单独处理最后一个的最后一个字符即可
//    if (lastLineRange.location + lastLineRange.length < (CFIndex)self.attributeString.length) {
//        // 2.1获取最后一行的属性字符串
//        NSMutableAttributedString *truncationString = [[self.attributeString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
//
//        if (lastLineRange.length > 0) {
//            // 2.2获取最后一个字符
//            unichar lastCharacter = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
//
//            // 2.3判断Unicode字符集是否包含lastCharacter
//            if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastCharacter]) {
//                // 2.4.1安全的删除truncationString中最后一个字符
//                [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
//            }
//        }
//
//        // 2.5获取截断属性的位置
//        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
//
//        // 2.6获取需要截断的属性
//        NSDictionary *tokenAttributes = [self.attributeString attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
//
//        //  2.7初始化一个带属性字符串 -> “...”
//        static NSString* const kEllipsesCharacter = @"\u2026";
//        NSMutableAttributedString *tokenString = [[NSMutableAttributedString alloc] initWithString:kEllipsesCharacter attributes:tokenAttributes];
//
//        // 2.8把“...”添加到最后一行尾部
//        [truncationString appendAttributedString:tokenString];
//
//        // 2.9处理最后一行的lineRef
//        CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
//        CTLineTruncationType truncationType = kCTLineTruncationEnd;
//
//        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenString);
//
//        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, self.frame.size.width, truncationType, truncationToken);
//
//        if (!truncatedLine) {
//            truncatedLine = CFRetain(truncationToken);
//        }
//        CFRelease(truncationLine);
//        CFRelease(truncationToken);
//
//        // 绘制本行文字
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CTLineDraw(truncatedLine, context);
//        CFRelease(truncatedLine);
//    }
//}
@end
