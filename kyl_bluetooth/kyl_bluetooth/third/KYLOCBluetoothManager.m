//
//  KOCBluetoothManager.m
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/9.
//  Copyright © 2019 yulu kong. All rights reserved.
//

#import "KYLOCBluetoothManager.h"

@interface KYLOCBluetoothManager()
@property (nonatomic , strong) BabyRhythm *rhythm;

@property (nonatomic , copy) KYLPeripheralsBlock peripheralsBlock;
@property (nonatomic , copy) KYLDiscoverServices serviceBlock;
@property (nonatomic , copy) KYLDiscoverCharacteristics characteristicBlock;
@property (nonatomic , copy) KYLReadValueForCharacteristic readValueForCharacteristic;
@property (nonatomic , copy) KYLDiscoverDescriptorsForCharacteristic discoverDescForCharacter;
@property (nonatomic , copy) KYLReadValueForDescriptors descriptorsValue;
@property (nonatomic , copy) KYLsetFilterOnDiscoverPeripherals setFilterOnDiscoverPeripherals;
@property (nonatomic , copy) KYLConnectStateBlock connectState; //连接状态
@property (nonatomic , copy) KYLDisconnectAtChannel disconnectBlock;
@property (nonatomic , copy) KYLDiscoverServicesAtChannel discoverServicesBlock;
@property (nonatomic , copy) KYLDiscoverCharacteristicsAtChannel discoverCharacteristicsBlock;
@property (nonatomic , copy) KYLReadValueForCharacteristicAtChannel readValueForCharacter;
@property (nonatomic , copy) KYLDiscoverDescriptorsForCharacteristicAtChannel channelDesForCharac;
@property (nonatomic , copy) KYLReadValueForDescriptorsAtChannel readValueForDesAtChannel;
@property (nonatomic , copy) KYLReadRSSI readRSSI;
@property (nonatomic , copy) KYLPeripheralManagerDidUpdateState peripheralUpadte;

@end

@implementation KYLOCBluetoothManager
{
    __strong BabyBluetooth *baby;
}

//初始化
+ (KYLOCBluetoothManager *)defaultManager{
    static KYLOCBluetoothManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KYLOCBluetoothManager alloc] init];
        [manager initObjects];
    });
    
    return manager;
}

- (void)initObjects{
    WEAKSELF;
    baby = [BabyBluetooth shareBabyBluetooth];
    self.rhythm = [[BabyRhythm alloc]init];
    self.peripherals = [NSMutableArray array];
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        weakSelf.peripheralsBlock(central,peripheral,advertisementData,RSSI);
        if (![weakSelf.peripherals containsObject:peripheral]) {
            [weakSelf.peripherals addObject:peripheral];
        }
        NSLog(@"%@",peripheral);
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        weakSelf.serviceBlock(peripheral,error);
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        weakSelf.characteristicBlock(peripheral,service,error);
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        weakSelf.readValueForCharacteristic(peripheral,characteristics,error);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        weakSelf.discoverDescForCharacter(peripheral,characteristic,error);
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        weakSelf.descriptorsValue(peripheral,descriptor,error);
    }];
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        return  weakSelf.setFilterOnDiscoverPeripherals(peripheralName,advertisementData,RSSI);
    }];
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
/**
 根据信号强度获取设备之间的距离,返回距离是米
 
 @param RSSI 信号强度值
 @return 米
 */
- (CGFloat)getDistance:(NSNumber *)RSSI{
    float power = (abs([RSSI intValue]) - 49)/(10*4.0);
    return powf(10.0f,power);
}
- (void)cancleAllConnect{
    [baby cancelAllPeripheralsConnection];
}
- (void)beginToScan{
    baby.scanForPeripherals().begin();
}
- (void)beginToScanWithLimitTime:(int)time{
    baby.scanForPeripherals().begin().stop(time);
}
- (void)cancleScan{
    [baby cancelScan];
}
- (void)kyl_discoverPeripherals:(KYLPeripheralsBlock)block{
    self.peripheralsBlock = block;
}
- (void)kyl_discoverPeripheralService:(KYLDiscoverServices)block{
    self.serviceBlock = block;
}

