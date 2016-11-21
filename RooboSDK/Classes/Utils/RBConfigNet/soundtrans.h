//
//  soundtrans.h
//  TestVoiceConfigNet
//
//  Created by Zhi Kuiyu on 16/1/4.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//




#ifndef soundtrans_h
#define soundtrans_h
#ifdef __cplusplus

#ifdef    __OBJC__
#import <UIKit/UIKit.h>

#endif // __OBJC__

extern "C" {
#endif

    
     int createWifiWarFile(NSString * wifiName ,NSString * wifiPsd,NSString * settingID,NSString * path);
#ifdef __cplusplus
}
#endif
#endif