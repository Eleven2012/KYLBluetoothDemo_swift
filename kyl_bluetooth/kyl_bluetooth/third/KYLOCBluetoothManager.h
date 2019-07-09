//
//  KOCBluetoothManager.h
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/9.
//  Copyright © 2019 yulu kong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#import "SVProgressHUD.h"
#import "KYLOCBluetoothType.h"



NS_ASSUME_NONNULL_BEGIN

@interface KYLOCBluetoothManager : NSObject

@property (nonatomic , strong) NSMutableArray *peripherals;//查找到的所有的外设
@property (nonatomic , copy) KYLDidReadRSSIAtChannel readRSSIAtChannel;
@property (nonatomic , copy) KYLBlockOnDisconnectAtChannel disconnectAtChannel;
@property (nonatomic , copy) KYLDidUpdateNotificationStateForCharacteristicAtChannel notiUpdateAtChannel;
@property (nonatomic , copy) KYLDidWriteValueForCharacteristicAtChannel didWriteData;

/**
 单例初始化
 */
+ (KYLOCBluetoothManager *)defaultManager;

/**
 取消之前的连接
 */
- (void)cancleAllConnect;

/**
 开始扫描外设
 */
- (void)beginToScan;

/**
 扫描多久之后停止扫描
 
 @param time 限制时间(s)
 */
- (void)beginToScanWithLimitTime:(int)time;

/**
 停止扫描
 */
- (void)cancleScan;

/**
 扫描到外设的代理
 
 @param block block
 */
- (void)kyl_discoverPeripherals:(KYLPeripheralsBlock)block;

/**
 发现设备服务
 
 @param block block
 */
- (void)kyl_discoverPeripheralService:(KYLDiscoverServices)block;

/**
 发现Characteristic
 
 @param block block
 */
- (void)kyl_discoverCharacteristics:(KYLDiscoverCharacteristics)block;

/**
 读取特征值
 
 @param block block
 */
- (void)kyl_readValueForCharacteristic:(KYLReadValueForCharacteristic)block;

/**
 读取特征描述
 
 @param block block
 */
- (void)kyl_discoverDescriptorsForCharacteristic:(KYLDiscoverDescriptorsForCharacteristic)block;

/**
 读取Descriptors
 
 @param block block
 */
- (void)kyl_readValueForDescriptors:(KYLReadValueForDescriptors)block;

/**
 设置设备查找的过滤条件
 
 @param block block
 */
- (void)kyl_setFilterOnDiscoverPeripherals:(KYLsetFilterOnDiscoverPeripherals)block;

/**
 连接外设
 
 @param channel channel
 */
- (void)connectToPeripheralWithChannel:(NSString *)channel peripheral:(CBPeripheral *)peripheral;

/**
 连接成功与否
 
 @param block block
 */
- (void)kyl_connectState:(KYLConnectStateBlock)block;

/**
 断开连接失败的回调
 
 @param block block
 */
- (void)kyl_disconnectAtChannelBlock:(KYLDisconnectAtChannel)block;

/**
 发现服务
 
 @param block block
 */
- (void)kyl_discoverServicesAtChannel:(KYLDiscoverServicesAtChannel)block;

/**
 发现特征
 
 @param block block
 */
- (void)kyl_KYLDiscoverCharacteristicsAtChannel:(KYLDiscoverCharacteristicsAtChannel)block;

/**
 读取特征值
 
 @param block block
 */
- (void)kyl_readValueForCharacterAtChannel:(KYLReadValueForCharacteristicAtChannel)block;

/**
 发现特定频道的特征描述
 
 @param block block
 */
- (void)kyl_discoverDescriptorsForCharacteristicAtChannel:(KYLDiscoverDescriptorsForCharacteristicAtChannel)block;

/**
 读取特定频道的特征描述
 
 @param block block
 */
- (void)kyl_readValueForDescriptorsAtChannel:(KYLReadValueForDescriptorsAtChannel)block;

/**
 读取RSSI
 
 @param block block
 */
- (void)kyl_readRSSI:(KYLReadRSSI)block;

/**
 外设状态更新
 
 @param block block
 */
- (void)kyl_peripheralManagerDidUpdateState:(KYLPeripheralManagerDidUpdateState)block;

/**
 添加断开重连的设备
 
 @param peripheral peripheral
 */
- (void)kyl_addAutoReconnectPeripheral:(CBPeripheral *)peripheral;

/**
 读取特定频道的rssi
 
 @param block block
 */
- (void)kyl_didReadRSSIAtChannel:(KYLDidReadRSSIAtChannel)block;

/**
 读取详细信息
 
 @param channel chanel
 @param characteristic 当前的characteristic
 @param currPeripheral 当前的currPeripheral
 */
- (void)readDetailValueOfCharacteristicWithChannel:(NSString *)channel characteristic:(CBCharacteristic *)characteristic currPeripheral:(CBPeripheral *)currPeripheral;

/**
 外设断开连接的回调
 
 @param block block
 */
- (void)kyl_blockOnDisconnectAtChannel:(KYLBlockOnDisconnectAtChannel)block;

/**
 订阅状态发生改变
 
 @param block block
 */
- (void)kyl_didUpdateNotificationStateForCharacteristicAtChannel:(KYLDidUpdateNotificationStateForCharacteristicAtChannel)block;

/**
 写数据成功的回调
 
 @param block block
 */
- (void)kyl_didWriteValueForCharacteristicAtChannel:(KYLDidWriteValueForCharacteristicAtChannel)block;

/**
 给外设写入数据
 
 @param data data
 */
- (void)writeData:(NSData *)data ToPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic;

/**
 订阅数据
 
 @param peripheral peripheral
 @param characteristic characteristic
 */
- (void)kyl_setNotifiyWithPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic block:(KYLReadValueForCharacteristic)block;

/**
 发现当前连接的设备
 
 @return peripherals
 */
- (NSArray *)KYLFindConnectedPeripherals;

/**
 取消订阅
 
 @param peripheral peripheral
 @param characteristic characteristic
 */
- (void)kyl_cancleNotifyWith:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;
@end

NS_ASSUME_NONNULL_END
