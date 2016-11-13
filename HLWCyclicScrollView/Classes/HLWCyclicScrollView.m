//
//  HLWCyclicScrollView.m
//  HLWCyclicScrollViewDemo
//
//  Created by tang on 16/1/1.
//  Copyright © 2016年 tang. All rights reserved.
//

#import "HLWCyclicScrollView.h"
#import "HLWDoubleLinkedCircularList.h"
#import "UIImageView+WebCache.h"
#import "ConstraintPack.h"

@interface HLWCyclicScrollView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView * scrollView;
@property (strong, nonatomic) UIPageControl * pageControl;

@property (strong, nonatomic) UIImageView * leftImageView;
@property (strong, nonatomic) UIButton * middleButton;
@property (strong, nonatomic) UIImageView * middleImageView;
@property (strong, nonatomic) UIImageView * rightImageView;

@property (strong, nonatomic) HLWDoubleLinkedCircularList * list;
@property (strong, nonatomic) HLWDoubleWayNode * leftNode;
@property (strong, nonatomic) HLWDoubleWayNode * middleNode;
@property (strong, nonatomic) HLWDoubleWayNode * rightNode;

@property (assign, nonatomic) CGFloat scrollViewWidth;
@property (assign, nonatomic) CGFloat scrollViewHeight;

@property (assign, nonatomic) BOOL autoScroll;
@property (strong, nonatomic) NSTimer * timer;

@end


@implementation HLWCyclicScrollView

#pragma mark - ---------- Initialize
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonConfig];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonConfig];
    }
    return self;
}

#pragma mark - ---------- Create interface
- (void)commonConfig
{
    self.backgroundColor = [UIColor whiteColor];
    // add scroll view
    [self addScrollView];
    
    // config scroll view
    [self configScrollView];
    
    // add content views
    [self addContentViews];
    
    // add page controll
    [self addAndLayoutPageControl];
    
    // auto scroll
    _autoScroll = YES;
    
    NSLog(@"view frame: %@", NSStringFromCGRect(self.frame));
}

- (void)addScrollView
{
    // create
    _scrollView = [UIScrollView new];
    // disable auto size
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    // add
    [self addSubview:_scrollView];

    // constraint x
    NSString *hFormat = @"H:|-(0)-[_scrollView]-(0)-|";
    NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);
    NSArray *hConstraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:hFormat
                            options:0
                            metrics:nil
                            views:views];
    [self addConstraints:hConstraints];
    
    // constraint y
    NSString *vFormat = @"V:|-(0)-[_scrollView]-(0)-|";
    NSArray *vConstraints = [NSLayoutConstraint
                             constraintsWithVisualFormat:vFormat
                             options:0
                             metrics:nil
                             views:views];
    [self addConstraints:vConstraints];
}

- (void)configScrollView
{
    // set content size
    _scrollView.contentSize = CGSizeMake(3 * _scrollView.frame.size.width, _scrollView.frame.size.height);
    // set background color
    _scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    // enbale page
    _scrollView.pagingEnabled = YES;
    // set delegate
    _scrollView.delegate = self;
    
    // hide Scroll Indicator
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
}



- (void)setContentViews
{
    [self removeContentViews];
    [self addContentViews];
    _scrollView.contentOffset = CGPointMake(self.scrollViewWidth, 0);
    
    // set page control
    self.pageControl.currentPage = _middleNode.index;
}

- (void)addContentViews
{
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.middleButton];
    [self.scrollView addSubview:self.rightImageView];
}

- (void)removeContentViews
{
    [self.leftImageView removeFromSuperview];
    [self.middleButton removeFromSuperview];
    [self.rightImageView removeFromSuperview];
}

- (void)addDataToContentViews
{
    [self addContent:_leftNode.data toImageView:self.leftImageView];
    [self addContent:_middleNode.data toImageView:self.middleImageView];
    [self addContent:_rightNode.data toImageView:self.rightImageView];
}

- (void)addContent:(id)content toImageView:(UIImageView *)imageViwe
{
    if ([content isKindOfClass:[UIImage class]]) {
        // content is image
        imageViwe.image = content;
    } else if ([content isKindOfClass:[NSString class]]) {
        // content is string
        if ([content hasPrefix:@"http://"]) {
            // content is image url
            [imageViwe sd_setImageWithURL:[NSURL URLWithString:content] placeholderImage:[UIImage imageNamed:_placeholderImageName]];
        } else {
            // content is image name
            imageViwe.image = [UIImage imageNamed:content];
        }
    }
}

- (UIImage *)imageWithContent:(id)content
{
    UIImage *returnImage = nil;
    if ([content isKindOfClass:[UIImage class]]) {
        returnImage = content;
    } else if ([content isKindOfClass:[NSString class]]){
        returnImage = [UIImage imageNamed:content];
    }
    
    return returnImage;
}

