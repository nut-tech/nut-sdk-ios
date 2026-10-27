//
//  NTOtaProtocol.h
//  nutble
//
//  OTA协议接口定义
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "NTOtaTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class NTDevice;

/// OTA实现协议 - 所有芯片OTA实现必须遵循此协议
@protocol NTOtaProtocol <NSObject>

#pragma mark - 类方法 (用于注册和检测)

/// 芯片类型标识
+ (NTOtaChipType)chipType;

/// 检查设备是否支持此OTA协议
/// @param device NTDevice设备对象
+ (BOOL)canHandleDevice:(NTDevice *)device;

/// 检查外设是否支持此OTA协议 (用于扫描阶段识别)
/// @param peripheral CBPeripheral对象
/// @param advertisementData 广播数据
+ (BOOL)canHandlePeripheral:(CBPeripheral *)peripheral
          advertisementData:(NSDictionary *)advertisementData;

/// 芯片特定的默认服务UUID
+ (nullable NSString *)defaultServiceUUID;

/// 芯片特定的默认特征UUID
+ (nullable NSString *)defaultCharacteristicUUID;

#pragma mark - 实例方法 (OTA操作)

/// 初始化
/// @param device 目标设备
- (instancetype)initWithDevice:(NTDevice *)device;

/// 关联的设备
@property (nonatomic, weak, readonly, nullable) NTDevice *device;

/// 当前OTA状态
@property (nonatomic, readonly) NTOtaState state;

/// 当前OTA进度
@property (nonatomic, readonly, nullable) NTOtaProgress *progress;

/// 开始OTA
/// @param firmwareData 固件数据
/// @param configuration OTA配置
- (BOOL)startOTAWithFirmwareData:(NSData *)firmwareData
                   configuration:(NTOtaConfiguration *)configuration;

/// 取消OTA
- (void)cancelOTA;

@optional

#pragma mark - 可选方法

/// 设置芯片特定配置
/// @param chipConfig 芯片特定配置对象
- (void)setChipSpecificConfiguration:(id)chipConfig;

/// 获取固件版本
/// @param completion 完成回调
- (void)getFirmwareVersionWithCompletion:(void(^)(NSString * _Nullable version, NSError * _Nullable error))completion;

/// 切换到BootLoader模式 (如果需要)
/// @param completion 完成回调，返回BootLoader模式的设备
- (void)switchToBootLoaderModeWithCompletion:(void(^)(NTDevice * _Nullable bootLoaderDevice, NSError * _Nullable error))completion;

/// 检查是否需要BootLoader模式
- (BOOL)requiresBootLoaderMode;

/// 获取支持的固件文件扩展名 (如 @[@"bin", @"hex"])
+ (NSArray<NSString *> *)supportedFirmwareExtensions;

@end

NS_ASSUME_NONNULL_END
