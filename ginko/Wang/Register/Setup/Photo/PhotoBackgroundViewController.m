//
//  PhotoBackgroundViewController.m
//  GINKO
//
//  Created by MobiDev on 12/20/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "PhotoBackgroundViewController.h"
#import "CustomTitleView.h"
#import "PhotoPickerController.h"

const int bcCount = 70;

@interface PhotoBackgroundViewController ()

@end

@implementation PhotoBackgroundViewController
@synthesize parentController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addBackgroundColorButtons];
}

-(void)setupUI
{
    UIButton *btBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btBack setImage:[UIImage imageNamed:@"BackArrow"] forState:UIControlStateNormal];
    [btBack setFrame:CGRectMake(0, 0, 14, 14)];
    [btBack addTarget:self action:@selector(btBackClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btBarBack = [[UIBarButtonItem alloc] initWithCustomView:btBack];
    [self.navigationItem setLeftBarButtonItem:btBarBack];
    
    PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
    
    switch (viewController.type) {
        case 1: //home
        {
            CustomTitleView *titleView = [CustomTitleView homeInfoView];
            [self.navigationItem setTitleView:titleView];
            break;
        }
        case 2: //work
        {
            CustomTitleView *titleView = [CustomTitleView workInfoView];
            [self.navigationItem setTitleView:titleView];
            break;
        }
        case 3: //entity
        {
            CustomTitleView *titleView = [CustomTitleView entityView:@"Entity Info"];
            [self.navigationItem setTitleView:titleView];
            break;
        }
        case 4: //home
        {
            CustomTitleView *titleView = [CustomTitleView homeInfoView];
            [self.navigationItem setTitleView:titleView];
            break;
        }
        default:
            break;
    }
}

- (void)addBackgroundColorButtons
{
    CGPoint point;
    point.x = 5;
    point.y = 5;
    
    CGSize newSize = CGSizeMake(40, 40);
    
    UIButton *btnPlayer[bcCount];
    
    int i;
    
    for (i=0; i<bcCount; i++) {
        btnPlayer[i] = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnPlayer[i] setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"bc_%d", i+1]] forState:UIControlStateNormal];
        [btnPlayer[i] setTag:101 + i];
        [btnPlayer[i] addTarget:self action:@selector(btSelectBC:) forControlEvents:UIControlEventTouchUpInside];
        
        [btnPlayer[i] setFrame:CGRectMake(point.x, point.y, newSize.width, newSize.height)];
        
        [scvMain addSubview:btnPlayer[i]];
        
        // Increase X Pos
        point.x += newSize.width + 5;
        
        if (i % 7 == 6) {
            point.y += newSize.height + 5;
            point.x = 5;
        }
    }
    
    [scvMain setContentSize:CGSizeMake(0, (i/7 + 1) * 40 + 5)];
    
}

-(IBAction)btBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btSelectBC:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [parentController.navigationController popViewControllerAnimated:NO];
    [parentController didSelectBackgroundColor:(int)btn.tag - 100];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
