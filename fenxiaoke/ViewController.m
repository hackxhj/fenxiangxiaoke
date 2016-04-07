//
//  ViewController.m
//  fenxiaoke
//
//  Created by 余华俊 on 16/4/5.
//  Copyright © 2016年 hackxhj. All rights reserved.
//

#import "ViewController.h"
#import "HttpRequest.h"
#import "GDataXMLNode.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface ViewController ()

@end

//"M12" : 22.587006,
//"M13" : 113.930709,

//"M2" : 22.586514,
//"M3" : 113.929489,
#define  USERNAME @"18665354221"
#define  PASSWORD @"a12345"

#define  COOKKEY  [NSString stringWithFormat:@"%@COOK",USERNAME]
#define  WEIDU  [NSString stringWithFormat:@"%@WEIDU",USERNAME]
#define  JD  [NSString stringWithFormat:@"%@JD",USERNAME]

@implementation ViewController
{
    NSMutableArray *personNameArrary;
    NSMutableString *itemValue;
    NSString *xmlpramStr;
    BOOL isLogink;
}


-(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
 
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setInputFild];
    NSDictionary *userPassdic=@{@"M5":@"+86",@"M2":PASSWORD,@"M1":USERNAME};
    xmlpramStr=[self getMyxmlStr:userPassdic:@"4166989841"];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:1.2];
    [self panduanSXBan];
 }


-(void)panduanSXBan
{
     NSDate *now = [NSDate date];
     NSCalendar *calendar = [NSCalendar currentCalendar];
     NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
     NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    int hour = [dateComponent hour];
    
     NSLog(@"%d",hour);
    
    if(hour>0&&hour<=12)
    {
        self.switcher.on=YES;
    }else
    {
        self.switcher.on=NO;
    }
}

#pragma  mark  构造xml 文件格式
-(NSString*)getMyxmlStr:(NSDictionary*)dic:(NSString*)postID
{
    NSString *jsonStr=[self dictionaryToJson:dic];
    
    // 创建一个根标签
    GDataXMLElement *rootElement = [GDataXMLNode elementWithName:@"FHE"];
    
    GDataXMLElement *elementTicket = [GDataXMLNode elementWithName:@"Tickets"];
 
    GDataXMLElement *elementPostId = [GDataXMLNode elementWithName:@"PostId"];
 
    [elementPostId setStringValue:postID];
    
    GDataXMLElement *elementData = [GDataXMLNode elementWithName:@"Data"];
    
    [elementData setStringValue:jsonStr];
    
    GDataXMLElement *elementDataattribute = [GDataXMLNode attributeWithName:@"DataType" stringValue:@"Json/P"];
    
    [elementData addAttribute:elementDataattribute];
    
    
    [rootElement addChild:elementTicket];
    [rootElement addChild:elementPostId];
    [rootElement addChild:elementData];
 
    // 生成xml文件内容
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:rootElement];
    NSData *data1 = [xmlDoc XMLData];
    NSString *xmlString = [[NSString alloc] initWithData:data1 encoding:NSASCIIStringEncoding];
    NSLog(@"xmlString  %@", xmlString);
    return xmlString;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
 
}

-(void)clearnAllCookies
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:COOKKEY];
    
    NSURL *url = [NSURL URLWithString:@"https://www.fxiaoke.com"];
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            
        }
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (IBAction)loginAction:(id)sender {
 

    [SVProgressHUD show];
    [self clearnAllCookies];
    
    NSString *loginUrlStr=@"https://www.fxiaoke.com/FHE/EM0AXUL/Authorize/PersonalLogin/iOS.55?_vn=55&_ov=8.3&_postid=-25449443&traceId=E-E..-08AEC323-E70C-4020-BA55-EE4D6C786D78";
    
    __weak ViewController *weakSelf=self;
     [HttpRequest post:loginUrlStr params:xmlpramStr success:^(id responseObj) {
        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
         [weakSelf MyParserXml:result];
         
         [weakSelf setcookieValueWithUrl:loginUrlStr];
         
  
    } failure:^(NSError *error) {
        
    }];
 
    
}

