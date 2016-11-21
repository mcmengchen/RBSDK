//
//  RBViewController.m
//  RooboSDK
//
//  Created by baxiang on 11/12/2016.
//  Copyright (c) 2016 baxiang. All rights reserved.
//

#import "RBViewController.h"
#import "RBUserApi.h"
#import "RBDeviceApi.h"
#import "PDPlayVideo.h"

@interface RBViewController ()<UITableViewDelegate,UITableViewDataSource>
/** 导航 */
@property (nonatomic, weak) UIView * rb_demo_navView;
/** 测试列表 */
@property (nonatomic, weak) UITableView  * rb_demo_tableView;
/** 测试用户api数据源 */
@property (nonatomic, strong) NSMutableArray * rb_demo_user_dataArray;
/** 测试设备api数据源 */
@property (nonatomic, strong) NSMutableArray * rb_demo_device_dataArray;
@end

@implementation RBViewController

#pragma mark - 创建 -> 测试导航栏
-(UIView *)rb_demo_navView{
    if (!_rb_demo_navView) {
        UIView * vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
        vi.backgroundColor = [UIColor orangeColor];
        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 200, 44)];
        lab.text = @"Roobo Demo";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor whiteColor];
        lab.center = CGPointMake(vi.frame.size.width*0.5, 20+lab.frame.size.height*0.5);
        [vi addSubview:lab];
        [self.view addSubview:vi];
        _rb_demo_navView = vi;
    }
    return _rb_demo_navView;
}
#pragma mark - 创建 -> 测试列表
-(UITableView *)rb_demo_tableView{
    if (!_rb_demo_tableView) {
        UITableView * vi = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.rb_demo_navView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.rb_demo_navView.frame)) style:UITableViewStylePlain];
        vi.delegate = self;
        vi.dataSource = self;
        [self.view addSubview:vi];
        _rb_demo_tableView = vi;
    }
    return _rb_demo_tableView;
}

#pragma mark - 创建 -> 测试用户 api 数据源
-(NSMutableArray *)rb_demo_user_dataArray{
    if (!_rb_demo_user_dataArray) {
        NSMutableArray * arr = [NSMutableArray arrayWithObjects:@"登陆",@"注册",@"忘记密码",@"修改密码",@"修改手机号",@"修改其他用户名称",@"修改用户名称",@"上传图片",@"退出登陆", nil];
        _rb_demo_user_dataArray = arr;
    }
    return _rb_demo_user_dataArray;
}


