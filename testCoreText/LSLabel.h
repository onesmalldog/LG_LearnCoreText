//
//  LSLabel.h
//  testCoreText
//
//  Created by gg on 2019/5/13.
//  Copyright © 2019 gg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LSFontAttribute : NSObject
@property ( copy , nonatomic) NSString *attributeName;
@property (assign, nonatomic) NSRange range;
@property (strong, nonatomic) id value;

+ (instancetype)attributeWithValue:(id)value range:(NSRange)range;
@end


@interface LSLabel : UIView

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
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*textForegroundColor;

/**
 文字背景色
 UIColor
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*textBackgroundColor;

/**
 字体字号
 UIFont
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*font;

/**
 删除线宽度
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*strikethroughStyle;

/**
 空心字宽度
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*strokeWidth;

/**
 空心字颜色
 UIColor
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*strokeColor;

/**
 下划线
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*underLine;

/**
 下划线颜色
 UIColor
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*underLineColor;

/**
 字间距
 NSNumber
 */
@property ( copy , nonatomic) NSArray <LSFontAttribute *>*fontKern;

#pragma mark ===================== Getter =====================
/**
 ===================== Getter =====================
 */
@property (assign, nonatomic, readonly) NSRange visibleRange;

@property (strong, nonatomic, readonly) UIFont *yy_font;

@property (strong, nonatomic, readonly) NSNumber *yy_kern;

@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat arcSize;

@property (assign, nonatomic) CGSize final_size;
@property (assign, nonatomic) CGRect final_rect;
@end

NS_ASSUME_NONNULL_END
