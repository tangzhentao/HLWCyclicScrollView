//
//  HLWCyclicScrollView.h
//  HLWCyclicScrollViewDemo
//
//  Created by tang on 16/1/1.
//  Copyright © 2016年 tang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PageControlPosition)
{
    PageControlPositionRight = 0,
    PageControlPositionMiddle = 1,
    PageControlPositionLeft = 2,
    
};

@protocol HLWCyclicScrollViewDelegate;

@interface HLWCyclicScrollView : UIView

/*
 用于自定义pageControl的颜色
 */
@property (strong, nonatomic, readonly) UIPageControl * pageControl;

@property (assign, nonatomic) PageControlPosition pageControlPosition;
@property (assign, nonatomic) CGFloat pageControlSpace;

@property (strong, nonatomic) NSArray * contentArray;

@property (strong, nonatomic) NSString * placeholderImageName; // 站位图

@property (assign, nonatomic) id<HLWCyclicScrollViewDelegate> delegate;

@property (assign, nonatomic) BOOL disableAutoScroll; // 禁止自动滚动


/*
 pause/restart auto scroll
 */
- (void)pauseAutoScroll;
- (void)startAutoScroll;
- (void)invalidateTimer;

@end


 @protocol HLWCyclicScrollViewDelegate <NSObject>


- (void)cyclicScrollView:(HLWCyclicScrollView *)cyclicScrollView didSelectPageAtIndex:(NSUInteger)index;
 
// - (NSInteger)numberOfPagesInCyclicScrollView:(HLWCyclicScrollView *)cyclicScrollView;
// - (id)cyclicScrollView:(HLWCyclicScrollView *)cyclicScrollView contentOfPageAtIndex:(NSUInteger)index;

 @end




