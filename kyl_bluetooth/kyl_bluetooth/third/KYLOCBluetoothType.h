//
//  KOCBluetoothType.h
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/9.
//  Copyright © 2019 yulu kong. All rights reserved.
//

#ifndef KYLOCBluetoothType_h
#define KYLOCBluetoothType_h

#define KYLSERVICEBLOCK (CBPeripheral *peripheral, NSError *error)
#define KYLCHARCTICBLOCK (CBPeripheral *peripheral, CBService *service, NSError *error)
#define KYLVALUEFORCHARCTIC (CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error)
#define KYLDISCOVERDSCRIPFORCH (CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error)
#define KYLREADVALUEFORDES (CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error)

#define WEAKSELF typeof(self) __weak weakSelf = self;
/**
 扫描到设备
 
 @param central 外设中心
 @param peripheral 外设
 @param advertisementData advertisementData
 @param RSSI RSSI
 */
typedef void(^KYLPeripheralsBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

/**
 发现设备服务
 
 @param peripheral 外设
 @param error error
 */
typedef void(^KYLDiscoverServices)KYLSERVICEBLOCK;

/**
 发现设备的Characteristics
 
 @param peripheral peripheral
 @param service service
 @param error error
 */
typedef void(^KYLDiscoverCharacteristics)KYLCHARCTICBLOCK;

/**
 读取到的特征值
 
 @param peripheral peripheral
 @param characteristics characteristics
 @param error error
 */
typedef void(^KYLReadValueForCharacteristic)KYLVALUEFORCHARCTIC;

/**
 读取到特征描述
 
 @param peripheral peripheral
 @param characteristic characteristic
 @param error error
 */
typedef void(^KYLDiscoverDescriptorsForCharacteristic)KYLDISCOVERDSCRIPFORCH;

/**
 读取Descriptor
 
 @param peripheral peripheral
 @param descriptor descriptor
 @param error error
 */
typedef void(^KYLReadValueForDescriptors)KYLREADVALUEFORDES;

/**
 设置查找设备的过滤器
 
 @param peripheralName peripheralName
 @param advertisementData advertisementData
 @param RSSI RSSI
 */
typedef BOOL(^KYLsetFilterOnDiscoverPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);

/**
 链接成功与否
 
 @param state state
 */
typedef void(^KYLConnectStateBlock)(BOOL state);

/**
 断开连接
 
 @param central central
 @param peripheral peripheral
 @param error error
 */
typedef void(^KYLDisconnectAtChannel)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);

/**
 发现服务
 */
typedef void(^KYLDiscoverServicesAtChannel)KYLSERVICEBLOCK;

/**
 发现特征
 */
typedef void(^KYLDiscoverCharacteristicsAtChannel)KYLCHARCTICBLOCK;

/**
 读取到service的特征值
 */
typedef void(^KYLReadValueForCharacteristicAtChannel)KYLVALUEFORCHARCTIC;

/**
 发现特征描述
 */
typedef void(^KYLDiscoverDescriptorsForCharacteristicAtChannel)KYLDISCOVERDSCRIPFORCH;

/**
 读取特定频道的描述信息
 */
typedef void(^KYLReadValueForDescriptorsAtChannel)KYLREADVALUEFORDES;
typedef void(^KYLReadRSSI)(NSNumber *RSSI, NSError *error);
typedef void(^KYLPeripheralManagerDidUpdateState)(CBPeripheralManager *peripheral);
typedef void(^KYLDidReadRSSIAtChannel)(NSNumber *RSSI, NSError *error);
typedef void(^KYLBlockOnDisconnectAtChannel)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);
typedef void(^KYLDidUpdateNotificationStateForCharacteristicAtChannel)(CBCharacteristic *characteristic, NSError *error);
typedef void(^KYLDidWriteValueForCharacteristicAtChannel)(CBCharacteristic *characteristic, NSError *error);


#endif /* KOCBluetoothType_h */
