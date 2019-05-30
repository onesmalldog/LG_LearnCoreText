//
//  NSMutableAttributedString+FrameRef.m
//  testCoreText
//
//  Created by gg on 2019/4/3.
//  Copyright © 2019 gg. All rights reserved.
//

#import "NSMutableAttributedString+FrameRef.h"

@implementation NSMutableAttributedString (FrameRef)
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect
{
    // 获取framesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    // 获取frameRef
    CTFrameRef frameRef = [self prepareFrameRefWithRect:rect framesetterRef:framesetterRef];
    
    // 释放framesetterRef
    CFRelease(framesetterRef);
    
    return frameRef;
}
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect
                       framesetterRef:(CTFramesetterRef)framesetterRef
{
    // 创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 添加路径
    CGPathAddRect(path, NULL, rect);
    
    // 获取frameRef
    // CFRangeMake(0,0) 表示绘制全部文字
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), path, (CFDictionaryRef)@{(id)kCTFrameProgressionAttributeName: @(kCTFrameProgressionLeftToRight)});
    
    // 释放内存
    CFRelease(path);
    
    return frameRef;
}
@end
