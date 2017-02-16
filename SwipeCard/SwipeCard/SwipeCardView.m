//
//  SwipeCardView.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "SwipeCardView.h"
#import "SwipeCardViewCell.h"
@interface SwipeCardView ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong) NSMutableDictionary*registDict;
@property(nonatomic,assign)NSInteger currentMaxItem;
@property(nonatomic,assign)NSInteger allCount;

@property(nonatomic,assign)CGPoint originLocation;
@property(nonatomic,strong)UIPanGestureRecognizer*  panGestureRecognizer;
@property(nonatomic,strong)UIGestureRecognizer*  otherPanGestureRecognizer;
@property(nonatomic,assign)BOOL isPanGestureUserable;
@property(nonatomic,strong)UILabel*pageLabel;
@property(nonatomic,strong)NSMutableArray<__kindof SwipeCardViewCell *> *visibleSwipeCardViewCells;
@property(nonatomic,strong)NSMutableDictionary*reusableSwipeCardViewCells;

@end

@implementation SwipeCardView
@synthesize visibleCells=_visibleCells;

//- (void)setVisibleCells:(NSArray<__kindof UIView *> * _Nullable)visibleCells {
//    if (_visibleCells != visibleCells) {
//       
//        _visibleCells = visibleCells;
//    }
//}
-(NSArray<__kindof UIView *> * _Nullable)visibleCells{
    return self.visibleSwipeCardViewCells;
}


//加载的view的最大个数
static const int MAX_BUFFER_SIZE = 3; //%%% max number of cards loaded at any given time,

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configInitData];
   
}
-(instancetype)init{
    if (self = [super init]) {
        [self configInitData];
    }
    return self;
}
///初始化基本信息
-(void)configInitData{
    self.visibleSwipeCardViewCells = [[NSMutableArray alloc] init];
    self.reusableSwipeCardViewCells = [[NSMutableDictionary alloc]init];
    _currentPage = 0;
   
    
    self.registDict = [[NSMutableDictionary alloc]init];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
     [self loadCards];
//    [self reloadData];
}

//%%% sets up the extra buttons on the screen
-(void)setShowPage:(BOOL)showPage{
    if (_showPage!=showPage) {
        _showPage = showPage;
        if (_showPage&&_pageLabel) {
            _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width-80, self.frame.size.height-60, 60, 40)];
            _pageLabel.textColor = [UIColor whiteColor];
            [self addSubview:_pageLabel];
//            [_pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(self).with.offset(-20);
//                make.right.equalTo(self).with.offset(-20);
//            }];
          NSLayoutConstraint*bottomConstraint =  [NSLayoutConstraint constraintWithItem:_pageLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:20];
          NSLayoutConstraint*rightConstraint =   [NSLayoutConstraint constraintWithItem:_pageLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:20];
            [self addConstraints:@[bottomConstraint,rightConstraint]];
            
            _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentPage,self.allCount];
        }else if(!_showPage){
            [_pageLabel removeFromSuperview];
        }
    }
}


-(void)reloadData{

    if ([self.dataSource respondsToSelector:@selector(SwipeCardViewnumberOfItems:)]) {
        _allCount = [self.dataSource SwipeCardViewnumberOfItems:self];
    }
    
       [self.visibleSwipeCardViewCells enumerateObjectsUsingBlock:^(SwipeCardViewCell* obj, NSUInteger idx, BOOL * _Nonnull stop) {
           [obj removeFromSuperview];
           [self.reusableSwipeCardViewCells setObject:obj forKey:obj.reuseIdentifier];
       }];
    
       [self.visibleSwipeCardViewCells removeAllObjects];
   
    if (self.allCount > 0) {
         [self loadCards];
    }
    

   
    
    
}

///view重用,暂未实现