- (NSString *)setcookieValueWithUrl:(NSString *)url
{
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    if ([sharedHTTPCookieStorage cookieAcceptPolicy] != NSHTTPCookieAcceptPolicyAlways) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    
    NSArray   *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:url]];
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:COOKKEY];
    
    
//    NSEnumerator    *enumerator = [cookies objectEnumerator];
//    NSHTTPCookie    *cookie;
//    while (cookie = [enumerator nextObject]) {
//        if ([[cookie name] isEqualToString:key]) {
//            return [NSString stringWithString:[[cookie value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        }
//    }
//    
    return nil;
}



-(void)MyParserXml:(NSString*)xmlstr
{
    NSXMLParser *parser=[[NSXMLParser alloc] initWithData:[xmlstr dataUsingEncoding:NSUTF8StringEncoding]];
    [parser setDelegate:self];//设置NSXMLParser对象的解析方法代理
    [parser setShouldProcessNamespaces:NO];
    [parser parse];//开始解析
    
 
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    NSLog(@"xml_parser start %@ ",elementName);
    if ( [elementName isEqualToString:@"FHE"] ) {
         if(personNameArrary==nil){
            personNameArrary=[[NSMutableArray alloc] init];
        }
    }
    
    if(itemValue!=nil){
        itemValue=nil;
    }
    itemValue=[[NSMutableString alloc] init];
    
    if ( [elementName isEqualToString:@"Result"] ) {
        NSString *atr=[attributeDict valueForKey:@"Status"];
        NSString *msg=[attributeDict valueForKey:@"Msg"];
        
        NSLog(@"Result  type: %@",atr);
        if(![atr isEqualToString:@"0"])
        {
             [self showMsg:msg];
            [SVProgressHUD dismiss];
        }else
        {
              isLogink=YES;
        }
    }
    
    if ( [elementName isEqualToString:@"Data"] ) {
        NSString *atr=[attributeDict valueForKey:@"DataType"];
        NSLog(@"DataType  type: %@",atr);
    }
    
    
}


-(void)showMsg:(NSString*)msgStr
{
    
    if(msgStr==nil)
    {
        msgStr=@"错误";
    }
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"提示"message:msgStr preferredStyle:UIAlertControllerStyleAlert];
 
    UIAlertAction*otherAction = [UIAlertAction actionWithTitle:@"OK"style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
        NSLog(@"确定");
    }];
  
    
     [alertController addAction:otherAction];
    
     [self presentViewController:alertController animated:YES completion:nil];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
     [itemValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
 
    
    if ( [elementName isEqualToString:@"FHE"] ) {
           NSLog(@"xml_parser person end:%@",itemValue);
    }
    
    NSDictionary *dic=[self dictionaryWithJsonString:itemValue];
    if(dic==nil)
        return;
    BOOL isYzm=[dic[@"M1"] boolValue];
    if(isYzm==YES)
    {
        [self showMsg:@"登陆失败！需要验证码"];
        [SVProgressHUD dismiss];
    }else if(isLogink==YES&&isYzm==NO)
    {
        [self getInfoAction:nil];
    }else
    {
        [self showMsg:@"登陆失败！"];
          [SVProgressHUD dismiss];
    }
    
}


- (IBAction)getInfoAction:(id)sender
{
    
    
    NSString *getinfoUrlstr=@"https://www.fxiaoke.com/FHE/EM0AXUL/Authorize/EnterpriseUserLogin/iOS.55?_vn=55&_ov=8.3&_postid=-1575664558&traceId=E-E..-69F10DFB-09E0-4E0E-A455-2DB1A15D61C4";
    
    NSDictionary *driveInfo=@{@"M1":@2,@"M3":@"5A7F6DBD-7DD9-4332-947A-2A21E7FAC9F9",@"M4":@0,@"M5":@"iPhone6"};
    NSDictionary*infodic=@{@"M3":@"&#x5E7F;&#x4E1C;&#x7701;&#x6DF1;&#x5733;&#x5E02;",@"M1":@384370,@"M2":driveInfo};
    
    NSString  *tempstr=[self getMyxmlStr:infodic:@"701070970"];
 
    
    [self setCookies];

      __weak ViewController *weakSelf=self;
    
    [HttpRequest post:getinfoUrlstr params:tempstr success:^(id responseObj) {
        [SVProgressHUD showSuccessWithStatus:@"登陆成功！"];

        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
//        [self MyParserXml:result];
         [weakSelf setcookieValueWithUrl:getinfoUrlstr];
 
     } failure:^(NSError *error) {
        
    }];
}



