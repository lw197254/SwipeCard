//
//  SwipeCardView.h

 


#import <UIKit/UIKit.h>
#import "SwipeCardViewCell.h"
@class SwipeCardView;

@protocol SwipeCardViewDelegate<NSObject>
@required
- (__kindof  SwipeCardViewCell* _Nullable)SwipeCardView:(nullable SwipeCardView *)swipeCardView viewForItemAtIndex:(NSInteger)index;
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

@property (nonatomic, readonly) NSArray<__kindof UIView *> *_Nullable  visibleCells;
@property(nonatomic,assign)SwipeCardViewContentMode contentMode;
@property(nonatomic,weak,nullable) id<SwipeCardViewDelegate> delegate;
@property(nonatomic,weak,nullable) id<SwipeCardViewDataSource> dataSource;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(nonnull NSString *)identifier;
-(__kindof  SwipeCardViewCell* _Nullable )dequeueReusableViewWithReuseIdentifier:(nonnull NSString*)identifier forIndexPath:(NSInteger)index;
-(void)reloadData;

@end
