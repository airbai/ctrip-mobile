//
//  MConfigController.m
//  ctrip-mobile
//
//  Created by caoguangyao on 13-4-17.
//  Copyright (c) 2013年 caoguangyao. All rights reserved.
//

#import "MConfigController.h"
#import "MCell.h"
#import "MTextFieldCell.h"
#import "UserDefaults.h"
#import "Const.h"
#import "MSelectController.h"
#import "NSString+Category.h"
#import "MItemListController.h"
#import "Item.h"
#import "Utility.h"
@interface MConfigController ()

@end

@implementation MConfigController{
    UserDefaults *userDefaults;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self initData];
    }
    return self;
}

-(void) initData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userDefaults = [UserDefaults new];
    
    userDefaults.keyWords = [defaults valueForKey:@"key_words"];
    userDefaults.cityName = [defaults valueForKey:@"city"];
    if ([userDefaults.cityName isEqual:nil]) {
        userDefaults.cityName =@"";
    }
    userDefaults.beginDate = [defaults valueForKey:@"begin_date"];
    userDefaults.endDate = [defaults valueForKey:@"end_date"];
    userDefaults.lowPrice = [defaults valueForKey:@"low_price"];
    userDefaults.upperPrice = [defaults valueForKey:@"upper_price"];
    userDefaults.sortType = [defaults valueForKey:@"sort_type"];
    userDefaults.timeRange = [defaults valueForKey:@"time_range"];
}

