//
//  GGLabel.m
//  testCoreText
//
//  Created by gg on 2019/4/25.
//  Copyright © 2019 gg. All rights reserved.
//

#import "GGLabel.h"
#import <AssertMacros.h>
#import <QuartzCore/QuartzCore.h>
#import <YYText/YYTextAsyncLayer.h>

#define ARCVIEW_DEBUG_MODE YES

@interface GGLabel () <YYTextAsyncLayerDelegate>

@end

@implementation GGLabel {
    CGFloat _arcSize;
    CGFloat _frame;
    CGSize _final_size;
}

typedef struct GlyphArcInfo {
    CGFloat            width;
    CGFloat            angle;    // in radians
} GlyphArcInfo;

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
    
    _final_size.height += ascent + descent + leading;
    
    CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
    glyphArcInfo[0].angle = (prevHalfWidth / lineLength) * arcSizeRad;
    
    // Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
    CFIndex lineGlyphIndex = 1;
    for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
        CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
        CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
        
        glyphArcInfo[lineGlyphIndex].angle = (prevCenterToCenter / lineLength) * arcSizeRad;
        NSLog(@"angle: %f, width: %f", glyphArcInfo[lineGlyphIndex].angle, glyphArcInfo[lineGlyphIndex].width);
        
        CGFloat offsetW = glyphArcInfo[lineGlyphIndex].width * cos(glyphArcInfo[lineGlyphIndex].angle);
        CGFloat offsetH = glyphArcInfo[lineGlyphIndex].width * sin(glyphArcInfo[lineGlyphIndex].angle);
        _final_size.width += offsetW;
        _final_size.height += offsetH;
        
        prevHalfWidth = halfWidth;
    }
    NSLog(@"%@", NSStringFromCGSize(_final_size));
}
- (CGSize)final_size {
    if (CGSizeEqualToSize(CGSizeZero, _final_size)) {
        return self.textLayout.textBoundingSize;
    }
    else {
        return _final_size;
    }
}
- (YYTextAsyncLayerDisplayTask *)newAsyncDisplayTask {
    YYTextAsyncLayerDisplayTask *task = [[YYTextAsyncLayerDisplayTask alloc] init];
    __block CGContextRef contextRef;
    __block CGRect frame;
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        
        [self drawRotateLabelWithFrame:frame context:contextRef];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        layer.contents = (__bridge id _Nullable)(image.CGImage);
    };
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void)) {
        contextRef = context;
        frame.size = size;
        frame.origin = CGPointZero;
    };
    return task;
}

- (void)_setLayoutNeedRedraw {
    [self.layer setNeedsDisplay];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.delegate = self;
    }
    return self;
}

//set arc size in degrees (180 = half circle)
-(void)setArcSize:(CGFloat)degrees{
    _arcSize = degrees * M_PI/180.0;
}

//get arc size in degrees
-(CGFloat)arcSize{
    return _arcSize * 180.0/M_PI;
}

- (BOOL)drawRotateLabelWithFrame:(CGRect)frame context:(CGContextRef)context {
    
    if (context == NULL) {
        return NO;
    }
    
    self.arcSize = 1;
    _radius = 20;
    
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    
    CGContextTranslateCTM(context, CGRectGetMidX(frame), CGRectGetMidY(frame) - self.radius);
    CGContextRotateCTM(context, self.arcSize/2.0);
    
    _final_size = CGSizeZero;
    
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    // 添加路径
    CGPathAddRect(path, NULL, frame);
    CTFrameRef ctframe = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, self.attributedText.length), path, NULL);
    
    
    
    CFArrayRef frames = CTFrameGetLines(ctframe);
    CFIndex lineCount = CFArrayGetCount(frames);
    
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctframe, CFRangeMake(0, lineCount), lineOrigins);
    
    for (int l = 0; l < lineCount; l++) {
//        CTLineRef lineRef = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
        CTLineRef lineRef = CFArrayGetValueAtIndex(frames, l);
        if (lineRef == NULL) {
            continue;
        }
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        CFIndex count = CFArrayGetCount(runs);
        
//        CGPoint textPosition = CGPointMake(0.0, self.radius);
        CGPoint textPosition = lineOrigins[l];
        CGContextSetTextPosition(context, lineOrigins[l].x, lineOrigins[l].y);
        
        CFIndex glyphCount = CTLineGetGlyphCount(lineRef);
        GlyphArcInfo *    glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
        [self prepareGlyphArcInfo:lineRef glyphCount:glyphCount glyphArcInfo:glyphArcInfo arcSizeRad:self.arcSize];
        
        CFIndex glyphOffset = 0;
        for (int i = 0; i < count; i++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            CGFloat rotates = 0;
            for (int j = 0; j < glyphCount; j++) {
                
                CFRange glyphRange = CFRangeMake(j, 1);
                CGFloat angle = -(glyphArcInfo[j + glyphOffset].angle);
                rotates += angle;
                CGContextRotateCTM(context, angle);
                
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
            CGContextRotateCTM(context, -rotates);
            glyphOffset += glyphCount;
        }
        free(glyphArcInfo);
        CGRect rect = CTLineGetImageBounds(lineRef, context);
        NSLog(@"%@", NSStringFromCGRect(rect));
        CFRelease(lineRef);
    }
    
    
    return YES;
}
@end
