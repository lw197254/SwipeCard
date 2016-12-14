//
//  SwipeCardView.h

 


#import <UIKit/UIKit.h>
@class SwipeCardView;
@protocol SwipeCardViewDelegate<NSObject>
@required
- (nullable UIView
   *)SwipeCardView:(nullable SwipeCardView *)swipeCardView viewForItemAtIndex:(NSInteger)index;
-(CGSize)SwipeCardView:(nullable SwipeCardView *)swipeCardView itemSizeAtIndexPath:(NSInteger )index;
@optional

-(void)SwipeCardView:(nullable SwipeCardView *)swipeCardView didSelectItemAtIndexPath:(NSInteger )index;

@end
@protocol SwipeCardViewDataSource<NSObject>
@required
-(NSInteger)SwipeCardViewnumberOfItems:(nullable SwipeCardView *)swipeCardView ;
@optional



-(void)SwipeCardView:(nullable SwipeCardView *)swipeCardView didSelectItemAtIndexPath:(NSInteger )index;

@end

typedef NS_ENUM(NSInteger,SwipeCardViewContentMode){
  
        SwipeCardViewContentModelCenter,              // default  
    
        SwipeCardViewContentModelLeft,
        SwipeCardViewContentModelRight,
    
    
 
};
@interface SwipeCardView : UIView



//@property (retain,nonatomic)NSArray* exampleCardLabels; //%%% the labels the cards
//@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards
//@property(nonatomic,assign)BOOL circleble;
@property(nonatomic,assign)BOOL showPage;
@property(nonatomic,assign)NSInteger currentPage;

@property(nonatomic,assign)SwipeCardViewContentMode contentMode;
@property(nonatomic,weak,nullable) id<SwipeCardViewDelegate> delegate;
@property(nonatomic,weak,nullable) id<SwipeCardViewDataSource> dataSource;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(nonnull NSString *)identifier;
-(__kindof  UIView* _Nullable )dequeueReusableViewWithReuseIdentifier:(nonnull NSString*)identifier forIndexPath:(NSInteger)index;
-(void)reloadData;

@end