- (void)kyl_discoverCharacteristics:(KYLDiscoverCharacteristics)block{
    self.characteristicBlock = block;
}
- (void)kyl_readValueForCharacteristic:(KYLReadValueForCharacteristic)block{
    self.readValueForCharacteristic = block;
}
- (void)kyl_discoverDescriptorsForCharacteristic:(KYLDiscoverDescriptorsForCharacteristic)block{
    self.discoverDescForCharacter = block;
}
- (void)kyl_readValueForDescriptors:(KYLReadValueForDescriptors)block{
    self.descriptorsValue = block;
}
- (void)kyl_setFilterOnDiscoverPeripherals:(KYLsetFilterOnDiscoverPeripherals)block{
    self.setFilterOnDiscoverPeripherals = block;
}

/**
 连接外设
 
 @param channel channel
 @param peripheral peripheral
 */
- (void)connectToPeripheralWithChannel:(NSString *)channel peripheral:(CBPeripheral *)peripheral{
    WEAKSELF;
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        weakSelf.connectState(YES);
    }];
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
        weakSelf.connectState(NO);
    }];
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        weakSelf.disconnectBlock(central,peripheral,error);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
    }];
    [self setBlockOnDiscoverServicesAtChannel:channel];
    [self setBlockOnDiscoverCharacteristicsAtChannel:channel];
    [self setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channel];
    [self setBlockOnReadValueForCharacteristicAtChannel:channel];
    [self setBlockOnReadValueForDescriptorsAtChannel:channel];
    //设置beats break委托
    [self.rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
    }];
    //设置beats over委托
    [self.rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
    }];
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channel scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    [self loadDataWith:peripheral AndChannel:channel];
}

/**
 发现设备的委托
 
 @param channel channel
 */
- (void)setBlockOnDiscoverServicesAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnDiscoverServicesAtChannel:channel block:^(CBPeripheral *peripheral, NSError *error) {
        weakSelf.discoverServicesBlock(peripheral,error);
        [weakSelf.rhythm beats];
    }];
}

/**
 设置发现设service的Characteristics的委托
 
 @param channel channel
 */
- (void)setBlockOnDiscoverCharacteristicsAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channel block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        weakSelf.discoverCharacteristicsBlock(peripheral,service,error);
        NSLog(@"===service name:%@",service.UUID);
    }];
}

/**
 设置发现characteristics的descriptors的委托
 
 @param channel channel
 */
- (void)setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channel block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        
        weakSelf.channelDesForCharac(peripheral,characteristic,error);
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
}

/**
 设置读取characteristics的委托
 
 @param channel channel
 */
- (void)setBlockOnReadValueForCharacteristicAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnReadValueForCharacteristicAtChannel:channel block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        weakSelf.readValueForCharacter(peripheral,characteristics,error);
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
}

/**
 设置读取Descriptor的委托
 
 @param channel channel
 */
- (void)setBlockOnReadValueForDescriptorsAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnReadValueForDescriptorsAtChannel:channel block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        weakSelf.readValueForDesAtChannel(peripheral,descriptor,error);
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
}

/**
 外设更新
 */
- (void)peripheralModelBlockOnPeripheralManagerDidUpdateState{
    WEAKSELF;
    [baby peripheralModelBlockOnPeripheralManagerDidUpdateState:^(CBPeripheralManager *peripheral) {
        weakSelf.peripheralUpadte(peripheral);
        NSLog(@"%@",peripheral);
    }];
}

/**
 读取rssi的委托
 */
- (void)setBlockOnDidReadRSSI{
    WEAKSELF;
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        weakSelf.readRSSI(RSSI,error);
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
}

/**
 读取RSSI值
 
 @param channel channel
 */
- (void)setBlockOnDidReadRSSIAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnDidReadRSSIAtChannel:channel block:^(NSNumber *RSSI, NSError *error) {
        weakSelf.readRSSIAtChannel(RSSI,error);
        NSLog(@"%@",RSSI);
    }];
}
- (void)KYL_didReadRSSIAtChannel:(KYLDidReadRSSIAtChannel)block{
    self.readRSSIAtChannel = block;
}

/**
 连接失败的回调
 
 @param channel channel
 */
