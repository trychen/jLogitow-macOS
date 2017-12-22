//
//  controller.h
//  LogiTowLib
//
//  Created by Trychen on 17/12/10.
//
//

#include "BabyBluetooth.h"
#import <JavaVM/jni.h>

#ifndef controller_h
#define controller_h

@interface Controller : NSObject

@property BabyBluetooth *baby;
@property JavaVM *jvm;
@property jobject jni_ble_object;

+ (instancetype) sharedController;

- (void) startScan;

- (void) stopScan;

- (void) disconnect: (jboolean) restartScan;

- (CBCentralManagerState) bluetoothState;

- (void)setupJNI:(JNIEnv)env ble_instance:(jobject) obj;

@end

#endif /* controller_h */
