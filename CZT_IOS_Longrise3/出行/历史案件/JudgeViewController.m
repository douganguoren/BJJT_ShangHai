//
//  JudgeViewController.m
//  CZT_IOS_Longrise
//
//  Created by 张博林 on 16/1/6.
//  Copyright © 2016年 程三. All rights reserved.
//

#import "JudgeViewController.h"
#import "CZT_IOS_Longrise.pch"
#import "HistoryCaseViewController.h"
#import "CustomPickerView.h"
#import <BJJT_Lib/Masonry.h>

@interface JudgeViewController ()<UIAlertViewDelegate,giveDataToService>{
    
    NSMutableArray *dataList;
    NSInteger select;
    NSString *getReasonName;
    NSString *getReasonCode;
    FVCustomAlertView *FVCAlertView;
    UIAlertView *jugdeAlertView;
    CustomPickerView *pickerView;
}

@end

@implementation JudgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"评价";
    select = 100;
    dataList = [NSMutableArray array];
    getReasonName = nil;
    [self loadXIB];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - loadXib
-(void)loadXIB{
    self.bacScrollView.contentSize = CGSizeMake(0, 700);
//    self.bacScrollView.pagingEnabled = YES;
    
    //CGFloat pading = 20;
    NSArray *ietms = [[NSBundle mainBundle]loadNibNamed:@"JudgeViewXIB" owner:self options:nil];
    UIView *views = [ietms lastObject];
    views.frame  = CGRectMake(0, 0, self.bacScrollView.bounds.size.width, 700);
    [self.bacScrollView addSubview:views];
    _sureButton.layer.cornerRadius = 3;
    _sureButton.layer.masksToBounds = YES;
    _verySatisfiedButton.layer.masksToBounds = YES;
    _verySatisfiedButton.layer.cornerRadius = 3;
    _verySatisfiedButton.highlighted = NO;
    _satisfiedButton.layer.masksToBounds = YES;
    _satisfiedButton.layer.cornerRadius = 3;
    _satisfiedButton.highlighted = NO;
    _justSoSoButton.layer.masksToBounds = YES;
    _justSoSoButton.layer.cornerRadius = 3;
    _justSoSoButton.highlighted = NO;
    _unsatisfiedButton.layer.masksToBounds = YES;
    _unsatisfiedButton.layer.cornerRadius = 3;
    _unsatisfiedButton.highlighted = NO;
    _suggestTextView.layer.masksToBounds = YES;
    _suggestTextView.layer.cornerRadius = 3;
    
//        [views mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(667);
//            make.left.equalTo(self.bacScrollView).with.offset(-20);
//            make.top.mas_equalTo(0);
//            
//            make.width.mas_equalTo(self.bacScrollView.mas_width);
//        }];
    
}
                                                 
#pragma mark - 选项点击事件
- (IBAction)btnClicked:(id)sender {
    _verySatisfiedImageView.hidden = YES;
    _satisfiedImageView.hidden = YES;
    _justSoSoImageView.hidden = YES;
    _unsatisfiedImageView.hidden = YES;
    UIButton *clickedButton = (UIButton *)sender;
    NSInteger tag = clickedButton.tag - 1000;
    if (tag == 0) {
        pickerView.hidden = YES;
//        _selectPickerView.hidden = YES;
        _verySatisfiedImageView.hidden = NO;
        select = 0;
        
    }else if (tag == 1){
        
        pickerView.hidden = YES;
//        _selectPickerView.hidden = YES;
        _satisfiedImageView.hidden = NO;
        select = 1;
        
    }else if (tag == 2){
        
        if (dataList.count > 0) {
            [UIView animateWithDuration:0.3 animations:^{
                
            } completion:^(BOOL finished) {
                pickerView.hidden = NO;
            }];
//            _pickerBtn.hidden = NO;
//            _selectPickerView.hidden = NO;
//            [_selectPickerView reloadAllComponents];
        }else{
//            _pickerBtn.hidden = NO;
            [self requestData];
//            [_selectPickerView reloadAllComponents];
        }
        _justSoSoImageView.hidden = NO;
        select = 2;
        
    }else if (tag == 3){
        if (dataList.count > 0) {
            
            [UIView animateWithDuration:0.3 animations:^{
                
            } completion:^(BOOL finished) {
                pickerView.hidden = NO;
            }];
            
//            _pickerBtn.hidden = NO;
//            _selectPickerView.hidden = NO;
//            [_selectPickerView reloadAllComponents];
        }else{
            [self requestData];
//            _pickerBtn.hidden = NO;
//            [_selectPickerView reloadAllComponents];
        }
        _unsatisfiedImageView.hidden = NO;
        select = 3;
        
    }
    
    
}

//#pragma mark - picker点击事件
//- (IBAction)pickerViewBtnCliked:(id)sender {
//    _pickerBtn.hidden = YES;
//     _selectPickerView.hidden = YES;
//}



