//
//  ViewController.m
//  SwipeCard
//
//  Created by 刘伟 on 2016/12/12.
//  Copyright © 2016年 万圣伟业. All rights reserved.
//

#import "ViewController.h"
#import "SwipeCardView.h"
@interface ViewController ()<SwipeCardViewDelegate,SwipeCardViewDataSource>
@property (weak, nonatomic) IBOutlet SwipeCardView *swipeCardView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.swipeCardView.delegate = self;
    self.swipeCardView.dataSource = self;
    self.swipeCardView.backgroundColor = [UIColor orangeColor];
    self.swipeCardView.showPage = YES;
    ///可以自定义一个view
    [self.swipeCardView registerClass:[UILabel class] forCellWithReuseIdentifier:@"swipe"];
    [self.swipeCardView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}
-(NSInteger)SwipeCardViewnumberOfItems:(SwipeCardView *)swipeCardView{
    return 16;
}
-(CGSize)SwipeCardView:(SwipeCardView *)swipeCardView itemSizeAtIndexPath:(NSInteger)index{
    return CGSizeMake(200, 100);
}
-(UIView*)SwipeCardView:(SwipeCardView *)swipeCardView viewForItemAtIndex:(NSInteger)index{
    UILabel*label = [swipeCardView dequeueReusableViewWithReuseIdentifier:@"swipe" forIndexPath:index];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor blueColor];
    label.text = [NSString stringWithFormat:@"%ld",index];
    
    
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
