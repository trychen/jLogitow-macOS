//
//  LogiTowLib.m
//  LogiTowLib
//
//  Created by Trychen on 17/12/10.
//
//

#import "com_trychen_logitow_LogiTowBLEStack.h"
#import "LogiTowLib.h"
#import "BabyBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation LogiTowLib

@end

JNIEXPORT void JNICALL Java_com_trychen_logitow_LogiTowBLEStack_setup
(JNIEnv *env, jclass class){
    [[Controller sharedController] setupJNI:env ble_class:class];
}

JNIEXPORT jint JNICALL Java_com_trychen_logitow_LogiTowBLEStack_getNativeBluetoothState
(JNIEnv *env, jclass class){
    return [[Controller sharedController] bluetoothState];
}

JNIEXPORT jboolean JNICALL Java_com_trychen_logitow_LogiTowBLEStack_startScanDevice
(JNIEnv *env, jclass class)
{
    [[Controller sharedController] startScan];
    
    return true;
}
JNIEXPORT void JNICALL Java_com_trychen_logitow_LogiTowBLEStack_stopScanDevice
(JNIEnv *env, jclass class) {
    [[Controller sharedController] stopScan];
}

JNIEXPORT void JNICALL Java_com_trychen_logitow_LogiTowBLEStack_disconnect
(JNIEnv *env, jclass class, jstring uuid) {
    const char *chars = (*env)->GetStringUTFChars(env, uuid, 0);
    
    NSString *deviceUUID = [NSString stringWithUTF8String:chars];
    
    [[Controller sharedController] disconnect:deviceUUID];
    
    (*env)->ReleaseStringUTFChars(env, uuid, chars);
}

JNIEXPORT jboolean JNICALL Java_com_trychen_logitow_LogiTowBLEStack_writeToGetVoltage(JNIEnv *env, jclass class, jstring uuid) {
    const char *chars = (*env)->GetStringUTFChars(env, uuid, 0);
    
    NSString *deviceUUID = [NSString stringWithUTF8String:chars];
    
    BOOL R = [[Controller sharedController] writeToGetVoltage: deviceUUID];
    
    (*env)->ReleaseStringUTFChars(env, uuid, chars);
    
    return R;
}

//JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *javavm, void *reserved) {
//    g_vm = javavm;
////    JNIEnv *env;
////    
////    if ((*javavm)->GetEnv(javavm, (void**)&env, JNI_VERSION_1_4)) {
////        return JNI_ERR;
////    }
////    
////    notify_connected_funid = (*env)->GetMethodID(env, ble_class,"notifyConnected","()V");
////    NSLog(@"BLE Class %@", ble_class == NULL ? @"Null": @"Not Null");
////    NSLog(@"notify_connected_funid %@", notify_connected_funid == NULL ? @"Null":@"Not Null");
////    
//    return JNI_VERSION_1_4;
//}