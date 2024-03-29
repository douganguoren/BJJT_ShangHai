//
//  HistoryCaseViewController.m
//  CZT_IOS_Longrise
//
//  Created by 程三 on 15/12/7.
//  Copyright (c) 2015年 程三. All rights reserved.
//

#import "HistoryCaseViewController.h"
#import "HistoryModel.h"
#import "HistoryTableViewCell.h"
#import "CaseDetailViewController.h"
#import "SGCLViewController.h"
#import "InsuranceReportController.h"
#import "CZT_IOS_Longrise.pch"
#import "WaitPayViewController.h"
#import "JudgeViewController.h"

@interface HistoryCaseViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,CellPush>{
    FVCustomAlertView *alertView;
}
@property (nonatomic,strong)NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet UITableView *htTableView;
@property (nonatomic,strong)NSMutableDictionary *historyDic;
@end

@implementation HistoryCaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    // [self requestData];
    // Do any additional setup after loading the view from its nib.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        self.hidesBottomBarWhenPushed = YES;
        //self.isShowController = true;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    _dataList = [NSMutableArray array];
    [self requestData];
    
    
}

#pragma mark -
#pragma mark - 配置界面
-(void)configUI{
    //添加下拉刷新
    _dataList = [NSMutableArray array];
    
    self.title = @"历史案件";
    [_htTableView registerNib:[UINib nibWithNibName:@"HistoryTableViewCell" bundle:nil] forCellReuseIdentifier:@"historyCell"];
    [self addRefresh];
}

#pragma mark -
#pragma mark - 添加下拉刷新
-(void)addRefresh{
    // __block HistoryCaseViewController *blockSelf = self;
    _htTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //[blockSelf.htTableView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_htTableView.mj_header endRefreshing];
        });
    }];
}

#pragma mark -
#pragma mark - 数据请求
-(void)requestData{
    // NSString *ServiceUrl = @"http://192.168.3.229:86/KCKP/restservices/kckpzcslrest/";
    
    alertView = [[FVCustomAlertView alloc] init];
    [alertView showAlertWithonView:self.view Width:100 height:100 contentView:nil cancelOnTouch:false Duration:-1];
    [self.view addSubview:alertView];
    
    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
    
    NSDictionary *loginDic = [Globle getInstance].loginInfoDic;
    NSDictionary *userDic = [loginDic valueForKey:@"userinfo"];
    _telephone = [userDic valueForKey:@"mobilephone"];
    //[bean setValue:_casecarno forKey:@"casecarno"];
    // [bean setValue:@"15071440127" forKey:@"telephone"];
    [bean setValue:_telephone forKey:@"telephone"];
    [bean setValue:[Globle getInstance].loadDataName forKey:@"username"];
    [bean setValue:[Globle getInstance].loadDataPass forKey:@"password"];
    
    [[Globle getInstance].service requestWithServiceIP:[Globle getInstance].serviceURL ServiceName:[NSString stringWithFormat:@"%@/zdsearchallcase",kckpzcslrest] params:bean httpMethod:@"POST" resultIsDictionary:YES completeBlock:^(id result) {
        NSDictionary *dic = result;
        if ([dic[@"restate"]isEqualToString:@"0"]) {
            if (nil != dic[@"data"]) {
                NSArray *array = dic[@"data"];
                if (![dic[@"data"]isEqual:@""]) {
                    for (NSDictionary * dic in array) {
                        HistoryModel *htModel = [[HistoryModel alloc]initWithDictionary:dic];
                        if (htModel.state != 7) {
                            [_dataList addObject:htModel];
                        }
                    }
                    [_htTableView reloadData];
                }else{
                    
                    [self showAlertViewWith:@"没有历史记录！"];
                }
                
            }else{
                [self showAlertViewWith:@"没有历史记录！"];
            }
            
        }else{
            [self showAlertViewWith:@"加载数据失败，请检查网络！"];
            
        }
        [alertView dismiss];
        
        
    }];
}