- (IBAction)clockAction:(id)sender {
    
    //m11 纬度
    //m12 精度
    //m10 0   上班   1 是下班
   
    
    if([self.weiduInput.text isEqualToString:@""]||[self.jdInput.text isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"经纬度不能为空！"];
        return;
    }
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    double weidu=[self.weiduInput.text doubleValue];
    NSNumber *weidun=[NSNumber numberWithDouble:weidu];
    double jd=[self.jdInput.text doubleValue];
    NSNumber *jdn=[NSNumber numberWithDouble:jd];
    
    NSNumber *sxb;
    if(self.switcher.isOn)
        sxb=@0;
    else
        sxb=@1;
    
    NSDictionary *dic=@{@"M27":locationString,
                        @"M16":@"&#x7B7E;&#x5230;&#x8BBE;&#x5907;&#x5DF2;&#x8D8A;&#x72F1;",
                        @"M22" : @"",
                        @"M11" : weidun,//weidun
                        @"M25" : @"",
                        @"M20" : @"",
                        @"M23" : @"",
                        @"M12" :jdn,//jdn
                        @"M15" : @1,
                        @"M10" : sxb,
                        @"M21" : @"",
                        @"M24" : @""};
    
     NSString  *tempstr=[self getMyxmlStr:dic:@"1461189364"];
    
      [self setCookies];
    // [self setMycooikes];
    
 
    [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM1AKaoQin/KaoQinApi/create/iOS.55?_vn=55&_ov=8.3&_postid=-1600297098&traceId=E-E.chinatave.1136-7F9E5FBC-7632-4C64-9B62-886BBC29B7B" params:tempstr success:^(id responseObj) {
        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
 
       NSString *jsonstr=[self getXmlinJsonStr:result];
       NSDictionary *m11dic=[self dictionaryWithJsonString:jsonstr];
       int sta=[m11dic[@"M11"] intValue];
       if(sta==1)
       {
            NSString *isbb= [sxb isEqualToNumber:@0]?@"上班":@"下班";
           [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@-打卡成功",isbb]];
           [self saveInputFild:weidun:jdn];
       }else
       {
           [SVProgressHUD showErrorWithStatus:@"打卡失败（或已经打卡了）"];
       }
     } failure:^(NSError *error) {
        
    }];
}

-(void)setInputFild
{
    NSNumber  *weidu=[[NSUserDefaults standardUserDefaults]objectForKey:WEIDU];
    NSNumber  *jingdu=[[NSUserDefaults standardUserDefaults]objectForKey:JD];
    if(weidu==nil||jingdu==nil)
        return;
    
    self.weiduInput.text=[NSString stringWithFormat:@"%@",weidu];
    self.jdInput.text=[NSString stringWithFormat:@"%@",jingdu];

}




-(void)saveInputFild:(NSNumber*)weiduStr:(NSNumber*)jingduStr
{
    [[NSUserDefaults standardUserDefaults]setObject:weiduStr forKey:WEIDU];
    [[NSUserDefaults standardUserDefaults]setObject:jingduStr forKey:JD];
    [[NSUserDefaults standardUserDefaults]synchronize];
}



-(NSString*)getXmlinJsonStr:(NSString*)xmlStr
{
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *array = [xmlEle children];
    NSLog(@"count : %d", [array count]);
    for (int i = 0; i < [array count]; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];

        if ([[ele name] isEqualToString:@"Data"]) {
            return [ele stringValue];
        }
        
    }
    return nil;
    
}

