//
//  ViewController.m
//  SwipeCard
//
//  Created by 刘伟 on 2016/12/12.
//  Copyright © 2016年 万圣伟业. All rights reserved.
//

#import "ViewController.h"
#import "SwipeCardView.h"
@interface ViewController ()<SwipeCardViewDelegate,SwipeCardViewDataSource,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet SwipeCardView *swipeCardView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.swipeCardView.delegate = self;
    self.swipeCardView.dataSource = self;
    self.swipeCardView.backgroundColor = [UIColor blueColor];
    self.swipeCardView.showPage = YES;
    ///可以自定义一个view
    [self.swipeCardView registerClass:[SwipeCardViewCell class] forCellWithReuseIdentifier:@"swipe"];
    [self.swipeCardView reloadData];
   
    // Do any additional setup after loading the view, typically from a nib.
}
-(NSInteger)SwipeCardViewnumberOfItems:(SwipeCardView *)swipeCardView{
    return 16;
}
-(CGSize)SwipeCardView:(SwipeCardView *)swipeCardView itemSizeAtIndexPath:(NSInteger)index{
    return CGSizeMake(200, 100);
}

-(SwipeCardViewCell*)SwipeCardView:(SwipeCardView *)swipeCardView viewForItemAtIndex:(NSInteger)index{
    SwipeCardViewCell*cell = [swipeCardView dequeueReusableViewWithReuseIdentifier:@"swipe" forIndexPath:index];
   
    cell.backgroundColor = [UIColor orangeColor];
   
    
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 120;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        NSLog(@"%@", [NSString stringWithFormat:@"%ld",indexPath.row]);
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