#pragma mark -
#pragma mark - 代理方法

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    if (_dataList.count > indexPath.row) {
        
        HistoryModel *model = _dataList[indexPath.row];
        // cell.caseHandleState.tag = 1000 + indexPath.section;
        // NSLog(@"model============%@",model);
        if (model.casetype == 0) {
            cell.caseType.text = @"单车";
        }else if (model.casetype == 1){
            cell.caseType.text = @"双车";
        }else if (model.casetype == 2){
            cell.caseType.text = @"多车";
        }
        cell.state = model.state;
        cell.casenumber = model.casenumber;
        cell.casecarno = model.casecarno;
        cell.appcaseno = model.appcaseno;
        cell.casedate = model.casedate;
        cell.inscomcode = model.inscomcode;
        cell.casetype = model.casetype;
        if (model.state == 1) {
            cell.caseState.text = @"待定责";
            [cell.caseHandleState setTitle:@"处理" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:15/255.0 alpha:1.0];
        }else if (model.state == 2){
            cell.caseState.text = @"待保险报案";
            [cell.caseHandleState setTitle:@"处理" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:15/255.0 alpha:1.0];
        }else if (model.state == 3){
            cell.caseState.text = @"待理赔";
            [cell.caseHandleState setTitle:@"待理赔" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:15/255.0 alpha:1.0];
        }else if (model.state == 4){
            cell.caseState.text = @"待评价";
            [cell.caseHandleState setTitle:@"评价" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:15/255.0 alpha:1.0];
        }else if (model.state == 5){
            cell.caseState.text = @"完成";
            [cell.caseHandleState setTitle:@"完成" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:107/255.0 green:220/255.0 blue:91/255.0 alpha:1.0];
        }else if (model.state == 6){
            cell.caseState.text = @"撤销案件";
            [cell.caseHandleState setTitle:@"已撤销" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:107/255.0 green:220/255.0 blue:91/255.0 alpha:1.0];
//        }else if (model.state == 7){
//            cell.caseState.text = @"照片待审核";
//            [cell.caseHandleState setTitle:@"处理" forState:UIControlStateNormal];
//            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:15/255.0 alpha:1.0];
        }else if (model.state == 8){
            cell.caseState.text = @"转现场处理";
            [cell.caseHandleState setTitle:@"完成" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:107/255.0 green:220/255.0 blue:91/255.0 alpha:1.0];
        }else{
            cell.caseState.text = @"完成";
            [cell.caseHandleState setTitle:@"完成" forState:UIControlStateNormal];
            cell.caseHandleState.backgroundColor = [UIColor colorWithRed:107/255.0 green:220/255.0 blue:91/255.0 alpha:1.0];
        }
        NSArray *array = [model.casehaptime componentsSeparatedByString:@"."];
        NSString *timeStr = array[0];
        cell.caseHapTime.text = timeStr;
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_dataList.count > indexPath.row) {
        HistoryModel *model = _dataList[indexPath.row];
        CaseDetailViewController *CDVC = [[CaseDetailViewController alloc]init];
//        CDVC.caseState = model.state;
        CDVC.casetype = model.casetype;
        CDVC.casehaptime = model.casehaptime;
        CDVC.accidentplace = model.accidentplace;
        CDVC.casenumber = model.casenumber;
        CDVC.casecarno = model.casecarno;
        CDVC.casedate = model.casedate;
        CDVC.insreporttel = model.insreporttel;
        CDVC.appphone = _telephone;
        CDVC.appcaseno = model.appcaseno;
        CDVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:CDVC animated:YES];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

