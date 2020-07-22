//
//  UIButton+Edge.h
//  YangNiuProject
//
//  Created by yuanzhou on 2017/10/31.
//  Copyright © 2017年 yuanzhou. All rights reserved.
//

#import "UIButton+Edge.h"
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define SS_SINGLELINE_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define SS_SINGLELINE_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif
@implementation UIButton (Edge)

- (void)setImagePositionWithType:(QMImagePositionType)type spacing:(CGFloat)spacing {
    CGSize imageSize = [self imageForState:UIControlStateNormal].size;
    CGSize titleSize = SS_SINGLELINE_TEXTSIZE([self titleForState:UIControlStateNormal], self.titleLabel.font);
    
    switch (type) {
        case QMImagePositionTypeLeft: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
            break;
        }
        case QMImagePositionTypeRight: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, 0, imageSize.width + spacing);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleSize.width + spacing, 0, - titleSize.width);
            break;
        }
        case QMImagePositionTypeTop: {
            // lower the text and push it left so it appears centered
            //  below the image
            self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (imageSize.height + spacing), 0);

            // raise the image and push it right so it appears centered
            //  above the text
            self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0, 0, - titleSize.width);
            //NSSLog(@"%@",NSStringFromCGRect(self.imageView.frame));

            break;
        }
        case QMImagePositionTypeBottom: {
            self.titleEdgeInsets = UIEdgeInsetsMake(- (imageSize.height + spacing), - imageSize.width, 0, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, - (titleSize.height + spacing), - titleSize.width);
            break;
        }
    }
}

- (void)setImageUpTitleDownWithSpacing:(CGFloat)spacing {
    [self setImagePositionWithType:QMImagePositionTypeTop spacing:spacing];
}

- (void)setImageRightTitleLeftWithSpacing:(CGFloat)spacing {
    [self setImagePositionWithType:QMImagePositionTypeRight spacing:spacing];
}

- (void)setEdgeInsetsWithType:(QMEdgeInsetsType)edgeInsetsType marginType:(QMMarginType)marginType margin:(CGFloat)margin {
    CGSize itemSize = CGSizeZero;
    if (edgeInsetsType == QMEdgeInsetsTypeTitle) {
        itemSize = SS_SINGLELINE_TEXTSIZE([self titleForState:UIControlStateNormal], self.titleLabel.font);
    } else {
        itemSize = [self imageForState:UIControlStateNormal].size;
    }
    
    CGFloat horizontalDelta = (CGRectGetWidth(self.frame) - itemSize.width) / 2.f - margin;
    CGFloat vertivalDelta = (CGRectGetHeight(self.frame) - itemSize.height) / 2.f - margin;
    
    NSInteger horizontalSignFlag = 1;
    NSInteger verticalSignFlag = 1;
    
    switch (marginType) {
        case QMMarginTypeTop: {
            horizontalSignFlag = 0;
            verticalSignFlag = - 1;
            break;
        }
        case QMMarginTypeBottom: {
            horizontalSignFlag = 0;
            verticalSignFlag = 1;
            break;
        }
        case QMMarginTypeLeft: {
            horizontalSignFlag = - 1;
            verticalSignFlag = 0;
            break;
        }
        case QMMarginTypeRight: {
            horizontalSignFlag = 1;
            verticalSignFlag = 0;
            break;
        }
        case QMMarginTypeTopLeft: {
            horizontalSignFlag = - 1;
            verticalSignFlag = - 1;
            break;
        }
        case QMMarginTypeTopRight: {
            horizontalSignFlag = 1;
            verticalSignFlag = - 1;
            break;
        }
        case QMMarginTypeBottomLeft: {
            horizontalSignFlag = - 1;
            verticalSignFlag = 1;
            break;
        }
        case QMMarginTypeBottomRight: {
            horizontalSignFlag = 1;
            verticalSignFlag = 1;
            break;
        }
    }
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(vertivalDelta * verticalSignFlag, horizontalDelta * horizontalSignFlag, - vertivalDelta * verticalSignFlag, - horizontalDelta * horizontalSignFlag);
    if (edgeInsetsType == QMEdgeInsetsTypeTitle) {
        self.titleEdgeInsets = edgeInsets;
    } else {
        self.imageEdgeInsets = edgeInsets;
    }
}
@end