-(__kindof SwipeCardViewCell* _Nullable)dequeueReusableViewWithReuseIdentifier:(nonnull NSString*)identifier forIndexPath:(NSInteger)index{
    Class class = self.registDict[identifier];
    
    SwipeCardViewCell*view = [self.reusableSwipeCardViewCells objectForKey:identifier];
    [self.reusableSwipeCardViewCells removeObjectForKey:identifier];
    if (view==nil) {
        
        view = [[class alloc]init];
        [view setValue:identifier forKey:@"reuseIdentifier"];
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemTap:)];
        [view addGestureRecognizer:tap];
        
        
        ///设置阴影
        view.layer.shadowColor = [UIColor grayColor].CGColor;//shadowColor阴影颜色
        view.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        view.layer.shadowOpacity = 0.7;//阴影透明度，默认0
        view.layer.shadowRadius = 4;//阴影半径，默认3

    }

    

   
    view.tag = index;
   

   
    
    return view;
}
///获取每个item的大小
-(CGSize)itemSizeWithIndex:(NSInteger)index{
     CGSize size;
    if ([self.delegate respondsToSelector:@selector(SwipeCardView:itemSizeAtIndexPath:)]) {
        size = [self.delegate SwipeCardView:self itemSizeAtIndexPath:index];
    }else{
        size = CGSizeZero;
    }
    return size;
}
//%%% loads all the cards and puts the first x in the "loaded cards" array
-(SwipeCardViewCell*)reloadCardViewAtIndex:(NSInteger)index{
    SwipeCardViewCell*view = [self.delegate SwipeCardView:self viewForItemAtIndex:index];
    
    return view;
}
-(void)loadCards
{
    for (NSInteger i = 0; i < self.currentMaxItem; i++) {
        if ([self.delegate respondsToSelector:@selector(SwipeCardView:viewForItemAtIndex:)])  {
//            NSInteger index = i;
            NSInteger index= (self.currentPage+ self.allCount+i)%self.allCount;
            SwipeCardViewCell*view = [self.delegate SwipeCardView:self viewForItemAtIndex:index];
            
            [self.visibleSwipeCardViewCells addObject:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self insertSubview:view atIndex:0];
//            [view mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.centerY.equalTo(self);
//                make.size.mas_equalTo([self itemSizeWithIndex:view.tag]);
//            }];
            NSLayoutConstraint*leftConstraint;
            switch (self.contentMode) {
                case SwipeCardViewContentModelCenter:
                    leftConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                    break;
                case SwipeCardViewContentModelLeft:
                    leftConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
                    break;
                case SwipeCardViewContentModelRight:
                    leftConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
                    break;
                    
                default:
                    break;
            }

           
            NSLayoutConstraint*centerYConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
            NSLayoutConstraint*widthConstraint =   [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self itemSizeWithIndex:view.tag].width];
             NSLayoutConstraint*heightConstraint =   [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self itemSizeWithIndex:view.tag].height];
            [self addConstraints:@[leftConstraint,centerYConstraint]];
            [view addConstraints:@[widthConstraint,heightConstraint]];
            
        }else{
//            抛出异常
            NSException *e = [NSException
                              exceptionWithName: @"未实现SwipeCardView:viewForItemAtIndex:代理方法"
                              reason: @"未实现SwipeCardView:viewForItemAtIndex:代理方法"
                              userInfo: nil];
            @throw e;
        }
        
    }
    
    [self resetAllCards];
}
//重设每个swipecardViewCell的透明度
-(void)resetAllCards{
    [self.visibleSwipeCardViewCells enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL * _Nonnull stop) {
//        [view layoutSubviews];
        [self view:view resetWithAlpha:1 -idx*0.3/MAX_BUFFER_SIZE yScale:1 - idx*0.3/MAX_BUFFER_SIZE xTransform:idx*8];
        
    }];

}
//设置view的偏移量与透明度
-(void)view:(UIView*)view resetWithAlpha:(CGFloat)alpha yScale:(CGFloat)yScale xTransform:(CGFloat)xTransform {
    view.alpha = alpha;
 CATransform3D   transform =  CATransform3DMakeTranslation(xTransform, 0, 0);

    view.layer.transform =CATransform3DScale(transform, 1, yScale, 1);
    //    transform = CGAffineTransformMakeTranslation(xTransform, 0);
//    view.transform =CGAffineTransformScale(transform, 1, yScale);
    UIView*aa = [view.subviews firstObject];
   
    NSLog(@"%f,%f",view.frame.size.height,aa.frame.origin.y+aa.frame.size.height/2);
    
}
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedToLeft:(UIView *)card;
{
//    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        card.layer.transform = CATransform3DMakeTranslation(-1000, 0, 0);
    }completion:^(BOOL finished) {
        //视图移除之后就进入回收箱
        [card removeFromSuperview];
        card.layer.transform = CATransform3DIdentity;
        
        
    } ];

    
    self.currentPage++;
    
    self.currentPage = (self.currentPage+ self.allCount)%self.allCount ;
   
   
   
    
    [self cardSwipedToLeftFinished];

}
-(void)cardSwipedToLeftFinished
{
    SwipeCardViewCell*cell = [self.visibleSwipeCardViewCells firstObject];
    [self.reusableSwipeCardViewCells setObject:cell forKey:cell.reuseIdentifier];
      [self.visibleSwipeCardViewCells removeObjectAtIndex:0];
    //向左滑动
    
    [UIView animateWithDuration:0.5 animations:^{
        //           将所有的叠加view调整位置并且加动画
        [self.visibleSwipeCardViewCells enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [self view:view resetWithAlpha:1 -idx*0.3/MAX_BUFFER_SIZE yScale:1 - idx*0.3/MAX_BUFFER_SIZE xTransform:idx*8];
            
        }];
        SwipeCardViewCell*newView =   [self reloadCardViewAtIndex:(self.currentPage+self.currentMaxItem-1)%self.allCount];
        [self view:newView resetWithAlpha:0 yScale:1 xTransform:0];
        
        
        [self.visibleSwipeCardViewCells addObject:newView];
        
        
        
    } completion:^(BOOL finished) {
        
        //               向左滑动，结束后给最下面的view加动画
        
        
        SwipeCardViewCell*newView =   [self.visibleSwipeCardViewCells lastObject];
        [self insertSubview:newView belowSubview:[self.visibleSwipeCardViewCells objectAtIndex:(self.visibleSwipeCardViewCells.count-2)]];
//        newView.hidden = NO;
        newView.translatesAutoresizingMaskIntoConstraints = NO;
//        [newView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.centerY.equalTo(self);
//            make.size.mas_equalTo([self itemSizeWithIndex:newView.tag]);
//        }];
        NSLayoutConstraint*leftConstraint;
        switch (self.contentMode) {
            case SwipeCardViewContentModelCenter:
                leftConstraint =  [NSLayoutConstraint constraintWithItem:newView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                break;
            case SwipeCardViewContentModelLeft:
                leftConstraint =  [NSLayoutConstraint constraintWithItem:newView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
                break;
            case SwipeCardViewContentModelRight:
                leftConstraint =  [NSLayoutConstraint constraintWithItem:newView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
                break;
                
            default:
                break;
        }
        
        NSLayoutConstraint*centerYConstraint =  [NSLayoutConstraint constraintWithItem:newView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint*widthConstraint =   [NSLayoutConstraint constraintWithItem:newView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self itemSizeWithIndex:newView.tag].width];
        NSLayoutConstraint*heightConstraint =   [NSLayoutConstraint constraintWithItem:newView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self itemSizeWithIndex:newView.tag].height];
        [newView addConstraints:@[widthConstraint,heightConstraint]];
        [self addConstraints:@[leftConstraint,centerYConstraint,]];

        //               [self cardSwipedToLeftFinished:newView];
        [UIView animateWithDuration:0.1 animations:^{
            //                   [self cardSwipedToLeftFinished:view];
            NSInteger idx = self.visibleSwipeCardViewCells.count -1;
            
            [self view:newView resetWithAlpha:1 -idx*0.3/MAX_BUFFER_SIZE yScale:1 - idx*0.3/MAX_BUFFER_SIZE xTransform:idx*8];
//            self.userInteractionEnabled = YES;
        }];
    }];

    
}
-(void)cardSwipedToRight:(UIView *)card
{
    self.currentPage--;
    
    self.currentPage = (self.currentPage+ self.allCount)%self.allCount ;
    SwipeCardViewCell*view = [self reloadCardViewAtIndex:self.currentPage];
    
    view.layer.transform = CATransform3DMakeTranslation(-1000, 0, 0);
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.centerY.equalTo(self);
//        make.size.mas_equalTo([self itemSizeWithIndex:view.tag]);
//    }];
    NSLayoutConstraint*leftConstraint;
    switch (self.contentMode) {
        case SwipeCardViewContentModelCenter:
            leftConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            break;
        case SwipeCardViewContentModelLeft:
            leftConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
            break;
        case SwipeCardViewContentModelRight:
            leftConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            break;
            
        default:
            break;
    }

        NSLayoutConstraint*centerYConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint*widthConstraint =   [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self itemSizeWithIndex:view.tag].width];
    NSLayoutConstraint*heightConstraint =   [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self itemSizeWithIndex:view.tag].height];
    [self addConstraints:@[leftConstraint,centerYConstraint]];
     [view addConstraints:@[widthConstraint,heightConstraint]];

    //    [self.recoverArray addObject:obj];
    [self.visibleSwipeCardViewCells insertObject:view atIndex:0];
    card.alpha = 1;
    [self cardSwipedToRightFinished];
}
-(void)cardSwipedToRightFinished{
    SwipeCardViewCell* obj = [self.visibleSwipeCardViewCells lastObject];
    
//    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.1 animations:^{
        
        [self view:obj resetWithAlpha:0 yScale:0.5 xTransform:0];
        //           将所有的叠加view调整位置并且加动画
        
    } completion:^(BOOL finished) {
        [self.visibleSwipeCardViewCells removeObject:obj];
        [self.reusableSwipeCardViewCells setObject:obj forKey:obj.reuseIdentifier];
        [obj removeFromSuperview];
        [UIView animateWithDuration:0.5 animations:^{
            //           将所有的叠加view调整位置并且加动画
            [self.visibleSwipeCardViewCells enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [self view:view resetWithAlpha:1 -idx*0.3/MAX_BUFFER_SIZE yScale:1 - idx*0.3/MAX_BUFFER_SIZE xTransform:idx*8];
                
            }];
        }];
