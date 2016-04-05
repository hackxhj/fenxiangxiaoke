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
@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *personNameArrary;
    NSMutableString *itemValue;
    NSString *xmlpramStr;

}


-(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
    
    NSDictionary *userPassdic=@{@"M5":@"+86",@"M2":@"a12345",@"M1":@"18665354221"};
    
    xmlpramStr=[self getMyxmlStr:userPassdic:@"4166989841"];
 }



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



- (IBAction)loginAction:(id)sender {
 

     [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM0AXUL/Authorize/PersonalLogin/iOS.55?_vn=55&_ov=8.3&_postid=-25449443&traceId=E-E..-08AEC323-E70C-4020-BA55-EE4D6C786D78" params:xmlpramStr success:^(id responseObj) {
        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
         [self MyParserXml:result];
         NSLog(@"%@",result);
         
        [self cookieValueWithKey:@"FSAuthXG"];
    } failure:^(NSError *error) {
        
    }];
 
    
}

- (NSString *)cookieValueWithKey:(NSString *)key
{
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    if ([sharedHTTPCookieStorage cookieAcceptPolicy] != NSHTTPCookieAcceptPolicyAlways) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    
    NSArray         *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:@"https://www.fxiaoke.com/FHE/EM0AXUL/Authorize/PersonalLogin/iOS.55?_vn=55&_ov=8.3&_postid=-25449443&traceId=E-E..-08AEC323-E70C-4020-BA55-EE4D6C786D78"]];
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"LOGINCOKIES"];
    
    
    NSEnumerator    *enumerator = [cookies objectEnumerator];
    NSHTTPCookie    *cookie;
    while (cookie = [enumerator nextObject]) {
        if ([[cookie name] isEqualToString:key]) {
            return [NSString stringWithString:[[cookie value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
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
        NSLog(@"Result  type: %@",atr);
        if([atr isEqualToString:@"0"])
        {
            
            [self showSuccessMsg];
        }
    }
    
    if ( [elementName isEqualToString:@"Data"] ) {
        NSString *atr=[attributeDict valueForKey:@"DataType"];
        NSLog(@"DataType  type: %@",atr);
    }
    
    
}


-(void)showSuccessMsg
{
    
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"提示"message:@"登陆成功"preferredStyle:UIAlertControllerStyleAlert];
    
  
    
    UIAlertAction*otherAction = [UIAlertAction actionWithTitle:@"OK"style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
        NSLog(@"确定");
    }];
  
    // Add the actions.
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
    
}
- (void)paser:parserErrorOccured
{
    NSLog(@"error_____");
}


- (IBAction)getInfoAction:(id)sender
{
    NSDictionary *driveInfo=@{@"M1":@2,@"M3":@"5A7F6DBD-7DD9-4332-947A-2A21E7FAC9F9",@"M4":@0,@"M5":@"iPhone6"};
  NSDictionary*infodic=@{@"M3":@"&#x5E7F;&#x4E1C;&#x7701;&#x6DF1;&#x5733;&#x5E02;",@"M1":@384370,@"M2":driveInfo};
    
    NSString  *tempstr=[self getMyxmlStr:infodic:@"701070970"];
 
    
    [self setCookies];

 
    [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM0AXUL/Authorize/EnterpriseUserLogin/iOS.55?_vn=55&_ov=8.3&_postid=-1575664558&traceId=E-E..-69F10DFB-09E0-4E0E-A455-2DB1A15D61C4" params:tempstr success:^(id responseObj) {
        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
        [self MyParserXml:result];
 
        [self cookieValueWithKey:@"FSAuthXG"];
    } failure:^(NSError *error) {
        
    }];
}



- (IBAction)clockAction:(id)sender {
    
    //m11 纬度
    //m12 精度
    //m15 1,
    //m10 0   上班   1 是下班
    
    
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    NSDictionary *dic=@{@"M27":@"2016-04-05",
                        @"M16":@"&#x7B7E;&#x5230;&#x8BBE;&#x5907;&#x5DF2;&#x8D8A;&#x72F1;",
                        @"M22" : @"",
                        @"M11" : @22.674354,
                        @"M25" : @"",
                        @"M20" : @"",
                        @"M23" : @"",
                        @"M12" : @114.064365,
                        @"M15" : @1,
                        @"M10" : @1,
                        @"M21" : @"",
                        @"M24" : @""};
    
     NSString  *tempstr=[self getMyxmlStr:dic:@"1461189364"];
    
      [self setCookies];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"FSAuthXRef" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"E.384370.1000" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"www.fxiaoke.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
 

    [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM1AKaoQin/KaoQinApi/create/iOS.55?_vn=55&_ov=8.3&_postid=92695926&traceId=E-E.384370.1000-E7DE2828-098C-4D87-BD38-EE815FC7F73D" params:tempstr success:^(id responseObj) {
        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
        [self MyParserXml:result];
        
        [self cookieValueWithKey:@"FSAuthXG"];
    } failure:^(NSError *error) {
        
    }];
}



-(void)setCookies
{
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"LOGINCOKIES"];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
}

- (IBAction)getclockInfo:(id)sender {
    
    NSDictionary *dic=@{@"M10": @6774112448};
    NSString  *tempstr=[self getMyxmlStr:dic:@"4213624291"];

    [self setCookies];
    [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM1AKaoQin/KaoQinApi/getCheckinsRule/iOS.55?_vn=55&_ov=8.3&_postid=-1894177654&traceId=E-E.384370.1000-FE91ECCD-9943-48EB-9E1F-A081C153D6AC" params:tempstr success:^(id responseObj) {
        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
        [self MyParserXml:result];
        
        [self cookieValueWithKey:@"FSAuthXG"];
    } failure:^(NSError *error) {
        
    }];
    
}
- (IBAction)getClockinfo2:(id)sender {
    
    NSDictionary *dic=@{@"M10": @"2016-04-05"};
    NSString  *tempstr=[self getMyxmlStr:dic:@"3570815973"];
    
    [self setCookies];
    [HttpRequest post:@"https://www.fxiaoke.com/FHE/EM1AKaoQin/KaoQinApi/getDailyInfo/iOS.55?_vn=55&_ov=8.3&_postid=-1614267203&traceId=E-E.384370.1000-C19DC36D-870C-48E8-BAEF-9D3A1647DFF1" params:tempstr success:^(id responseObj) {
        NSString *result = [[NSString alloc] initWithData:responseObj  encoding:NSUTF8StringEncoding];
        [self MyParserXml:result];
        
        [self cookieValueWithKey:@"FSAuthXG"];
    } failure:^(NSError *error) {
        
    }];
}

@end
