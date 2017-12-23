//
//  controller.m
//  LogiTowLib
//
//  Created by Trychen on 17/12/10.
//
//

#import <Foundation/Foundation.h>
#include "controller.h"
#import "LogiTowLib.h"

@implementation Controller : NSObject {
    BabyBluetooth *baby;
    JavaVM *jvm;
    jclass jni_ble_class;
}

+ (instancetype)sharedController {
    static Controller *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[Controller alloc]init];
    });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self babyDelegate];
    }
    return self;
}

/*
 开始搜索
 */
- (void)startScan {
    baby.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().begin();
    NSLog(@"Started scaning for logitow devices");
}

/*
 停止搜索
 */
- (void)stopScan {
    [baby cancelScan];
    NSLog(@"Cry off scaning");
}

/*
 断开连接，并重新搜索？
 */
- (void) disconnect: (jboolean) restartScan {
    [baby cancelAllPeripheralsConnection];
    if (restartScan) {
        [self startScan];
    }
}

/*
 配置JNI
 */
- (void)setupJNI:(JNIEnv *)env ble_class:(jclass)class {
    if (jni_ble_class != NULL && jvm != NULL) {
        (*env)->DeleteGlobalRef(env, jni_ble_class);
    }
    
    if (jvm == NULL) (*env)->GetJavaVM(env, &jvm);

    jni_ble_class = (*env)->NewGlobalRef(env, class);
    
    (*env)->DeleteLocalRef(env, class);
}
/*
 通知 BLE Stack 已连接成功
 */
- (void)notifyConnected: (NSString *) uuid {
    if (jvm == NULL) {
        NSLog(@"Could't find JVM to get JNIEnv while notifyConnected");
        return;
    }
    JNIEnv *env;
    (*jvm)->GetEnv(jvm, (void**) &env, JNI_VERSION_1_4);
    if (env == NULL) {
        NSLog(@"Could't get JNIEnv while notifyConnected");
        return;
    }
    jmethodID notify_connected_funid = (*env)->GetStaticMethodID(env, jni_ble_class,"notifyConnected","(Ljava/lang/String;)V");
    if (notify_connected_funid == NULL) {
        NSLog(@"Could't get methodid for notifyConnected()V while notifyConnected");
        return;
    }
    
    int length = [uuid length];
    
    unichar uniString[length];
    
    [uuid getCharacters: uniString];
    
    (*env)->CallStaticVoidMethod(env, jni_ble_class, notify_connected_funid, (*env)->NewString(env, uniString, length));
}

/*
 通知 BLE Stack 已断开连接
 */
- (void)notifyDisconnected: (jboolean)rescan {
    if (jvm == NULL) {
        NSLog(@"Could't find JVM to get JNIEnv while notifyDisconnected");
        return;
    }
    JNIEnv *env;
    (*jvm)->GetEnv(jvm, (void**) &env, JNI_VERSION_1_4);
    if (env == NULL) {
        NSLog(@"Could't get JNIEnv while notifyDisconnected");
        return;
    }
    jmethodID notify_disconnected_funid = (*env)->GetStaticMethodID(env, jni_ble_class,"notifyDisconnected","(Z)V");
    if (notify_disconnected_funid == NULL) {
        NSLog(@"Could't get methodid for notifyDisconnected(Z)V while notifyDisconnected");
        return;
    }
    (*env)->CallStaticVoidMethod(env, jni_ble_class, notify_disconnected_funid, rescan);
}


/*
 通知 BLE Stack 获取到了方块数据
 */
- (void)notifyBlockData: (const void *)data {
    if (jvm == NULL) {
        NSLog(@"Could't find JVM to get JNIEnv while notifyBlockData");
        return;
    }
    JNIEnv *env;
    (*jvm)->GetEnv(jvm, (void**) &env, JNI_VERSION_1_4);
    if (env == NULL) {
        NSLog(@"Could't get JNIEnv while notifyBlockData");
        return;
    }
    jmethodID notify_connected_funid = (*env)->GetStaticMethodID(env, jni_ble_class,"notifyBlockData","([B)V");
    if (notify_connected_funid == NULL) {
        NSLog(@"Could't get methodid for notifyBlockData([B)V while notifyBlockData");
        return;
    }
    jbyteArray bytes = (*env)->NewByteArray(env, 7);
    if (bytes == NULL) {
        NSLog(@"Could't new byte array while notifyBlockData");
        return;
    }
    (*env)->SetByteArrayRegion(env, bytes, 0, 7, data);
    (*env)->CallStaticVoidMethod(env, jni_ble_class, notify_connected_funid, bytes);
}

/*
 获取蓝牙状态
 */
- (CBCentralManagerState) bluetoothState {
    return [[baby centralManager] state];
}

/*
 蓝牙网关初始化和委托方法设置
 */
- (void)babyDelegate{
    __weak typeof(baby) weakBaby = baby;
    __weak typeof(self) weakSelf = self;
    
    // 设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        // 设置查找规则是名称为LOGITOW
        if ([peripheralName isEqualToString:@"LOGITOW"]) {
            return YES;
        }
        return NO;
    }];
    
    // 连接过滤器
    __block BOOL isFirst = YES;
    [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        // 排除没有数据传送服务服务的
        if (![[advertisementData allKeys] containsObject:@"kCBAdvDataServiceUUIDs"]) return NO;
        if (![[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] containsObject:[CBUUID UUIDWithString:@"69400001-b5a3-f393-e0a9-e50e24dcca99"]]) return NO;
        // 连接第一个设备
        if (isFirst) {
            isFirst = NO;
            return YES;
        }
        NSLog(@"Found logitow devices");
        return YES;
    }];
    
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        // 设置连接成功的block
        NSLog(@"Succeed in connecting to %@ with uuid %s",peripheral.name, [peripheral.identifier UUIDString].UTF8String);
        
        // 停止扫描
        [weakBaby cancelScan];
        
        [weakSelf notifyConnected: peripheral.identifier.UUIDString];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"Found Services: %@", service.UUID.UUIDString);
        }
    }];
    
    // 设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"Finding characteristices in Service %@", service.UUID.UUIDString);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"69400001-B5A3-F393-E0A9-E50E24DCCA99"]]) {
            // 数据传送服务
            for (CBCharacteristic *c in service.characteristics) {
                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"69400002-B5A3-F393-E0A9-E50E24DCCA99"]]) {
                    // 写
                }
                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"69400003-B5A3-F393-E0A9-E50E24DCCA99"]]) {
                    // 读
                    NSLog(@"Found characteristice to read block data with UUID %@", c.UUID.UUIDString);
                    [weakBaby cancelNotify:peripheral characteristic:c];
                    [weakBaby notify:peripheral
                      characteristic:c
                               block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                                   //接收到值会进入这个方法
                                   [weakSelf notifyBlockData:[characteristics.value bytes]];
                               }];
                }
            }
        }
    }];
    
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error){
        [weakSelf notifyDisconnected:true];
        [weakSelf startScan];
    }];
}

@end