//         self.userInteractionEnabled = YES;
    }];
    
}
-(void)animationBegin{
    
}
-(void)animationEnd{
    
}
-(NSInteger)currentMaxItem{
    if (self.allCount > MAX_BUFFER_SIZE) {
        _currentMaxItem = MAX_BUFFER_SIZE;
    }else{
        _currentMaxItem = self.allCount;
    }
    return _currentMaxItem;
}
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier{
    [self.registDict setObject:cellClass forKey:identifier];
}

-(void)setCurrentPage:(NSInteger)currentPage{
    if (currentPage!=_currentPage) {
        _currentPage = currentPage;
        if (_pageLabel) {
            _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentPage+1,self.allCount];
        }
        
    }
}

///防止手势冲突，左右滑动走当前的手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    
    if (gestureRecognizer == self.panGestureRecognizer&&[otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        self.otherPanGestureRecognizer = otherGestureRecognizer;
        return YES;
    }
    
    return NO;
}
//手势开始
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    if (self.currentMaxItem < 2) {
        return;
    }
   
   CGFloat xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
  CGFloat  yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    UIView*view = [self.visibleSwipeCardViewCells firstObject];
    if (fabs(yFromCenter) >fabs(xFromCenter)) {
        gestureRecognizer.enabled = NO;
        
        gestureRecognizer.enabled = YES;
        if (self.isPanGestureUserable) {
//            左划偏移量超过20，翻页
            if(xFromCenter<-20){
                [self cardSwipedToLeft:view];
            }else if(xFromCenter>=-20&&xFromCenter < 0){
                //                 view.center = view.originalPoint
                view.layer.transform =  CATransform3DIdentity;
            }

        }
        self.isPanGestureUserable=NO;
        return;
    }
    self.isPanGestureUserable=YES;
    if (self.otherPanGestureRecognizer) {
        self.otherPanGestureRecognizer.enabled = NO;
         self.otherPanGestureRecognizer.enabled = YES;
    }
    
