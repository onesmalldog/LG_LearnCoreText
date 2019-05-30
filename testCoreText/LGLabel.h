//
//  LGLabel.h
//  testCoreText
//
//  Created by gg on 2019/4/3.
//  Copyright © 2019 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGTextLayout.h"

NS_ASSUME_NONNULL_BEGIN
@interface LGFontAttribute : NSObject
@property ( copy , nonatomic) NSString *attributeName;
@property (assign, nonatomic) NSRange range;
@property (strong, nonatomic) id value;

+ (instancetype)attributeWithValue:(id)value range:(NSRange)range;
@end


@interface LGLabel : UIView

#pragma mark ===================== Setter =====================
// ===================== Setter =====================
/**
 是否竖向布局
 */
@property (assign, nonatomic) BOOL isVerticalForms;

/**
 /// ****************
         段落格式
 /// ****************
 */
@property (strong, nonatomic) NSParagraphStyle *paragraphStyle;

/**
 行间距
 */
@property (assign, nonatomic) CGFloat lineSpacing;

/**
 段间距
 */
@property (assign, nonatomic) CGFloat paragraphSpacing;

@property (assign, nonatomic) NSTextAlignment alignment;

@property (assign, nonatomic) NSLineBreakMode lineBreakMode;

@property (assign, nonatomic) NSUInteger numberOfLines;


/**
 /// **********************
        Attribute String
 /// **********************
 */
@property (strong, nonatomic) NSMutableAttributedString *attributeString;

@property ( copy , nonatomic) NSString *text;

/**
 文字颜色
 UIColor
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*textForegroundColor;

/**
 文字背景色
 UIColor
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*textBackgroundColor;

/**
 字体字号
 UIFont
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*font;

/**
 删除线宽度
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*strikethroughStyle;

/**
 空心字宽度
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*strokeWidth;

/**
 空心字颜色
 UIColor
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*strokeColor;

/**
 下划线
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*underLine;

/**
 下划线颜色
 UIColor
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*underLineColor;

/**
 字间距
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LGFontAttribute *>*fontKern;

#pragma mark ===================== Getter =====================
/**
    ===================== Getter =====================
 */
@property (assign, nonatomic, readonly) NSRange visibleRange;

@property (strong, nonatomic, readonly) UIFont *yy_font;

@property (strong, nonatomic, readonly) NSNumber *yy_kern;

@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat arcSize;

@property (strong, nonatomic) LGTextLayout *layout;
@end

NS_ASSUME_NONNULL_END
