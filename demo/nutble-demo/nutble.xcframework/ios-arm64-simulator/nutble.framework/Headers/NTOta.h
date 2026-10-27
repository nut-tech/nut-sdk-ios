//
//  NTOta.h
//  nutble
//
//  OTA模块总头文件
//  支持多芯片OTA: Telink, Nordic, OnMicro, Goodix
//
//  Public headers are flattened into Headers/ in the shipped XCFramework,
//  so use flat imports (same as nutble.h) — not Core/ or Impl/ relative paths.
//

#import <Foundation/Foundation.h>

// 核心类型定义
#import "NTOtaTypes.h"

// 错误定义
#import "NTOtaError.h"

// 协议接口
#import "NTOtaProtocol.h"

// 统一管理器
#import "NTOtaManager.h"

// 芯片实现
#import "NTOtaTelinkImpl.h"