#pragma mark - 创建 -> 测试设备 api 数据源
-(NSMutableArray *)rb_demo_device_dataArray{
    if (!_rb_demo_device_dataArray) {
        NSMutableArray * arr = [NSMutableArray arrayWithObjects:@"打开设备声波配网功能",@"播放声波配网文件",@"开始获取绑定配网结果",@"开始获取修改网络结果",@"更改管理员",@"删除所绑定的设备", @"添加其他用户到设备成员组", @"从当前设备成员组中删除用户", @"获取当前用户的所有设备", @"获取设备硬件信息", @"获取设备的信息", @"发送表情", @"发送文本内容", @"旋转设备",@"重启设备", @"开启安全防护", @"修改设备的安防时间段", @"设置夜间模式开关", @"修改设备的名称",@"进入视频连接成功的声音开关", @"修改设备音量", @"修改设备声音音色",  nil];
        _rb_demo_device_dataArray = arr;
    }
    return _rb_demo_device_dataArray;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark ------------------- UITableViewDelegate ------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"用户 API";
    }else{
        return @"设备 API";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.rb_demo_user_dataArray.count;

    }else{
        return self.rb_demo_device_dataArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = self.rb_demo_user_dataArray[indexPath.row];
    }else{
        cell.textLabel.text = self.rb_demo_device_dataArray[indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    static NSString * deviceId = @"1011000000200BAE";
    static NSString * wifiName = @"roobo";
    static NSString * wifiPsd = @"roobo@2016";
//    static NSString * userId = @"ps:c412131ab751d4a402fe28f0b9d7d1cf";//18600341822
    static NSString * userId = @"ps:410905cd3be5f9f7623371b9b7089f16";//13341122739

    if (indexPath.section == 0) {
        //用户 api
        NSLog(@"调用 -------------> %@ API",self.rb_demo_user_dataArray[indexPath.row]);
        switch (indexPath.row) {
            case 0:
            {
                //登陆
                [RBUserApi userLogin:^(RBUserModel *userModel, NSError *error) {
                    NSLog(@"登陆结果回调：********");
                    NSLog(@"用户数据 = %@",userModel);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                } Regist:^(RBUserModel *userModel, NSError *error) {
                    NSLog(@"注册结果回调：********");
                    NSLog(@"用户数据 = %@",userModel);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                } Forget:^(BOOL isSucceed, NSError *error) {
                    NSString * str = isSucceed? @"成功":@"失败";
                    NSLog(@"忘记密码回调：********");
                    NSLog(@"重置密码 %@",str);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                }];
            }
                break;
            case 1:
            {
                //注册
                [RBUserApi userRegist:^(RBUserModel *userModel, NSError *error) {
                    NSLog(@"注册结果回调：********");
                    NSLog(@"用户数据 = %@",userModel);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                }];
            }
                break;
            case 2:
            {
                //忘记密码
                [RBUserApi userForgetPsd:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_user_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 3:
            {
                //修改密码
                [RBUserApi userModifyPsd:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_user_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 4:
            {
                //修改手机号
                [RBUserApi userModifyAccount:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_user_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 5:
            {
                
                //修改其他用户名称：(新的名称和之前的名称需不同)
                [RBUserApi updateOthersUserID:userId name:@"newName" completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_user_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 6:
            {
                //修改用户名称:(新的名称和之前的名称需不同)
                [RBUserApi updateUserName:@"newNmae" completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_user_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 7:
            {
                //上传图片
                UIImage * img = [UIImage imageNamed:@"rbTestPig"];
                [RBUserApi uploadUserImg:img progressBlock:^(NSProgress *progress) {
                    NSLog(@"%lld",progress.completedUnitCount);
                } completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_user_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 8:
            {
                //退出登陆
                [RBUserApi logOut:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_user_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            default:
                break;
        }
        
        
        
    } else if (indexPath.section == 1) {
        //设备 api

        NSLog(@"调用 -------------> %@ API",self.rb_demo_device_dataArray[indexPath.row]);
        switch (indexPath.row) {
            case 0:
            {
                //打开设备声波配网
                [RBDeviceApi openVoiceConfigNetWithDeviceID:deviceId type:RBModifyNetType_BindDevice completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 1:
            {
                //播放声波配网文件
                [RBDeviceApi playVoiceConfigNetFileWithWifiName:wifiName wifiPsd:wifiPsd];
            }
                break;
            case 2:
            {
                //获取绑定配网结果
                [RBDeviceApi startGetVoiceConfigNetResultBlock:^(BOOL isSucceed, NSDictionary *dict, NSError *error) {
                    NSString * str = isSucceed? @"成功":@"失败";
                    NSLog(@"绑定配网结果回调：********");
                    NSLog(@"绑定配网 %@",str);
                    NSLog(@"dict == %@\n  error = %@",dict,error);
                    NSLog(@"msg = %@",[dict objectForKey:@"msg"]);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                }];
            }
                break;
            case 3:
            {
                //获取修改网络结果
                [RBDeviceApi startGetModifyNetResultBlock:^(BOOL isSucceed, NSDictionary *dict, NSError *error) {
                    NSString * str = isSucceed? @"成功":@"失败";
                    NSLog(@"修改网络结果回调：********");
                    NSLog(@"修改网络 %@",str);
                    NSLog(@"dict == %@\n  error = %@",dict,error);
                    NSLog(@"msg = %@",[dict objectForKey:@"msg"]);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                }];
            }
                break;
            case 4:
            {
                //修改管理员
                [RBDeviceApi changeManager:deviceId userID:userId completionBlock:^(bool isSucceed, NSError * error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 5:
            {
                //删除所绑定的设备
                [RBDeviceApi deleteOwnDevice:deviceId completionBlock:^(bool isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
                
            }
                break;
            case 6:
            {
                //添加其他用户到设备成员组中（邀请成员）
                NSString * userPhone = @"18600341822";
                [RBDeviceApi addUser:userPhone deviceID:deviceId completionBlock:^(id response, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] Response:response error:error];
                }];
            }
                break;
            case 7:
            {
                //从当前设备成员组中删除用户
                [RBDeviceApi deleteUser:userId deviceID:deviceId completionBlock:^(id response, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] Response:response error:error];
                }];
            }
                break;
            case 8:
            {
                //获取当前用户的所有设备
                [RBDeviceApi fetchAllDevices:^(NSArray<RBDeviceModel *> *device, NSError *error) {
                    NSLog(@"%@结果回调：********",self.rb_demo_device_dataArray[indexPath.row]);
                    NSLog(@"device =  %@",device);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                }];
                
            }
                break;
            case 9:
            {
                //获取设备硬件信息
                [RBDeviceApi fetchHardwareInfo:deviceId completion:^(RBHardware *device, NSError *error) {
                    NSLog(@"%@结果回调：********",self.rb_demo_device_dataArray[indexPath.row]);
                    NSLog(@"device =  %@",device);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                    
                }];
                
            }
                break;
            case 10:
            {
                //获取设备详情
                [RBDeviceApi fetchDeviceDetail:deviceId completionBlock:^(RBDevicesDetail *detail, NSError *error) {
                    NSLog(@"%@结果回调：********",self.rb_demo_device_dataArray[indexPath.row]);
                    NSLog(@"detail =  %@",detail);
                    NSLog(@"error = %@",error);
                    NSLog(@"End：********");
                }];
            }
                break;
            case 11:
            {
                //发送表情
                [RBDeviceApi sendEmoji:deviceId emojiType:RBEmoji_Moe completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 12:
            {
                //发送文本内容
                [RBDeviceApi sendTTS:deviceId content:@"content" completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 13:
            {
                //旋转设备
                [RBDeviceApi rotateDevice:deviceId angle:180 completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 14:
            {
                //重启设备
                [RBDeviceApi restart:deviceId completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 15:
            {
                //开关安全防护
                [RBDeviceApi switchSafetyState:deviceId isOn:true completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 16:
            {
                //修改设备的安防时间段
                 [RBDeviceApi updateSafetyTime:deviceId startTime:@"09:00" endTime:@"12:00" completionBlock:^(BOOL isSucceed, NSError *error) {
                     [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                 }];
                
            }
                break;
            case 17:
            {
                //设置夜间模式开关
                [RBDeviceApi updateNightMode:deviceId nightSetting:RBNightSettingSwitch switchState:true startTime:@"09:00" endTime:@"12:00" completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
                
            }
                break;
            case 18:
            {
                //修改设备名称
                [RBDeviceApi updateDeviceName:deviceId name:@"newDeviceName" completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
            case 19:
            {
                //进入视频连接成功的声音开关
                [RBDeviceApi switchVideoConnetVoice:deviceId isOn:true completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
                
            }
                break;
            case 20:
            {
                //修改设备音量
                [RBDeviceApi updateVolume:deviceId voice:100 completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
                
            }
                break;
            case 21:
            {
                //修改设备音色
                [RBDeviceApi updateSound:deviceId soundName:@"NANNAN" completionBlock:^(BOOL isSucceed, NSError *error) {
                    [self rb_log_ResultWithDetail:self.rb_demo_device_dataArray[indexPath.row] isSucceed:isSucceed error:error];
                }];
            }
                break;
                
            default:
                break;
        }
        
        
        
    }
}


#pragma mark - action: 打印
- (void)rb_log_ResultWithDetail:(NSString *)detail isSucceed:(BOOL)isSucceed error:(NSError *)error{
    NSString * str = isSucceed? @"成功":@"失败";
    NSLog(@"%@结果回调：********",detail);
    NSLog(@"%@ %@",detail,str);
    NSLog(@"error = %@",error);
    NSLog(@"End：********");
    UIAlertView * vi = [[UIAlertView alloc]initWithTitle:detail message:[NSString stringWithFormat:@"%@结果 = %@\n error = %@",detail,str,error] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [vi show];
}


- (void)rb_log_ResultWithDetail:(NSString *)detail Response:(id)response error:(NSError*)error{
    NSLog(@"%@结果回调：********",detail);
    NSLog(@"response =  %@",response);
    NSLog(@"error = %@",error);
    NSLog(@"End：********");
    UIAlertView * vi = [[UIAlertView alloc]initWithTitle:detail message:[NSString stringWithFormat:@"%@\n response = %@\n error = %@",detail,response,error] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [vi show];
    
}


#pragma mark ------------------- LifeCycle ------------------------
#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rb_demo_navView.hidden = false;
    self.rb_demo_tableView.hidden = false;
    
    
}








@end
