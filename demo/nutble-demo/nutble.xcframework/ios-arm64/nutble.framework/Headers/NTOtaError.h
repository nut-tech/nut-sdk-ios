//
//  NTOtaError.h
//  nutble
//
//  OTA错误定义
//

#import <Foundation/Foundation.h>
#import "NTOtaTypes.h"

NS_ASSUME_NONNULL_BEGIN

/// OTA错误Domain
extern NSString * const NTOtaErrorDomain;

/// Telink芯片错误Domain
extern NSString * const NTOtaTelinkErrorDomain;

/// Nordic芯片错误Domain
extern NSString * const NTOtaNordicErrorDomain;

/// OnMicro芯片错误Domain
extern NSString * const NTOtaOnMicroErrorDomain;

/// Goodix芯片错误Domain
extern NSString * const NTOtaGoodixErrorDomain;

/// 错误UserInfo Key - 芯片原始错误码
extern NSString * const NTOtaErrorOriginalCodeKey;

/// 错误UserInfo Key - 芯片类型
extern NSString * const NTOtaErrorChipTypeKey;

/// 错误UserInfo Key - 详细描述
extern NSString * const NTOtaErrorDetailKey;

@interface NTOtaError : NSObject

/// 创建OTA错误
/// @param code 错误码
/// @param description 描述
+ (NSError *)errorWithCode:(NTOtaErrorCode)code description:(nullable NSString *)description;

/// 创建OTA错误带详细信息
/// @param code 错误码
/// @param description 描述
/// @param detail 详细信息
+ (NSError *)errorWithCode:(NTOtaErrorCode)code
               description:(nullable NSString *)description
                     detail:(nullable NSString *)detail;

/// 创建芯片特定错误
/// @param chipType 芯片类型
/// @param originalCode 芯片原始错误码
/// @param description 描述
+ (NSError *)chipErrorWithChipType:(NTOtaChipType)chipType
                      originalCode:(NSInteger)originalCode
                       description:(nullable NSString *)description;

/// 创建超时错误
/// @param operation 操作描述
+ (NSError *)timeoutErrorWithOperation:(nullable NSString *)operation;

/// 创建设备不支持错误
/// @param chipType 芯片类型
+ (NSError *)deviceNotSupportedErrorWithChipType:(NTOtaChipType)chipType;

/// 获取错误的本地化描述
/// @param error 错误对象
+ (NSString *)localizedDescriptionForError:(NSError *)error;

/// 获取错误码描述
/// @param code 错误码
+ (NSString *)descriptionForErrorCode:(NTOtaErrorCode)code;

@end

NS_ASSUME_NONNULL_END