- (void)setBlockOnDisconnectAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnDisconnectAtChannel:channel block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"连接失败");
        weakSelf.disconnectAtChannel(central,peripheral,error);
    }];
}
- (void)kyl_connectState:(KYLConnectStateBlock)block{
    self.connectState = block;
}
- (void)kyl_disconnectAtChannelBlock:(KYLDisconnectAtChannel)block{
    self.disconnectBlock = block;
}
- (void)kyl_discoverServicesAtChannel:(KYLDiscoverServicesAtChannel)block{
    self.discoverServicesBlock = block;
}
- (void)kyl_KYLDiscoverCharacteristicsAtChannel:(KYLDiscoverCharacteristicsAtChannel)block{
    self.discoverCharacteristicsBlock = block;
}
- (void)kyl_readValueForCharacterAtChannel:(KYLReadValueForCharacteristicAtChannel)block{
    self.readValueForCharacter = block;
}
- (void)kyl_discoverDescriptorsForCharacteristicAtChannel:(KYLDiscoverDescriptorsForCharacteristicAtChannel)block{
    self.channelDesForCharac = block;
}
- (void)kyl_readValueForDescriptorsAtChannel:(KYLReadValueForDescriptorsAtChannel)block{
    self.readValueForDesAtChannel = block;
}
- (void)kyl_readRSSI:(KYLReadRSSI)block{
    self.readRSSI = block;
}
- (void)kyl_peripheralManagerDidUpdateState:(KYLPeripheralManagerDidUpdateState)block{
    self.peripheralUpadte = block;
}
-(void)loadDataWith:(CBPeripheral *)peripheral AndChannel:(NSString *)channel{
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    baby.having(peripheral).and.channel(channel).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}
- (void)kyl_addAutoReconnectPeripheral:(CBPeripheral *)peripheral{
    [baby AutoReconnect:peripheral];
}

- (void)readDetailValueOfCharacteristicWithChannel:(NSString *)channel characteristic:(CBCharacteristic *)characteristic currPeripheral:(CBPeripheral *)currPeripheral{
    [self setBlockOnReadValueForCharacteristicAtChannel:channel];
    [self setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channel];
    [self setBlockOnReadValueForDescriptorsAtChannel:channel];
    [self setBlockOnDidWriteValueForCharacteristicAtChannel:channel];
    [self setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channel];
    [self setBlockOnDidReadRSSI];
    [self setBlockOnDidReadRSSIAtChannel:channel];
    [self setBlockOnDisconnectAtChannel:channel];
    //读取服务
    baby.channel(channel).characteristicDetails(currPeripheral,characteristic);
}

/**
 数据写入成功的回调
 
 @param channel channel
 */
- (void)setBlockOnDidWriteValueForCharacteristicAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channel block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
        weakSelf.didWriteData(characteristic,error);
    }];
}

/**
 设置通知状态改变的block
 
 @param channel channel
 */
- (void)setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:(NSString *)channel{
    WEAKSELF;
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channel block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
        weakSelf.notiUpdateAtChannel(characteristic,error);
    }];
}
- (void)kyl_blockOnDisconnectAtChannel:(KYLBlockOnDisconnectAtChannel)block{
    self.disconnectAtChannel = block;
}
- (void)kyl_didUpdateNotificationStateForCharacteristicAtChannel:(KYLDidUpdateNotificationStateForCharacteristicAtChannel)block{
    self.notiUpdateAtChannel = block;
}
- (void)kyl_didWriteValueForCharacteristicAtChannel:(KYLDidWriteValueForCharacteristicAtChannel)block{
    self.didWriteData = block;
}
- (void)writeData:(NSData *)data ToPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic{
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}
- (void)kyl_setNotifiyWithPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic block:(KYLReadValueForCharacteristic)block{
    [baby notify:peripheral
  characteristic:characteristic
           block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
               block(peripheral,characteristics,error);
           }];
}
- (void)kyl_cancleNotifyWith:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    [baby cancelNotify:peripheral characteristic:characteristic];
}
- (NSArray *)KYLFindConnectedPeripherals{
    return [baby findConnectedPeripherals];
}
@end
