//
//  NSMutableAttributedString+FrameRef.h
//  testCoreText
//
//  Created by gg on 2019/4/3.
//  Copyright © 2019 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (FrameRef)
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect;
@end

NS_ASSUME_NONNULL_END