//cell代理方法
-(void)pushNextControllerWith:(int)caseState andNumber:(NSString *)casenumber andAppcaseseno:(NSString *)appcaseno andCasecarno:(NSString *)casecarno andCasedate:(NSString *)casedate andInscomCode:(NSString *)inscomcode andCasetype:(int)casetype{
    
    if (caseState == 1) {
        
        alertView = [[FVCustomAlertView alloc] init];
        [alertView showAlertWithonView:self.view Width:100 height:100 contentView:nil cancelOnTouch:false Duration:-1];
        [self.view addSubview:alertView];
        
        NSMutableArray *casecarlistArray = [NSMutableArray array];
        NSMutableArray *historyDescribArray = [NSMutableArray array];
        NSMutableDictionary *bean = [NSMutableDictionary dictionary];
        //    [bean setObject:@"110101201512180009" forKey:@"casenumber"];
        [bean setObject:casenumber forKey:@"casenumber"];
        //  [bean setObject:@"15071440127" forKey:@"appphone"];
        [bean setObject:_telephone forKey:@"appphone"];
        [bean setObject:[Globle getInstance].loadDataName forKey:@"username"];
        [bean setObject:[Globle getInstance].loadDataPass forKey:@"password"];
        
        [[Globle getInstance].service requestWithServiceIP:[Globle getInstance].serviceURL ServiceName:[NSString stringWithFormat:@"%@/zdsearchcasedetailinfo",kckpzcslrest] params:bean httpMethod:@"POST" resultIsDictionary:YES completeBlock:^(id result) {
            NSDictionary *bigDic = result;
            if ([bigDic[@"restate"]isEqualToString:@"0"]) {
                if (![bigDic[@"data"]isEqual:@""]) {
                    //     NSLog(@"%@",dic[@"data"]);
                    NSDictionary *dataDic = bigDic[@"data"];
                    NSArray *dataArray = dataDic[@"casecarlist"];
                    for (NSDictionary *dic in dataArray) {
                        [casecarlistArray addObject:dic];
                    }
                    [casecarlistArray addObject:casecarno];
                    [historyDescribArray addObject:dataDic[@"accidenttype"]];
                    [historyDescribArray addObject:dataDic[@"accidentdes"]];
                    
                }else{
                    [self showAlertViewWith:@"加载失败，请确认网络是否开启！"];
                }
                
            }else{
                [self showAlertViewWith:@"加载失败，请确认网络是否开启！"];
            }
            
            [alertView dismiss];
        }];
        
        SGCLViewController *SGL = [[SGCLViewController alloc]init];
        SGL.currentMark = 1;
        SGL.appcaseno = appcaseno;
        if (casetype == 0) {
            SGL.type = 1;
            
        }else{
            
            SGL.type = 2;
            SGL.moreHistoryToResponsArray = [NSMutableArray array];
            SGL.moreHistoryToResponsArray = casecarlistArray;
            SGL.historyDescribArray = [NSMutableArray array];
            SGL.historyDescribArray = historyDescribArray;
        }
        
        
        SGL.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:SGL animated:YES];
        
    }else if (caseState == 2){
        
        FVCustomAlertView *alertView1 = [[FVCustomAlertView alloc]init];
        [alertView1 showAlertWithonView:self.view Width:100 height:100 contentView:nil cancelOnTouch:false Duration:-1];
        [self.view addSubview:alertView1];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Insurance" bundle:nil];
        InsuranceReportController *InReVC = [storyboard instantiateViewControllerWithIdentifier:@"InsuranceReport"];
        
        NSMutableDictionary *bean = [NSMutableDictionary dictionary];
        [bean setValue:casenumber forKey:@"casenumber"];
        [bean setValue:_telephone forKey:@"appphone"];
        [bean setValue:[Globle getInstance].loadDataName forKey:@"username"];
        [bean setValue:[Globle getInstance].loadDataPass forKey:@"password"];
        [[Globle getInstance].service requestWithServiceIP:[Globle getInstance].serviceURL ServiceName:[NSString stringWithFormat:@"%@/zdsearchcasedetailinfo",kckpzcslrest] params:bean httpMethod:@"POST" resultIsDictionary:YES completeBlock:^(id result) {
            NSDictionary *reDic = result;
            if ([reDic[@"restate"]isEqualToString:@"0"]) {
                if (![reDic[@"data"]isEqual:@""]) {
                    NSArray *array = reDic[@"data"][@"casecarlist"];
                    for (NSDictionary *dic in array) {
                        if ([dic[@"casecarno"]isEqualToString:casecarno]) {
                            if ([dic[@"dutytype"]isEqualToNumber:@1]) {
                                
                                [self showAlertViewWith:@"无责信息无需处理"];
                                return;
                            }else{
                                NSMutableArray *casecarlistArray = [NSMutableArray array];
                                
                                for (int i = 0; i < array.count; i++) {
                                    
                                    NSMutableDictionary *dicArr = [NSMutableDictionary dictionary];
                                    NSDictionary *arrDic = array[i];
                                    if ([arrDic[@"casecarno"]isEqualToString:casecarno]) {
                                        [dicArr setValue:arrDic[@"casecarno"] forKey:@"casecarno"];
                                        [dicArr setValue:arrDic[@"dutytype"] forKey:@"dutytype"];
                                        [dicArr setValue:arrDic[@"inscomname"] forKey:@"inscomname"];
                                        [dicArr setValue:arrDic[@"inscomcode"] forKey:@"inscomcode"];
                                        [dicArr setValue:arrDic[@"carownname"] forKey:@"carownname"];
                                        [dicArr setValue:arrDic[@"carownphone"] forKey:@"carownphone"];
                                        [dicArr setValue:arrDic[@"driverno"] forKey:@"driverno"];
                                        [dicArr setValue:arrDic[@"signimgurl"] forKey:@"signimgurl"];
                                        [dicArr setValue:arrDic[@"signdate"] forKey:@"signdate"];
                                        [casecarlistArray addObject:dicArr];
                                    }
                                }

                                for (int i = 0; i < array.count; i++) {
    
                                    NSMutableDictionary *dicArr = [NSMutableDictionary dictionary];
                                    NSDictionary *arrDic = array[i];
                                    if (![arrDic[@"casecarno"]isEqualToString:casecarno]) {
                                        [dicArr setValue:arrDic[@"casecarno"] forKey:@"casecarno"];
                                        [dicArr setValue:arrDic[@"dutytype"] forKey:@"dutytype"];
                                        [dicArr setValue:arrDic[@"inscomname"] forKey:@"inscomname"];
                                        [dicArr setValue:arrDic[@"inscomcode"] forKey:@"inscomcode"];
                                        [dicArr setValue:arrDic[@"carownname"] forKey:@"carownname"];
                                        [dicArr setValue:arrDic[@"carownphone"] forKey:@"carownphone"];
                                        [dicArr setValue:arrDic[@"driverno"] forKey:@"driverno"];
                                        [dicArr setValue:arrDic[@"signimgurl"] forKey:@"signimgurl"];
                                        [dicArr setValue:arrDic[@"signdate"] forKey:@"signdate"];
                                        [casecarlistArray addObject:dicArr];
                                    }
                                }
                                
                                _historyDic = [NSMutableDictionary dictionary];
                                [_historyDic setValue:appcaseno forKey:@"appcaseno"];
                                [_historyDic setValue:casecarno forKey:@"casecarno"];
                                [_historyDic setValue:_telephone forKey:@"casetelephone"];
                                [_historyDic setValue:[NSString stringWithFormat:@"%lf",[Globle getInstance].imagelon] forKey:@"caselon"];
                                [_historyDic setValue:[NSString stringWithFormat:@"%lf",[Globle getInstance].imagelat] forKey:@"caselat"];
                                [_historyDic setValue:reDic[@"data"][@"caseaddress"] forKey:@"caseaddress"];
                                [_historyDic setValue:casedate forKey:@"casedate"];
                                [_historyDic setValue:inscomcode forKey:@"inscomcode"];
                                [_historyDic setValue:@"0" forKey:@"reportway"];
                                [_historyDic setValue:[Globle getInstance].areaid forKey:@"areaid"];
                                [_historyDic setValue:casecarlistArray forKey:@"casecarlist"];
                                [_historyDic setValue:[Globle getInstance].loadDataName forKey:@"username"];
                                [_historyDic setValue:[Globle getInstance].loadDataPass forKey:@"password"];
                                InReVC.historyCaseDict = _historyDic;
                                InReVC.hidesBottomBarWhenPushed = YES;
                                [self.navigationController pushViewController:InReVC animated:YES];
                                break;
                            }
                        }
                    }
                    
                    
                }else{
                    [self showAlertViewWith:reDic[@"redes"]];
                }
                
            }else{
                
                [self showAlertViewWith:@"请检查网络是否连接！"];
            }
            [alertView1 dismiss];
        }];
        
        
    }else if (caseState == 3){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请等待理赔！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
    }else if (caseState == 4){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"JudgeViewSB" bundle:nil];
        JudgeViewController *JVC = [storyboard instantiateViewControllerWithIdentifier:@"JudgeViewID"];
        JVC.appcaseno = appcaseno;
        JVC.casecarno = casecarno;
        [self.navigationController pushViewController:JVC animated:YES];
        
    }else if (caseState == 5){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"案件已完成！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
    }else if (caseState == 6){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"案件已撤消！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
//    }else if (caseState == 7){
//        SGCLViewController *SGL = [[SGCLViewController alloc]init];
//        SGL.currentMark = 1;
//        SGL.appcaseno = appcaseno;
//        if (casetype == 0) {
//            SGL.type = 1;
//            
//        }else{
//            SGL.type = 2;
//        }
//        SGL.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:SGL animated:YES];
        
    }else if (caseState == 8){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"案件已转现场处理！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"案件已完成！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    
}

