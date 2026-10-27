//
//  NTOtaTypes.h
//  nutble
//
//  OTA通用类型定义
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Telink配置键名 (用于chipConfig字典)

/// Telink配置 - Service UUID
static NSString * const kNTTelinkServiceUUID = @"serviceUUID";
/// Telink配置 - Characteristic UUID
static NSString * const kNTTelinkCharacteristicUUID = @"characteristicUUID";
/// Telink配置 - Read Interval
static NSString * const kNTTelinkReadInterval = @"readInterval";
/// Telink配置 - Protocol (0=Legacy, 1=Extend)
static NSString * const kNTTelinkProtocol = @"protocol";
/// Telink配置 - PDU长度 (Extend模式, 16-240)
static NSString * const kNTTelinkPduLength = @"pduLength";
/// Telink配置 - 固件版本 (Extend模式)
static NSString * const kNTTelinkFirmwareVersion = @"firmwareVersion";
/// Telink配置 - 版本比较开关
static NSString * const kNTTelinkVersionCompare = @"versionCompare";
/// Telink配置 - 发送OTA版本命令
static NSString * const kNTTelinkSendOtaVersion = @"sendOtaVersion";
/// Telink配置 - 发送固件索引
static NSString * const kNTTelinkSendFwIndex = @"sendFwIndex";
/// Telink配置 - 固件索引值
static NSString * const kNTTelinkFwIndex = @"fwIndex";
/// Telink配置 - Secure Boot开关
static NSString * const kNTTelinkSecureBootEnable = @"secureBootEnable";
/// Telink配置 - Secure Boot描述符数据
static NSString * const kNTTelinkSecureBootData = @"secureBootData";

#pragma mark - 枚举定义

/// OTA状态
typedef NS_ENUM(NSInteger, NTOtaState) {
    NTOtaStateIdle = 0,              ///< 空闲
    NTOtaStateConnecting,            ///< 连接中
    NTOtaStatePreparing,             ///< 准备中 (发现服务、切换模式等)
    NTOtaStateUploading,             ///< 上传中
    NTOtaStateValidating,            ///< 验证中
    NTOtaStateCompleted,             ///< 完成
    NTOtaStateFailed,                ///< 失败
    NTOtaStateCancelled              ///< 已取消
};

/// 芯片类型
typedef NS_ENUM(NSInteger, NTOtaChipType) {
    NTOtaChipTypeUnknown = 0,        ///< 未知
    NTOtaChipTypeTelink,             ///< Telink芯片
    NTOtaChipTypeNordic,             ///< Nordic芯片
    NTOtaChipTypeOnMicro,            ///< OnMicro芯片
    NTOtaChipTypeGoodix              ///< Goodix芯片
};

/// OTA错误码
typedef NS_ENUM(NSInteger, NTOtaErrorCode) {
    // 通用错误 (1xxx)
    NTOtaErrorUnknown = -1,
    NTOtaErrorCancelled = -999,
    NTOtaErrorTimeout = -1001,
    NTOtaErrorDeviceDisconnected = -1002,
    NTOtaErrorDeviceNotSupported = -1003,
    NTOtaErrorInvalidFirmware = -1004,
    NTOtaErrorInvalidConfiguration = -1005,
    NTOtaErrorAlreadyInProgress = -1006,
    NTOtaErrorBluetoothNotReady = -1007,

    // 连接错误 (2xxx)
    NTOtaErrorConnectFailed = -2001,
    NTOtaErrorServiceNotFound = -2002,
    NTOtaErrorCharacteristicNotFound = -2003,
    NTOtaErrorNotifyEnableFailed = -2004,

    // 传输错误 (3xxx)
    NTOtaErrorWriteFailed = -3001,
    NTOtaErrorVerifyFailed = -3002,
    NTOtaErrorCRCError = -3003,
    NTOtaErrorDataSequenceError = -3004,
    NTOtaErrorFlashWriteError = -3005,
    NTOtaErrorDataIncomplete = -3006,

    // 验证错误 (4xxx)
    NTOtaErrorFirmwareCheckFailed = -4001,
    NTOtaErrorVersionCompareFailed = -4002,
    NTOtaErrorSignatureVerifyFailed = -4003,
    NTOtaErrorSizeError = -4004,

    // 芯片特定错误基础值 (各芯片实现可从此开始扩展)
    NTOtaErrorTelinkBase = -5000,
    NTOtaErrorNordicBase = -6000,
    NTOtaErrorOnMicroBase = -7000,
    NTOtaErrorGoodixBase = -8000,
};

#pragma mark - 进度信息

