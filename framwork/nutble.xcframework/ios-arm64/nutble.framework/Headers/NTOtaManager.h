//
//  NTOtaManager.h
//  nutble
//
//  统一OTA管理器 - 客户使用的主要接口
//

#import <Foundation/Foundation.h>
#import "NTOtaTypes.h"
#import "NTOtaProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class NTDevice;

/// 统一OTA管理器 - 客户使用的主要接口
/// 支持多芯片OTA: Telink, Nordic, OnMicro, Goodix
@interface NTOtaManager : NSObject

#pragma mark - 单例

/// 共享实例
+ (instancetype)sharedManager;

#pragma mark - 注册实现

/// 注册OTA实现类
/// @param implClass 实现NTOtaProtocol的类
- (void)registerOtaImplementation:(Class<NTOtaProtocol>)implClass;

/// 注册所有内置实现 (Telink, Nordic等)
- (void)registerBuiltInImplementations;

/// 取消注册OTA实现类
/// @param implClass 实现NTOtaProtocol的类
- (void)unregisterOtaImplementation:(Class<NTOtaProtocol>)implClass;

#pragma mark - 设备检测

/// 获取设备对应的芯片类型
/// @param device 设备对象
- (NTOtaChipType)chipTypeForDevice:(NTDevice *)device;

/// 检查设备是否支持OTA
/// @param device 设备对象
- (BOOL)isOtaSupportedForDevice:(NTDevice *)device;

/// 获取支持的芯片类型列表
- (NSArray<NSNumber *> *)supportedChipTypes;

/// 获取芯片类型对应的实现类
/// @param chipType 芯片类型
- (nullable Class<NTOtaProtocol>)implementationForChipType:(NTOtaChipType)chipType;

#pragma mark - OTA操作 (简化API)

/// 开始OTA (自动选择实现，使用默认配置)
/// @param device 目标设备
/// @param firmwareData 固件数据
/// @param progressBlock 进度回调
/// @param completionBlock 完成回调
/// @return 是否成功启动OTA
- (BOOL)startOTAForDevice:(NTDevice *)device
             firmwareData:(NSData *)firmwareData
            progressBlock:(nullable void(^)(NTOtaProgress *progress))progressBlock
          completionBlock:(nullable void(^)(NSError * _Nullable error))completionBlock;

/// 开始OTA (使用芯片特定配置)
/// @param device 目标设备
/// @param firmwareData 固件数据
/// @param chipConfig 芯片特定配置 (如Telink的OTASettingsModel)
/// @param progressBlock 进度回调
/// @param completionBlock 完成回调
/// @return 是否成功启动OTA
- (BOOL)startOTAForDevice:(NTDevice *)device
             firmwareData:(NSData *)firmwareData
                chipConfig:(nullable id)chipConfig
            progressBlock:(nullable void(^)(NTOtaProgress *progress))progressBlock
          completionBlock:(nullable void(^)(NSError * _Nullable error))completionBlock;

/// 开始OTA (使用完整配置)
/// @param device 目标设备
/// @param firmwareData 固件数据
/// @param configuration 完整配置对象
/// @return 是否成功启动OTA
- (BOOL)startOTAForDevice:(NTDevice *)device
             firmwareData:(NSData *)firmwareData
            configuration:(NTOtaConfiguration *)configuration;

#pragma mark - OTA控制

/// 取消OTA
/// @param device 目标设备
- (void)cancelOTAForDevice:(NTDevice *)device;

/// 取消所有OTA
- (void)cancelAllOTA;

#pragma mark - 状态查询

/// 获取当前OTA状态
/// @param device 目标设备
- (NTOtaState)otaStateForDevice:(NTDevice *)device;

/// 获取当前OTA进度
/// @param device 目标设备
- (nullable NTOtaProgress *)otaProgressForDevice:(NTDevice *)device;

/// 是否正在进行OTA
/// @param device 目标设备
- (BOOL)isOtaInProgressForDevice:(NTDevice *)device;

/// 是否有任何OTA正在进行
- (BOOL)hasAnyOtaInProgress;

@end

NS_ASSUME_NONNULL_END