/*-(void)setMycooikes
{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"FSAuthX" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"0G606155Mm40002ujX7pCn5kRm4a221POUmpZ4VZ9UiICEUxCUz1F5HgN2ZZKV6KwXnUfQAm4hHe8f6F3XAzwKZaojh1oXhquNGmzV5qQRTKiug5pYn4IYZOhvivW7tp09BXnCwVIYzlZ1htuxr7ZmPaybSBeWyRyjyKqvTgeRvyNyhPVNkBLOtC81zPVjQkDfHV7zm1yTwD8ede57s1TtiO4GMRyjy3iOBWECt3ym4L05Z0LSYF7Gszi4PT2DA5e1eRccHyWYF3s813w4" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
     NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
 
    NSMutableDictionary *cookieProperties1 = [NSMutableDictionary dictionary];
    [cookieProperties1 setObject:@"FSAuthXG" forKey:NSHTTPCookieName];
    [cookieProperties1 setObject:@"o020jDw7L040000OHWXt4nmpveAeRfEyG32vabBymmijx5254Rajz6mwVoICrDJIuKoIzhlsqyqbCun3" forKey:NSHTTPCookieValue];
    [cookieProperties1 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieDomain];
    [cookieProperties1 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties1 setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties1 setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie1 = [NSHTTPCookie cookieWithProperties:cookieProperties1];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie1];
 
    NSMutableDictionary *cookieProperties4 = [NSMutableDictionary dictionary];
    [cookieProperties4 setObject:@"sso_token" forKey:NSHTTPCookieName];
    [cookieProperties4 setObject:@"b83e064b506041919b47be485214f2d9" forKey:NSHTTPCookieValue];
    [cookieProperties4 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieDomain];
    [cookieProperties4 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties4 setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties4 setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie4 = [NSHTTPCookie cookieWithProperties:cookieProperties4];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie4];
 
    NSMutableDictionary *cookieProperties2 = [NSMutableDictionary dictionary];
    [cookieProperties2 setObject:@"RouteUp" forKey:NSHTTPCookieName];
    [cookieProperties2 setObject:@"" forKey:NSHTTPCookieValue];
    [cookieProperties2 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieDomain];
    [cookieProperties2 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties2 setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties2 setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie2 = [NSHTTPCookie cookieWithProperties:cookieProperties2];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie2];
 
    NSMutableDictionary *cookieProperties3 = [NSMutableDictionary dictionary];
    [cookieProperties3 setObject:@"FSAuthXC" forKey:NSHTTPCookieName];
    [cookieProperties3 setObject:@"" forKey:NSHTTPCookieValue];
    [cookieProperties3 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieDomain];
    [cookieProperties3 setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties3 setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties3 setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie3 = [NSHTTPCookie cookieWithProperties:cookieProperties3];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie3];

}*/


-(void)setCookies
{
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:COOKKEY];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
}

- (IBAction)getclockInfo:(id)sender {
    
//    NSDictionary *dic=@{@"M10": @6774112448};
//    NSString  *tempstr=[self getMyxmlStr:dic:@"4213624291"];
//
//    [self setCookies];
//    [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM1AKaoQin/KaoQinApi/getCheckinsRule/iOS.55?_vn=55&_ov=8.3&_postid=-1894177654&traceId=E-E.384370.1000-FE91ECCD-9943-48EB-9E1F-A081C153D6AC" params:tempstr success:^(id responseObj) {
//        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
//        [self MyParserXml:result];
//        
//     } failure:^(NSError *error) {
//        
//    }];
    
}
- (IBAction)getClockinfo2:(id)sender {
    
//    NSDictionary *dic=@{@"M10": @"2016-04-05"};
//    NSString  *tempstr=[self getMyxmlStr:dic:@"3570815973"];
//    
//    [self setCookies];
//    [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM1AKaoQin/KaoQinApi/getDailyInfo/iOS.55?_vn=55&_ov=8.3&_postid=-1614267203&traceId=E-E.384370.1000-C19DC36D-870C-48E8-BAEF-9D3A1647DFF1" params:tempstr success:^(id responseObj) {
//        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
//        [self MyParserXml:result];
//        
//     } failure:^(NSError *error) {
//        
//    }];
}

@end