//#pragma mark -
//#pragma mark - 点击事件
//-(void)waitHandleBtnClicked:(UIButton *)sender{
//    SGCLViewController *SGL = [[SGCLViewController alloc]init];
//    SGL.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:SGL animated:YES];
//}

//-(void)HandleBtnClicked:(UIButton *)sender{
//
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Insurance" bundle:nil];
//    InsuranceReportController *InReVC = [storyboard instantiateViewControllerWithIdentifier:@"InsuranceReport"];
//
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    indicator.center = CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height-40);
//    [self.view addSubview:indicator];
//    [indicator startAnimating];
//
//    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
//    //[bean setValue:_casecarno forKey:@"casecarno"];
//    [bean setValue:casenumber forKey:@"casenumber"];
//    [bean setValue:@"15071440127" forKey:@"appphone"];
//    // [bean setValue:_telephone forKey:@"telephone"];
//    [bean setValue:[Globle getInstance].loadDataName forKey:@"username"];
//    [bean setValue:[Globle getInstance].loadDataPass forKey:@"password"];
//    [[Globle getInstance].service requestWithServiceIP:[Globle getInstance].serviceURL ServiceName:@"zdsearchcasedetailinfo" params:bean httpMethod:@"POST" resultIsDictionary:YES completeBlock:^(id result) {
//        NSDictionary *dic = result;
//        if ([dic[@"restate"]isEqualToString:@"0"]) {
//            if (dic[@"data"]) {
//                NSArray *array = dic[@"data"][@"casecarlist"];
//                for (NSDictionary *dic in array) {
//                    if ([dic[@"casecarno"]isEqualToString:model.casecarno]) {
//                        if ([dic[@"dutytype"]isEqualToNumber:@1]) {
//                            [indicator stopAnimating];
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"无责信息无需处理" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                            [alert show];
//                        }else{
//                            [indicator stopAnimating];
//                            [_historyDic setValue:model.appcaseno forKey:@"appcaseno"];
//                            [_historyDic setValue:model.casecarno forKey:@"casecarno"];
//                            [_historyDic setValue:@"15071440127" forKey:@"casetelephone"];
//                            [_historyDic setValue:[NSString stringWithFormat:@"%lf",[Globle getInstance].imagelon] forKey:@"caselon"];
//                             [_historyDic setValue:[NSString stringWithFormat:@"%lf",[Globle getInstance].imagelat] forKey:@"caselat"];
//                            [_historyDic setValue:dic[@"data"][@"caseaddress"] forKey:@"caseaddress"];
//
////                            @property(nonatomic,assign)float imagelon;
////                            //纬度
////                            @property(nonatomic,assign)float imagelat;
//                            InReVC.hidesBottomBarWhenPushed = YES;
//                            [self.navigationController pushViewController:InReVC animated:YES];
//                        }
//                    }
//                }
//
//
//            }else{
//                NSLog(@"无数据");
//                NSLog(@"%@",dic[@"redes"]);
//            }
//
//        }else{
//            NSLog(@"获取数据失败");
//            NSLog(@"%@",dic[@"redes"]);
//        }
//    }];

//
//}
//
//-(void)completeBrnClicked:(UIButton *)sender{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"案件已完成！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alert show];
//}
-(void)showAlertViewWith:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:title delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
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