-(NSString *)makeURL
{
    NSString *timeRange = userDefaults.timeRange;
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    userDefaults.beginDate = [formatter stringFromDate:now];
    NSTimeInterval timeInterval;
    
    if ([timeRange isEqualToString:ONE_MONTH]) {
        timeInterval = DAY_INTERVAL *30;

    }
    
    if ([timeRange isEqualToString:THREE_MONTH]){
        timeInterval =DAY_INTERVAL *30 *3;
    }
    
    if ([timeRange isEqualToString:HALF_A_YEAR]){
        timeInterval = DAY_INTERVAL *30 * 6;
    }
    
    if ([timeRange isEqualToString:ONE_YEAR]){
        timeInterval = DAY_INTERVAL *30 * 12;
    }
    
    
    NSDate *endDate = [now initWithTimeIntervalSinceNow:timeInterval];
    userDefaults.endDate = [formatter stringFromDate:endDate];
    
    MTextFieldCell *keywordCell = (MTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    userDefaults.keyWords = keywordCell.textField.text;
    
    MTextFieldCell *lowPriceCell = (MTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    if ([lowPriceCell.textField.text isEqualToString:@""]) {
        userDefaults.lowPrice = @"0";
    }
    else
    {
        userDefaults.lowPrice = lowPriceCell.textField.text;
    }
    
    MTextFieldCell  *upperPriceCell = (MTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    if ([upperPriceCell.textField.text isEqualToString:@""]) {
        userDefaults.upperPrice = @"8000";
    }
    else{
        userDefaults.upperPrice =upperPriceCell.textField.text;
    }
    
    if (userDefaults.cityName.length==0) {
        userDefaults.cityName = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].detailTextLabel.text;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:userDefaults.beginDate forKey:@"begin_date"];
    [defaults setValue:userDefaults.endDate forKey:@"end_date"];
    [defaults setValue:userDefaults.keyWords forKey:@"key_words"];
    [defaults setValue:userDefaults.lowPrice forKey:@"low_price"];
    [defaults setValue:userDefaults.upperPrice forKey:@"upper_price"];
    [defaults setValue:userDefaults.cityName forKey:@"city"];
    [defaults synchronize];
    
    
    NSString *str = [NSString stringWithFormat:@"%@%@/?page_index=%d%@&key_words=%@&city=%@&begin_date=%@&=end_date=%@&low_price=%@&upper_price=%@&sort_type=%@",
                     API_BASE_URL,GROUP_LIST_PARAMTER,1,PAGE_SIZE_PARAMTER,
                     [userDefaults.keyWords URLEncode],[userDefaults.cityName URLEncode],
                     userDefaults.beginDate,userDefaults.endDate,
                     userDefaults.lowPrice,userDefaults.upperPrice,
                     userDefaults.sortType];
    
    return str;
}

-(void) doSearch{
    NSString *urlString = [self makeURL];
    [self.network httpJsonResponse:urlString byController:self];
    
}

-(void)setJSON:(id)json fromRequest:(NSURLRequest *)request
{
    
    NSString *path = [[request URL] path];
    
    if ([path isEqualToString:PROVINCE_LIST_PARAMTER]) {
        
        NSArray *dataList = [NSArray arrayWithArray:json];
        
        NSDictionary *dataItem = (NSDictionary *)[dataList lastObject];
        
        if ([[dataItem allKeys] count]==2) {
            MSelectController *controller = [[MSelectController alloc] initWithStyle:UITableViewStyleGrouped];
            
            NSArray *province_list = [[NSArray alloc] init];
            
            for (NSDictionary *dic in (NSArray *)json) {
                NSString *province = [dic valueForKey:@"name"];
                province_list = [province_list arrayByAddingObject:province];
            }
            
            controller.dataList = province_list;
            controller.tag=100;
            controller.title = @"省市自治区";
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if([path isEqualToString:GROUP_LIST_PARAMTER])
    {
        MItemListController *controller = [self.navigationController.viewControllers objectAtIndex:0];
        
        NSArray *newItems = [[Const sharedObject] getProudctItemListFromRequest:request withJSON:json];
        NSInteger count = [[json objectForKey:@"count"] integerValue];
        NSString *city = [[Const sharedObject] getQueryValueFromRequest:request byKey:@"city"];
        NSString *keyWords = [[Const sharedObject] getQueryValueFromRequest:request byKey:@"key_words"];
        
        controller.title = city;
        controller.keyWords = keyWords;
        controller.items = newItems;
        controller.pageIndex = 1;
        controller.itemTotalCount = count;
        
        [controller.tableView reloadData];
        
        [self.navigationController popViewControllerAnimated:YES];
        
                
        
    }
    else
    {
        NSLog(@"@166,%@",json);
        
        [[Utility sharedObject] setAlertView:@"错误" withMessage:@"对不起，找不到您需要的内容..."];
    }
    
}

-(void)resetData{
    [self initData];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"选项";
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(doSearch)];
    
    self.navigationItem.rightBarButtonItem = btnDone;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self resetData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog (@"should return?");
    [textField resignFirstResponder];
    return YES;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        static NSString *cellIndentifier = @"MTextFieldCell";
        
        MTextFieldCell *cell = (MTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MTextFieldCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        if (row == 0) {
            cell.textField.placeholder = @"请输入查询关键字...";
            
            if (userDefaults.keyWords.length>0) {
                cell.textField.text = userDefaults.keyWords;
                
            }
        }
        else if (row ==1)
        {
            cell.textField.placeholder = @"请输入查询最低价格...";
            
            if (userDefaults.lowPrice!=nil) {
                cell.textField.text = userDefaults.lowPrice;
                cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
                
            }

        
        }
        else if (row ==2){
            cell.textField.placeholder = @"请输入查询最高价格...";
            
            if (userDefaults.upperPrice != nil) {
                cell.textField.text = userDefaults.upperPrice;
                cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            }
        };
        
        cell.textField.delegate = self;
              
        return cell;
    }
    else{
        static NSString *cellIndentifier1 = @"MCell";
        
        MCell *cell = (MCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier1];
        
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        if (row ==0)
        {
            cell.textLabel.text = @"城市";
            
            if (userDefaults.cityName!= nil) {
                cell.detailTextLabel.text =userDefaults.cityName;
            }
            else
            {
                cell.detailTextLabel.text = @"北京";
            }
            
        }
        else if(row == 1)
        {
            cell.textLabel.text = @"范围";
            
            if (userDefaults.endDate!=nil) {
                cell.detailTextLabel.text = [[[Const sharedObject] arrayForTimeRange] objectAtIndex:0];
            }
            else{
                NSLog(@"156@%@",userDefaults.timeRange);
                cell.detailTextLabel.text = userDefaults.timeRange;
            }
            
        }
        else if (row == 2)
        {
            cell.textLabel.text = @"排序";
            if (userDefaults.sortType!=nil) {
                NSString *key = userDefaults.sortType;
                
                cell.detailTextLabel.text = [[[Const sharedObject]dictionaryForSortType] valueForKey:key];
            }
            else{
                NSString *value =[[[Const sharedObject] dictionaryForSortType] valueForKey:@"0"];
                 cell.detailTextLabel.text = value;
            }
        }
        
        return cell;
    }
    
    return nil;
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 1) {
        MSelectController *controller = [[MSelectController alloc] initWithStyle:UITableViewStyleGrouped];
        if (row ==0) {
            //cities
            NSString *strURL = [NSString stringWithFormat:@"%@%@/",API_BASE_URL,PROVINCE_LIST_PARAMTER];
            [self.network httpJsonResponse:strURL byController:self];
            return;
            
        }
        else if(row == 1){
            //time range
            controller.tag=200;
            controller.title = @"范围";
            controller.dataList = [NSArray arrayWithArray:[[Const sharedObject] arrayForTimeRange]];
            
        }
        else if(row == 2)
        {
            //sort type
            controller.tag = 201;
            controller.title = @"排序";
            controller.dataList = [[[Const sharedObject] dictionaryForSortType] allValues];
            
        }
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
 }



@end
