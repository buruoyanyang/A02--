//
//  ViewController.m
//  A01-传智猜图
//
//  Created by Apple on 14/12/14.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "ViewController.h"
#import "CZQuestion.h"
@interface ViewController ()

//strong  oc对象
//weak  UI控件 ，代理对象
//assign  基本类型  数值类型 BOOL 结构体  枚举
//copy 字符串


@property (weak, nonatomic) IBOutlet UILabel *countView;
@property (weak, nonatomic) IBOutlet UIButton *coinView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIButton *iconView;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionView;

//记录图片按钮的原始位置
@property (nonatomic, assign) CGRect oldFrame;

//遮盖的按钮
@property (nonatomic, weak) UIButton *coverView;

//加载plist数据 模型
@property (nonatomic, strong) NSArray *questions;
//记录当前题目的索引
@property (nonatomic, assign) int index;
@property (weak, nonatomic) IBOutlet UIButton *nextView;

- (IBAction)tipClick;
- (IBAction)helpClick;
- (IBAction)bigImageClick;
- (IBAction)nextClick;

- (IBAction)iconClick;

@end

@implementation ViewController

//2 懒加载
- (NSArray *)questions
{
    if (_questions == nil) {
        _questions = [CZQuestion questionsList];
    }
    return _questions;
}


//隐藏状态栏
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

//高亮显示标题栏
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSLog(@"%@",NSHomeDirectory());
    
    //3 测试数据
//    NSLog(@"%@",self.questions);
    
    self.index--;
    [self nextClick];
    
}


- (IBAction)tipClick {
}

- (IBAction)helpClick {
}

//1 点击放大图片
- (IBAction)bigImageClick {
    //记得去掉自动布局，否则放大效果是无效的

    //记录原始的frame
    self.oldFrame = self.iconView.frame;
    
    //1.1  放大图片
    CGFloat iconW = self.view.frame.size.width;
    CGFloat iconH = iconW;
    CGFloat iconX = 0;
    CGFloat iconY = (self.view.frame.size.height - iconH) / 2;
    
    //1.3 生成遮盖的view （按钮）
    UIButton *coverView = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:coverView];
    
    self.coverView = coverView;
    
    coverView.frame = self.view.bounds;
    
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0;
    
    //1.4 把一个子控件置于顶层
    [self.view bringSubviewToFront:self.iconView];
    
    //1.2 动画
    [UIView animateWithDuration:1.0 animations:^{
        self.iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
        coverView.alpha = 0.5;
    }];
    
    //1.5 点击遮盖层 缩小图片
    [coverView addTarget:self action:@selector(smallImageClick) forControlEvents:UIControlEventTouchUpInside];
}

//1.5 点击遮盖层 缩小图片
- (void)smallImageClick
{
    [UIView animateWithDuration:1.0 animations:^{
        self.iconView.frame = self.oldFrame;
        self.coverView.alpha = 0;
        
    } completion:^(BOOL finished) {
        //当动画完成之后，移除遮盖按钮
        [self.coverView removeFromSuperview];

    }];
}
//1.6 点击图片按钮。放大或缩小
- (IBAction)iconClick {
    if (self.coverView == nil) {
        [self bigImageClick];
    }else{
        [self smallImageClick];
    }
}

//5 下一题  给子控件赋值
- (IBAction)nextClick {
    self.index++;
    //取模型数据
    if (self.index == self.questions.count -1 ) {
        return;
    }
    CZQuestion *question = self.questions[self.index];
    
    self.countView.text = [NSString stringWithFormat:@"%d/%lu",self.index+1,(unsigned long)self.questions.count];
    
    self.titleView.text = question.title;
    [self.iconView setImage:[UIImage imageNamed:question.icon] forState:UIControlStateNormal];

    self.nextView.enabled = (self.index + 1) != self.questions.count;
    
    //生成答案按钮
    [self addAnswerButtons:question];
    
    [self addOptionButtons:question];
    //生成选项按钮
}

