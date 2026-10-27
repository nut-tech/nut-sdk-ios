//
//  NTOtaTelinkImpl.h
//  nutble
//
//  Telink芯片OTA实现
//  封装TelinkGenericOTALib
//

#import <Foundation/Foundation.h>
#import <nutble/NTOtaProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// Telink芯片OTA实现
@interface NTOtaTelinkImpl : NSObject <NTOtaProtocol>

/// Telink特定配置 (OTASettingsModel)
/// 使用此属性可以设置Telink特有的OTA参数
@property (nonatomic, strong, nullable) id telinkSettings;

@end

NS_ASSUME_NONNULL_END