-(UIImageView *)leftImageView
{
    if (!_leftImageView) {
        CGRect frame = CGRectMake(0, 0, self.scrollViewWidth, self.scrollViewWidth);
        _leftImageView = [[UIImageView alloc] initWithFrame:frame];
//        _leftImageView.backgroundColor = [UIColor redColor];
    }
    return _leftImageView;
}

-(UIButton *)middleButton
{
    if (!_middleButton) {
        CGRect frame = CGRectMake(0, 0, self.scrollViewWidth, self.scrollViewWidth);
        _middleButton = [[UIButton alloc] initWithFrame:frame];
        
        self.middleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // add
        [_middleButton addSubview:self.middleImageView];
        
        // layout
        Pin(self.middleImageView, @"H:|[view]|");
        Pin(self.middleImageView, @"V:|[view]|");
        
        // config
        [_middleButton addTarget:self action:@selector(pressDownMiddleButton) forControlEvents:UIControlEventTouchDown];
        [_middleButton addTarget:self action:@selector(pressUpMiddleButton) forControlEvents:UIControlEventTouchUpInside];

    }
    return _middleButton;
}

-(void)pressDownMiddleButton
{
    NSLog(@"%s", __func__);
    [self pauseAutoScroll];
}

-(void)pressUpMiddleButton
{
    NSLog(@"%s", __func__);
    [self startAutoScroll];
}

-(UIImageView *)middleImageView
{
    if (!_middleImageView) {
        CGRect frame = CGRectMake(self.scrollViewWidth, 0, self.scrollViewWidth, self.scrollViewWidth);
        _middleImageView = [[UIImageView alloc] initWithFrame:frame];
    }
    return _middleImageView;
}

-(UIImageView *)rightImageView
{
    if (!_rightImageView) {
        CGRect frame = CGRectMake(2 * self.scrollViewWidth, 0, self.scrollViewWidth, self.scrollViewWidth);
        _rightImageView = [[UIImageView alloc] initWithFrame:frame];
//        _rightImageView.backgroundColor = [UIColor blueColor];

    }
    return _rightImageView;
}

-(UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        
        // disable auto size
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        _pageControl.currentPage = 0;
        
        // color
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        
        // space
        _pageControlSpace = 10;
        
        _pageControl.hidesForSinglePage = YES;
        
    }
    return _pageControl;
}

- (void)addAndLayoutPageControl
{
    // add
    [self addSubview:self.pageControl];
    [self bringSubviewToFront:self.pageControl];
    
    // layout
    // x
    
    NSLayoutAttribute layoutAttribute;
    CGFloat space = _pageControlSpace;
    if (PageControlPositionRight == _pageControlPosition) {
        layoutAttribute = NSLayoutAttributeRight;
    } else if (PageControlPositionMiddle == _pageControlPosition) {
        layoutAttribute = NSLayoutAttributeCenterX;
        space = 0;
    } else if (PageControlPositionLeft == _pageControlPosition) {
        layoutAttribute = NSLayoutAttributeLeft;
    }
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:layoutAttribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.pageControl
                                                                  attribute:layoutAttribute
                                                                 multiplier:1
                                                                   constant:space];
    [self addConstraint:constraint];
    
    // y
    NSLayoutConstraint *vconstraint = [NSLayoutConstraint constraintWithItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.pageControl
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0];
    [self addConstraint:vconstraint];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (1 >= _contentArray.count) {
        _scrollView.contentSize = CGSizeMake(self.scrollViewWidth, self.scrollViewHeight);
        _scrollView.contentOffset = CGPointMake(0, 0);
        
    } else {
        _scrollView.contentOffset = CGPointMake(self.scrollViewWidth, 0);
        _scrollView.contentSize = CGSizeMake(3 * _scrollView.frame.size.width, _scrollView.frame.size.height);

    }
    
//
    [self layoutContentViews];

}

-(CGFloat)scrollViewWidth
{
    if (!_scrollViewWidth) {
        _scrollViewWidth = _scrollView.frame.size.width;
    }
    return _scrollViewWidth;
}

-(CGFloat)scrollViewHeight
{
    if (!_scrollViewHeight) {
        _scrollViewHeight = _scrollView.frame.size.height;
    }
    return _scrollViewHeight;
}

- (void)tappedMiddleImage:(UIGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(cyclicScrollView: didSelectPageAtIndex:)]) {
        [_delegate cyclicScrollView:self didSelectPageAtIndex:_middleNode.index];
    }
}