-(void) addAnswerButtons:(CZQuestion *) question
{
    NSUInteger count = question.answer.length;
    //先删除上一题的按钮
    
    //让数组中的每一个元素执行remove方法
    [self.answerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //生成答案按钮
    for(int i = 0;i < question.answer.length;i++)
    {
        //循环生成答案按钮
        UIButton *answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.answerView addSubview:answerBtn];
        //设置frame
        CGFloat answerW = 35;
        CGFloat answerH = 35;
        CGFloat answerY = 0;
        CGFloat margin = 20;
        CGFloat marginLeft = (self.answerView.frame.size.width -  count * answerW - (count -1) * margin) / 2;
        CGFloat answerX = marginLeft + (answerW + margin) * i;
        answerBtn.frame = CGRectMake(answerX, answerY, answerW, answerH);

        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        [answerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //注册点击事件
        [answerBtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }

}


-(void) addOptionButtons:(CZQuestion* )question
{
    int totalColumn = 7; //总列数
    CGFloat optionW = 35;
    CGFloat optionH = 35;
    CGFloat marginX = (self.optionView.frame.size.width - totalColumn * optionW) / (totalColumn + 1);
    CGFloat marginY = 15;
    for (int i = 0; i < question.options.count; i++) {
        UIButton *optionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.optionView addSubview:optionBtn];
        int  row = i / totalColumn;
        int column = i % totalColumn;
        CGFloat optionX = marginX + column *(optionW + marginX);
        CGFloat optionY = row*(optionH + marginY);
        optionBtn.frame = CGRectMake(optionX, optionY, optionW, optionH);
        
        //设置按钮的属性
        [optionBtn setTitle:question.options[i] forState:UIControlStateNormal];
        [optionBtn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        [optionBtn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateNormal];
        [optionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [optionBtn setTag:i];
        //注册点击事件
        [optionBtn addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

//点击选项事件
-(void) optionClick:(UIButton *) sender
{
    sender.hidden = YES;
    //找第一个空白按钮
    for (UIButton *answerBtn in self.answerView.subviews) {
        //获取按钮上得文字
        if(answerBtn.currentTitle == nil)
        {
            //赋值
            [answerBtn setTitle:sender.currentTitle forState:UIControlStateNormal];
            [answerBtn setTag:sender.tag];
            break;
        }
    }
    BOOL isFull = YES;
    NSMutableString *inputAnswer = [NSMutableString string];
    for (UIButton *answerBtn in self.answerView.subviews ) {
        if (answerBtn.currentTitle == nil) {
            isFull = NO;
            break;
        }
        [inputAnswer appendString:answerBtn.currentTitle];
    }
    //获取当前题目
    CZQuestion *question = self.questions[self.index];
    if (isFull) {
        //禁止输入
        self.optionView.userInteractionEnabled = NO;
        //判断答案
        if ([inputAnswer isEqualToString:question.answer]) {
            [self setAnswerButtonColor:[UIColor blueColor]];
            [self performSelector:@selector(nextClick) withObject:nil afterDelay:1];
            //加分
            int coin = [self.coinView.currentTitle intValue];
            coin += 500;
            [self.coinView setTitle:[NSString stringWithFormat:@"%d",coin] forState:UIControlStateNormal];
        }
        else
        {
            [self setAnswerButtonColor:[UIColor redColor]];
        }
    }
    
}

//点击答案按钮事件
-(void) answerClick:(UIButton *) sender
{
    self.optionView.userInteractionEnabled = YES;
    if (sender.currentTitle == nil) {
        return;
    }
    for (UIButton * optionButton in self.optionView.subviews) {
        if(optionButton.tag == sender.tag )
        {
            optionButton.hidden = NO;
            break;
        }
    }
    [self setAnswerButtonColor:[UIColor blackColor]];
    [sender setTitle:nil forState:UIControlStateNormal];
}

-(void) setAnswerButtonColor:(UIColor *)color
{
    for (UIButton *answerBtn in self.answerView.subviews) {
        [answerBtn setTitleColor:color forState:UIControlStateNormal];
        
    }
}

@end





















