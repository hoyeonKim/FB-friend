//
//  ViewController.m
//  FB-friend
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define FACEBOOK_APPID @"394567327345826"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic)ACAccount *facebookAccount;
@property(strong,nonatomic)NSArray *data;
@property(weak,nonatomic)IBOutlet UITableView *table;

@end

@implementation ViewController

-(void)showFriendList{
    ACAccountStore *store = [[ACAccountStore alloc]init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey:FACEBOOK_APPID,ACFacebookPermissionsKey: @[@"basic_info"],ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if(error){
            NSLog(@"Error : %@",error);
        }
        if(granted){
            NSLog(@"승인성공");
            NSArray *accounList = [store accountsWithAccountType:accountType];
            self.facebookAccount = [accounList lastObject];
            [self requestFriendList];
        }
        else{
            NSLog(@"권한 승인 실패");
        }
    }];
    
}
-(void)requestFriendList{
    NSString *urlStr = @"https://graph.facebook.com/me/friends";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *params = nil;
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error){
        if(nil!=error){
            NSLog(@"Error : %@", error);
            return;
        }
        __autoreleasing NSError *parseError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        self.data = result[@"data"];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self.table reloadData];
        }];
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.data count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FEED-CELL"];
    NSDictionary *one = self.data[indexPath.row];
    
    NSString *contents;
    if(one[@"name"]){
   
        contents = [NSString stringWithFormat:@"%@",one[@"name"]];
    }
    else{
        contents = one[@"story"];
        cell.indentationLevel=2;
        
    }
    cell.textLabel.text = contents;
    return cell;
}
-(void)viewWillAppear:(BOOL)animated{
    [self showFriendList];
}- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
