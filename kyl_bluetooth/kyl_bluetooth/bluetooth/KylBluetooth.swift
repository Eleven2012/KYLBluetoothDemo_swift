//
//  KylBluetooth.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/8.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc final class KylBluetooth:NSObject {
    @objc public var isSendingHeartBeat = true
    
    @objc public let uuid:UUID //设备UUID
    
    public let name:String //设备名称
    public var speakerName:String?
    public var masterboardType:KYLMasterboardType = .new
    private(set) var connectState:KYLConnectState = .disconnected
    
    var deviceInfo:KYLDeviceInfo? //收到8命令会重新生成，一直缓存，不会删除
    var deviceNoResponseCount = 0                       //超过3次未收到设备返回数据将自动断连
    var command8count = 0                               //8号命令重读计数
    var observer:NSKeyValueObservation!
    let peripheral:CBPeripheral                         //外设
    var writeChar:CBCharacteristic?                     //写特征
    var airPathChar:CBCharacteristic?                   //补漏洞特征
    var contexts = [(UInt8, [UInt8], KYLWritePriority,(((UInt8, [UInt8])?)->())?)]()  //命令体
    var cmd:UInt8 = 0                                 //写入命令号，0的时候为可写状态
    var totalData = Data()                              //分包存储变量
    var onReadDataBlock:(((UInt8, [UInt8])?)->())?      //设备返回数据回调
    var lastSendCommandTime:CFAbsoluteTime?             //上一次执行命令时间
    var upgradeInfo:[KYLComponentType]?                       //需要升级的元器件
    var matchResult:[(Int,KYLComponentType,KYLComponentsMatchResult,KYLComponentsMatchResultLevel)]! //匹配结果
    let internalCommands:[UInt8] = [0x01,0x08,0x05,0x03,0x0b,0x27,0x2B,0x2C,0x1a,0x1b,0x1c,0x1e,0x1f,0x36,0x23,0x24,0x25,0x26,0x80,0x81,0x82,0x83,0x71,0x1D] //内部命令集
    
    var upgradeData:Data?                            //升级数据
    var totalFrames:Int  = 0                         //总帧数
    var currentFrame:Int = 1                         //当前帧数
    var currentComponent:KYLComponentType!              //当前升级元器件
    var isUpgrading = false{
        didSet{
            if isUpgrading{
                //UIApplication.shared.isIdleTimerDisabled = true
            }else{
                //UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    var newMasterboardUpgrading = false              //新主控升级中
    var newMasterboardReconnecting = false           //新主控升级断开重连中
    var justScanComponents = false                   //只扫描
    
    //舵机角度回读相关
    var servoTotoalCount:Int?
    var servoReadCount:Int = 0
    var servoNeedChangeAngle:[UInt8:UInt8]?
    
    //jimu
    var handShakeStep = 0  //握手
    var aliveTimer:Timer?  //发送心跳定时器
    var powerTimer:Timer?  //读取电量定时器
    var delayTimer:Timer?  //读取主板信息定时器
    var commandTimer:Timer?//命令超时定时器
    var jimuTimer:Timer?   //判断jimu主控定时器
    var upgradeTimeoutTimer:Timer? //升级超时定时器
    var upgradeTimeoutCount:Int = 0 //50S
    var reconnectTask:DispatchWorkItem?
    
    var jimuTimerCount = 0 //判断jimu主控命令次数
    
    //蓝牙模块修复标志位
    var didReadNext = false
    var fisrtFetchPowerInfo = false
    
    
    
    @objc init(_ peripheral:CBPeripheral) {
        self.peripheral = peripheral
        uuid = peripheral.identifier
        name = peripheral.name ?? ""
        super.init()
    }
}