#pragma mark - 请求数据
-(void)requestData{
    
    pickerView = [CustomPickerView instancePickerView];
    pickerView.frame = CGRectMake(0, -50*([UIScreen mainScreen].bounds.size.height/667.0), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    pickerView.backgroundColor = [UIColor clearColor];
    pickerView.delegate = self;
    
    
    FVCAlertView = [[FVCustomAlertView alloc] init];
    [FVCAlertView showAlertWithonView:self.view Width:100 height:100 contentView:nil cancelOnTouch:false Duration:-1];
    [self.view addSubview:FVCAlertView];
    
    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
    [bean setValue:[Globle getInstance].loadDataName forKey:@"username"];
    [bean setValue:[Globle getInstance].loadDataPass forKey:@"password"];
    
    [[Globle getInstance].service requestWithServiceIP:ServiceURL ServiceName:[NSString stringWithFormat:@"%@/zdsearchunsatisfiedreason",kckpzcslrest] params:bean httpMethod:@"POST" resultIsDictionary:YES completeBlock:^(id result) {
        
        if (nil != result) {
            NSDictionary *bigDic = result;
            if ([bigDic[@"restate"]isEqualToString:@"0"]) {
                if (![bigDic[@"data"]isEqual:@""]) {
                    
                    NSArray *dataArray = bigDic[@"data"];
                    for (NSDictionary *dic in dataArray) {
                        [dataList addObject:dic];
                    }
                    pickerView.dataArray = [NSMutableArray array];
                    pickerView.dataArray = dataList;
                    [self.view addSubview:pickerView];
                    [pickerView.pickerView reloadAllComponents];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:bigDic[@"redes"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"获取不满意原因列表失败，请检查网络！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                NSLog(@"%@",bigDic[@"redes"]);
            }
        }
        
        
        
        
//        [_selectPickerView reloadAllComponents];
//        _selectPickerView.hidden = NO;
        [FVCAlertView dismiss];
        
    }];
    
    
}

#pragma mark - 确定点击事件
- (IBAction)sureClicked:(id)sender {
    
    if (select == 100) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请选择其中一项!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    FVCAlertView = [[FVCustomAlertView alloc] init];
    [FVCAlertView showAlertWithonView:self.view Width:100 height:100 contentView:nil cancelOnTouch:false Duration:-1];
    [self.view addSubview:FVCAlertView];
    
    NSDictionary *loginDic = [Globle getInstance].loginInfoDic;
    NSDictionary *userDic = [loginDic valueForKey:@"userinfo"];
    NSString * telephone = [userDic valueForKey:@"mobilephone"];
    
    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
    [bean setValue:_appcaseno forKey:@"appcaseno"];
    [bean setValue:_casecarno forKey:@"casecarno"];
    [bean setValue:telephone forKey:@"casetelephoe"];
    [bean setValue:_suggestTextView.text forKey:@"personevaluate"];
    [bean setValue:[NSString stringWithFormat:@"%ld",select] forKey:@"personescord"];
    if (select == 0) {
    
        [bean setValue:nil forKey:@"reasoncode"];
        
    }else if (select == 1){
        [bean setValue:nil forKey:@"reasoncode"];
        
    }else if (select == 2){
        if (getReasonName == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请选择不满意的原因!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [FVCAlertView dismiss];
            return;
        }else{
            [bean setValue:getReasonCode forKey:@"reasoncode"];
        }
        
    }else if (select == 3){
        if (getReasonName == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请选择不满意的原因!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [FVCAlertView dismiss];
            return;
        }else{
            [bean setValue:getReasonCode forKey:@"reasoncode"];
        }
        
    }
    [bean setValue:[Globle getInstance].loadDataName forKey:@"username"];
    [bean setValue:[Globle getInstance].loadDataPass forKey:@"password"];
    
    [[Globle getInstance].service requestWithServiceIP:ServiceURL ServiceName:[NSString stringWithFormat:@"%@/zdsubmitcarevaluationinfo",kckpzcslrest] params:bean httpMethod:@"POST" resultIsDictionary:YES completeBlock:^(id result) {
        if (nil != result) {
            NSDictionary *bigDic = result;
            if ([bigDic[@"restate"]isEqualToString:@"0"]){
                jugdeAlertView = [[UIAlertView alloc]initWithTitle:nil message:@"评价成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [jugdeAlertView show];
            
                
            }else{
                NSString *str = bigDic[@"redes"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"评价失败!" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"评价失败!" message:@"请检查您的网络!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        [FVCAlertView dismiss];
    }];
    
}

//#pragma mark - picker代理方法
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
//    return 1;
//}
//
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    return dataList.count;
//}
//
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    
//    NSString *unsatisfiedReasonStr = nil;
//    if (dataList.count > row) {
//        NSDictionary *dic = dataList[row];
//        unsatisfiedReasonStr = dic[@"reasonname"];
//    }
//    return unsatisfiedReasonStr;
//    
//}
//
//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    if (dataList.count > row) {
//        NSDictionary *dic = dataList[row];
//        reasonName = dic[@"reasonname"];
//        reasonCode = dic[@"reasoncode"];
//    }
//}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == jugdeAlertView) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 自定义pickerView代理
-(void)getSelectReasonName:(NSString *)reasonName andReasonCode:(NSString *)reasonCode{
    getReasonName = reasonName;
    getReasonCode = reasonCode;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
