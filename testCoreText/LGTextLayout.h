//
//  LGTextLayout.h
//  testCoreText
//
//  Created by gg on 2019/4/23.
//  Copyright © 2019 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGTextLayout : NSObject
@property (assign, nonatomic) BOOL isVerticalForms;
@property (assign, nonatomic) NSInteger numberOfLines;

@property (strong, nonatomic) NSMutableAttributedString *attributeString;

@property (assign, nonatomic) CGSize final_size;

- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect fromAttributedString:(NSMutableAttributedString *)attrStr;
- (void)drawRunFromFrameRef:(CTFrameRef)frameRef context:(CGContextRef)context;
- (CGSize)getRealLineFromLineSpace:(CGFloat)lineSpace;
@end

NS_ASSUME_NONNULL_END