/// OTA进度信息
@interface NTOtaProgress : NSObject

/// 完成比例 0.0 ~ 1.0
@property (nonatomic, assign) float fractionCompleted;

/// 已发送字节数
@property (nonatomic, assign) NSInteger bytesSent;

/// 总字节数
@property (nonatomic, assign) NSInteger totalBytes;

/// 当前速度 (bytes/s)
@property (nonatomic, assign) NSInteger currentSpeedBytesPerSecond;

/// 平均速度 (bytes/s)
@property (nonatomic, assign) NSInteger averageSpeedBytesPerSecond;

/// 当前状态
@property (nonatomic, assign) NTOtaState state;

/// 状态描述
@property (nonatomic, copy, nullable) NSString *stateDescription;

/// 芯片类型
@property (nonatomic, assign) NTOtaChipType chipType;

/// 便利构造方法
+ (instancetype)progressWithFraction:(float)fraction
                           bytesSent:(NSInteger)bytesSent
                           totalBytes:(NSInteger)totalBytes
                          chipType:(NTOtaChipType)chipType;

/// 更新进度
- (void)updateWithFraction:(float)fraction bytesSent:(NSInteger)bytesSent;

@end

#pragma mark - 配置基类

/// OTA配置基类
@interface NTOtaConfiguration : NSObject <NSCopying>

/// 超时时间 (秒)，默认60秒
@property (nonatomic, assign) NSTimeInterval timeout;

/// 连接超时时间 (秒)，默认10秒
@property (nonatomic, assign) NSTimeInterval connectionTimeout;

/// 服务发现超时时间 (秒)，默认10秒
@property (nonatomic, assign) NSTimeInterval discoveryTimeout;

/// 芯片特定配置 (如Telink的OTASettingsModel)
@property (nonatomic, strong, nullable) id chipSpecificConfig;

/// 进度回调
@property (nonatomic, copy, nullable) void(^progressBlock)(NTOtaProgress *progress);

/// 完成回调
@property (nonatomic, copy, nullable) void(^completionBlock)(NSError * _Nullable error);

/// 状态变化回调
@property (nonatomic, copy, nullable) void(^stateChangeBlock)(NTOtaState state);

/// 默认配置
+ (instancetype)defaultConfiguration;

/// 带回调的配置
+ (instancetype)configurationWithProgress:(nullable void(^)(NTOtaProgress *progress))progressBlock
                               completion:(nullable void(^)(NSError * _Nullable error))completionBlock;

/// 完整配置
+ (instancetype)configurationWithProgress:(nullable void(^)(NTOtaProgress *progress))progressBlock
                               completion:(nullable void(^)(NSError * _Nullable error))completionBlock
                        chipSpecificConfig:(nullable id)chipSpecificConfig;

@end

#pragma mark - 辅助方法

/// 获取芯片类型名称
NS_INLINE NSString *NTOtaChipTypeGetName(NTOtaChipType type) {
    switch (type) {
        case NTOtaChipTypeTelink:   return @"Telink";
        case NTOtaChipTypeNordic:   return @"Nordic";
        case NTOtaChipTypeOnMicro:  return @"OnMicro";
        case NTOtaChipTypeGoodix:   return @"Goodix";
        default:                    return @"Unknown";
    }
}

/// 获取OTA状态名称
NS_INLINE NSString *NTOtaStateGetName(NTOtaState state) {
    switch (state) {
        case NTOtaStateIdle:        return @"Idle";
        case NTOtaStateConnecting:  return @"Connecting";
        case NTOtaStatePreparing:   return @"Preparing";
        case NTOtaStateUploading:   return @"Uploading";
        case NTOtaStateValidating:  return @"Validating";
        case NTOtaStateCompleted:   return @"Completed";
        case NTOtaStateFailed:      return @"Failed";
        case NTOtaStateCancelled:   return @"Cancelled";
    }
}

/// 获取OTA状态本地化描述
NS_INLINE NSString *NTOtaStateGetDescription(NTOtaState state) {
    switch (state) {
        case NTOtaStateIdle:        return @"OTA空闲";
        case NTOtaStateConnecting:  return @"正在连接设备...";
        case NTOtaStatePreparing:   return @"正在准备OTA...";
        case NTOtaStateUploading:   return @"正在上传固件...";
        case NTOtaStateValidating:  return @"正在验证固件...";
        case NTOtaStateCompleted:   return @"OTA完成";
        case NTOtaStateFailed:      return @"OTA失败";
        case NTOtaStateCancelled:   return @"OTA已取消";
    }
}

NS_ASSUME_NONNULL_END
