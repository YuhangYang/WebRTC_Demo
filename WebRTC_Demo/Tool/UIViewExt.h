/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

CGRect CGRectMoveToCenter(CGRect rect, CGPoint center);

@interface UIView (ViewFrameGeometry)

@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property(nonatomic, assign) CGFloat x;
@property(nonatomic, assign) CGFloat y;

@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat width;

@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign) CGFloat left;

@property(nonatomic, assign) CGFloat bottom;
@property(nonatomic, assign) CGFloat right;

- (void)moveBy: (CGPoint) delta;
- (void)scaleBy: (CGFloat) scaleFactor;
- (void)fitInSize: (CGSize) aSize;

@end
