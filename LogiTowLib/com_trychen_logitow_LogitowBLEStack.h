/* DO NOT EDIT THIS FILE - it is machine generated */
#include <JavaVM/jni.h>
/* Header for class com_trychen_logitow_LogitowBLEStack */

#ifndef _Included_com_trychen_logitow_LogitowBLEStack
#define _Included_com_trychen_logitow_LogitowBLEStack
#ifdef __cplusplus
extern "C" {
#endif
    /*
     * Class:     com_trychen_logitow_LogitowBLEStack
     * Method:    setup
     * Signature: ()V
     */
    JNIEXPORT void JNICALL Java__setup
    (JNIEnv *, jclass);
    
    /*
     * Class:     com_trychen_logitow_LogitowBLEStack
     * Method:    getNativeBluetoothState
     * Signature: ()I
     */
    JNIEXPORT jint JNICALL Java_com_trychen_logitow_LogitowBLEStack_getNativeBluetoothState
    (JNIEnv *, jclass);
    
    /*
     * Class:     com_trychen_logitow_LogitowBLEStack
     * Method:    startScanDevice
     * Signature: ()Z
     */
    JNIEXPORT jboolean JNICALL Java_com_trychen_logitow_LogitowBLEStack_startScanDevice
    (JNIEnv *, jclass);
    
    /*
     * Class:     com_trychen_logitow_LogitowBLEStack
     * Method:    stopScanDevice
     * Signature: ()V
     */
    JNIEXPORT void JNICALL Java_com_trychen_logitow_LogitowBLEStack_stopScanDevice
    (JNIEnv *, jclass);
    
    /*
     * Class:     com_trychen_logitow_LogitowBLEStack
     * Method:    disconnect
     * Signature: (Ljava/lang/String;)V
     */
    JNIEXPORT void JNICALL Java_com_trychen_logitow_LogitowBLEStack_disconnect
    (JNIEnv *, jclass, jstring);
    
    
    /*
     * Class:     com_trychen_logitow_LogitowBLEStack
     * Method:    writeToGetVoltage
     * Signature: (Ljava/lang/String;)V
     */
    JNIEXPORT jboolean JNICALL Java_com_trychen_logitow_LogitowBLEStack_writeToGetVoltage
    (JNIEnv *, jclass, jstring);

    
#ifdef __cplusplus
}
#endif
#endif