//    UIView*view = gestureRecognizer.view;
    switch (gestureRecognizer.state) {
           
        case UIGestureRecognizerStateChanged:{
            if (xFromCenter <= 0) {
//                向左滑动，等手势结束后再进行操作
                view.layer.transform =   CATransform3DMakeTranslation(xFromCenter, 0, 0);
            }if (xFromCenter > 0) {
//                   向右滑动，马上进行操作
//                防止手势不放，将手势关闭后再打开
                gestureRecognizer.enabled = NO;
                 [self cardSwipedToRight:view];
                 gestureRecognizer.enabled = YES;
            }
            break;
        };
           
        case UIGestureRecognizerStateEnded: {
//            [self afterSwipeAction];
//            左划偏移量超过20，翻页
            if(xFromCenter<-20){
//
                
                
                [self cardSwipedToLeft:view];
            }else if(xFromCenter>=-20&&xFromCenter < 0){
//                 view.center = view.originalPoint
                view.layer.transform =  CATransform3DIdentity;
            }
           
            break;
        };
            default:
            break;
    }
    NSLog(@"%ld",gestureRecognizer.state);
}
-(void)itemTap:(UIGestureRecognizer*)gesture{
    if ([self.delegate respondsToSelector:@selector(SwipeCardView:didSelectItemAtIndexPath:)]) {
        [self.delegate SwipeCardView:self didSelectItemAtIndexPath:gesture.view.tag];
    }
   
    //    transform = CGAffineTransformMakeTranslation(xTransform, 0);
    //    view.transform =CGAffineTransformScale(transform, 1, yScale);
    UIView*aa = [gesture.view.subviews firstObject];
    gesture.view.layer.transform = CATransform3DIdentity;
    gesture.view.transform = CGAffineTransformIdentity;
    [gesture.view layoutSubviews];
    NSLog(@"%f,%f,%f,%f",gesture.view.frame.size.height,aa.bounds.size.height,aa.frame.origin.y+aa.frame.size.height/2,aa.frame.size.height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
