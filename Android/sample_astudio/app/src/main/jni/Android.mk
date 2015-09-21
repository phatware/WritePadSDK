LOCAL_PATH := $(call my-dir)

#########
### Copy Libs
#########

include $(CLEAR_VARS)

LOCAL_MODULE := libWritePadRecos

include $(CLEAR_VARS)

LOCAL_MODULE    := WritePadRecos
LOCAL_SRC_FILES := ../../../../../libs/$(TARGET_ARCH_ABI)/libWritePadRecos.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../../../../include

include $(PREBUILT_STATIC_LIBRARY)

#########
### Multilingual
#########

include $(CLEAR_VARS)


LOCAL_MODULE := WritePadReco
LOCAL_CFLAGS := -I$(LOCAL_PATH)/../../../../../include
LOCAL_SRC_FILES := interface.c
LOCAL_STATIC_LIBRARIES := WritePadRecos

include $(BUILD_SHARED_LIBRARY)


