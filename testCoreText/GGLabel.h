//
//  GGLabel.h
//  testCoreText
//
//  Created by gg on 2019/4/25.
//  Copyright © 2019 gg. All rights reserved.
//

#import "YYLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GGLabel : YYLabel
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat arcSize;

@property (assign, nonatomic, readonly) CGSize final_size;
@end

NS_ASSUME_NONNULL_END