#pragma mark - ---------- layout
- (void)layoutContentViews
{
    self.leftImageView.frame = CGRectMake(0, 0, self.scrollViewWidth, self.scrollViewHeight);
    self.middleButton.frame = CGRectMake(self.scrollViewWidth, 0, self.scrollViewWidth, self.scrollViewHeight);
    self.rightImageView.frame = CGRectMake(self.scrollViewWidth * 2, 0, self.scrollViewWidth, self.scrollViewHeight);
    _scrollView.contentOffset = CGPointMake(self.scrollViewWidth, 0);
}

#pragma mark - ---------- data

- (void)setContentArray:(NSArray *)contentArray
{
    if (contentArray != _contentArray) {
        _contentArray = contentArray;
        
        [self loadData];
    }
}

- (void)loadData
{
    _list = [HLWDoubleLinkedCircularList doubleLinkedCircularListWithArray:_contentArray];
    [self initLeftMiddleRightNodes];
    self.pageControl.numberOfPages = _contentArray.count;
    self.pageControl.currentPage = _middleNode.index;

    [self addDataToContentViews];
    
    if (1 >= _contentArray.count) {
        _scrollView.contentSize = CGSizeMake(self.scrollViewWidth, self.scrollViewHeight);
        _scrollView.contentOffset = CGPointMake(0, 0);
        
        _disableAutoScroll = YES;
        
        // disable auto scroll
        [self pauseAutoScroll];
        
    } else {
        _scrollView.contentOffset = CGPointMake(self.scrollViewWidth, 0);
        
        // start to auto scroll
        [self startAutoScroll];
    }
    
    
    
    
}

- (void)reloadData
{
    // reset ContentViews
    [self removeContentViews];
    [self addContentViews];
    
    [_scrollView setContentOffset:CGPointMake(self.scrollViewWidth, 0) animated:NO];

    
    // set data
    [self addDataToContentViews];
    
    // set pageControl
    self.pageControl.numberOfPages = _contentArray.count;
    self.pageControl.currentPage = _middleNode.index;
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
//    [self loadData];
    NSLog(@"%s", __func__);
    
}

- (void)initLeftMiddleRightNodes
{
    _middleNode = _list.head;
    _leftNode = _middleNode.previous;
    _rightNode = _middleNode.next;
}

- (void)previousTurn
{
    _middleNode = _middleNode.previous;
    _leftNode = _middleNode.previous;
    _rightNode = _middleNode.next;
}

- (void)nextTurn
{
    _middleNode = _middleNode.next;
    _leftNode = _middleNode.previous;
    _rightNode = _middleNode.next;
}

#pragma mark - ---------- Auto scroll
-(NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)pauseAutoScroll
{
    if (self.timer.isValid) {
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)startAutoScroll
{
    if (self.timer.isValid && NO == self.disableAutoScroll) {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
    }
}

- (void)invalidateTimer;
{
    [self.timer invalidate];
}

- (void)scroll
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollViewWidth * 2, 0) animated:YES];
}

- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
}

#pragma mark - ---------- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat pageIndex = offset.x / self.scrollViewWidth;
    
    if (0 >= pageIndex) {
        // 左划，因为页面从中间页划到了第一页；
        [self previousTurn];
        [self reloadData];
        
    } else if (1 == pageIndex) {
        // 没划，因为页面还是中间页；
    } else if (2 <= pageIndex) {
        // 右划，因为页面从中间页划到了第三页；
        [self nextTurn];
        [self reloadData];
    }
//    NSLog(@"%s", __func__);
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
    [_scrollView setContentOffset:CGPointMake(self.scrollViewWidth, 0) animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // when user drag, pause auto scroll
    [self pauseAutoScroll];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // finish drag, restart auto scroll
    [self startAutoScroll];
}

#pragma mark - ---------- touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __func__);
    NSLog(@"event: %@", event);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __func__);
    NSLog(@"event: %@", event);
}

- (void)dealloc
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

/*
 - (void)loadData
 {
 // page count
 if (_delegate && [_delegate respondsToSelector:@selector(numberOfPagesInCyclicScrollView:)]) {
 self.pageControl.numberOfPages = [_delegate numberOfPagesInCyclicScrollView:self];
 }
 
 // set images
 if (_delegate && [_delegate respondsToSelector:@selector(cyclicScrollView: contentOfPageAtIndex:)]) {
 id leftContent = [_delegate cyclicScrollView:self contentOfPageAtIndex:0];
 id middleContent = [_delegate cyclicScrollView:self contentOfPageAtIndex:1];
 id rightContent = [_delegate cyclicScrollView:self contentOfPageAtIndex:2];
 
 _leftImageView.image = [self imageWithContent:leftContent];
 _middleImageView.image = [self imageWithContent:middleContent];
 _rightImageView.image = [self imageWithContent:rightContent];
 }
 }
 */


@end
