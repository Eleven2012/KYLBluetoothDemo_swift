//
//  KylBluetooth+Types.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/8.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct KYLBLEConfiguration {
    static let serviceUUID   = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
    static let readCharUUID  = CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616")
    static let writeCharUUID = CBUUID(string: "49535343-8841-43F4-A8D4-ECBE34729BB3")
    static let AIR_PATCH_CHAR = CBUUID(string: "49535343-ACA3-481C-91EC-D85E28A60318")
    
    static let cmdIndex = 3 //命令索引
    static let lenIndex = 2 //长度索引
    
    static let reread_masterborad_max_count = 2   //失败重新读取信息最大次数
    static let heartBeat_max_count          = 4   //心跳最大未回次数
    
    static let interval_alive = 3.0               //心跳包间隔时间 s
    static let interval_power = 30.0              //请求电量信息间隔时间 s
    static let interval_masterboard = 1.0         //重复读取主板信息时间间隔 s
    
    static let interval_jimu_command = 1.0        //判断是否是积木主控命令超时时间
    
    static let interval_normal_command = 1.0      //普通命令超时时间
    static let interval_upgrade_command = 3.0     //升级命令超时时间
    static let interval_masterboard_command = 5.0 //08命令超时时间
    
    static let interval_masterboard_timeout:Int = 50 //旧主控升级完成等待超时时间
    
    static let level_power_low:Float = 7.4        //电压
    
    //需要升级的器件
    static let upgradeComponents:[KYLComponentType] = [.masterboard,.servo,.infrared,.ultrasound,.touch,.gyro,.led,.horn]
    //需要开启传输功能的器件
    static let transmissionComponents:[KYLComponentType] = [.rgbLight,.horn,.led,.infrared,.ultrasound,.touch,.gyro,.color]
    //积木用到的器件(注意顺序)
    static let jimuComponents:[KYLComponentType] = [.rgbLight,.horn,.led,.infrared,.ultrasound,.touch,.gyro,.color,.servo,.motor]
}


@objc public enum KYLBLEModelType:Int {
    case offical = 0
    case diy     = 1
    case masterboard = 2
    case masterboardNewDIY = 3
    case masterboardModdifyID = 4 //用来区分修改id逻辑
}

public enum KYLComponentType:UInt8 {
    case servo      = 0  //舵机
    case infrared   = 1  //红外
    case touch      = 2  //触碰
    case gyro       = 3  //陀螺仪
    case led        = 4  //灯光
    case gravity    = 5  //重力
    case ultrasound = 6  //超声
    case nixieTube  = 7  //数码管
    case horn       = 8  //喇叭
    case color      = 9  //颜色
    case motor      = 10 //马达
    case sensirion  = 11 //温湿度
    case light      = 12 //光感
    case sound      = 13 //声音
    case rgbLight   = 14 //独角兽角灯
    
    
    case masterboard = 255 //主控
    
    var localName:String{
        switch self {
        case .infrared:
            return KYLLocalizedString("Infrared_sensor")
        case .touch:
            return KYLLocalizedString("Touch_sensor")
        case .led:
            return KYLLocalizedString("LED_light")
        case .rgbLight:
            return KYLLocalizedString("UnicornBot_Light")
        case .color:
            return KYLLocalizedString("Color_Sensor")
        case .horn:
            return KYLLocalizedString("Bluetooth_speaker")
        case .ultrasound:
            return KYLLocalizedString("Ultrasonic")
        case .gyro:
            return KYLLocalizedString("gyro")
        case .light:
            return KYLLocalizedString("光感")
        case .gravity:
            return KYLLocalizedString("重力")
        case .nixieTube:
            return KYLLocalizedString("Digital_tube")
        case .sound:
            return KYLLocalizedString("声音")
        case .sensirion:
            return KYLLocalizedString("温湿度")
        case .motor:
            return KYLLocalizedString("Motor")
        case .servo:
            return KYLLocalizedString("Servo")
        case .masterboard:
            return KYLLocalizedString("Main_control_box")
        }
    }
    
    var upgradeString:String{
        
        return KYLLocalizedString("upgrading").replacingOccurrences(of: "%s", with: "\(self.localName)")
        
    }
    
    var string:String{
        switch self {
        case .infrared:
            return "Infrared"
        case .touch:
            return "Touch"
        case .led:
            return "Light"
        case .rgbLight:
            return "RgbLight"
        case .color:
            return "Color"
        case .horn:
            return "Speaker"
        case .ultrasound:
            return "Ultrasonic"
        case .gyro:
            return "Gyro"
        case .light:
            return "EnLight"
        case .gravity:
            return "Gravity"
        case .nixieTube:
            return "DigitalTube"
        case .sound:
            return "Sound"
        case .sensirion:
            return "Temperature"
        default:
            return ""
        }
    }
    
    var version:String?{
        if let info = KylBluetoothManager.shared.curDevice?.deviceInfo{
            switch self {
            case .infrared:
                return info.infrared?.version
            case .touch:
                return info.touch?.version
            case .led:
                return info.led?.version
            case .rgbLight:
                return info.rgbLight?.version
            case .color:
                return info.color?.version
            case .horn:
                return info.horn?.version
            case .ultrasound:
                return info.ultrasound?.version
            case .gyro:
                return info.gyro?.version
            case .motor:
                return info.motor?.version
            case .servo:
                return info.servo?.version
            case .masterboard:
                return info.version
            default:
                return nil
            }
        }
        return nil
    }
    
    
    
    var normal:[UInt]?{
        if let info = KylBluetoothManager.shared.curDevice?.deviceInfo{
            switch self {
            case .infrared:
                return info.infrared?.normal
            case .touch:
                return info.touch?.normal
            case .led:
                return info.led?.normal
            case .rgbLight:
                return info.rgbLight?.normal
            case .color:
                return info.color?.normal
            case .horn:
                return info.horn?.normal
            case .ultrasound:
                return info.ultrasound?.normal
            case .gyro:
                return info.gyro?.normal
            case .motor:
                return info.motor?.normal
            case .servo:
                return info.servo?.normal
            default:
                return nil
            }
        }
        return nil
    }
    
    var abnormal:[UInt]?{
        if let info = KylBluetoothManager.shared.curDevice?.deviceInfo{
            switch self {
            case .infrared:
                return info.infrared?.abnormal
            case .touch:
                return info.touch?.abnormal
            case .led:
                return info.led?.abnormal
            case .rgbLight:
                return info.rgbLight?.abnormal
            case .color:
                return info.color?.abnormal
            case .horn:
                return info.horn?.abnormal
            case .ultrasound:
                return info.ultrasound?.abnormal
            case .gyro:
                return info.gyro?.abnormal
            case .motor:
                return info.motor?.abnormal
            case .servo:
                return info.servo?.abnormal
            default:
                return nil
            }
        }
        return nil
    }
    
    
    
    var diffVersion:[UInt]?{
        if let info = KylBluetoothManager.shared.curDevice?.deviceInfo{
            switch self {
            case .infrared:
                return info.infrared?.diffVersion
            case .touch:
                return info.touch?.diffVersion
            case .led:
                return info.led?.diffVersion
            case .rgbLight:
                return info.rgbLight?.diffVersion
            case .color:
                return info.color?.diffVersion
            case .horn:
                return info.horn?.diffVersion
            case .ultrasound:
                return info.ultrasound?.diffVersion
            case .gyro:
                return info.gyro?.diffVersion
            case .motor:
                return info.motor?.diffVersion
            case .servo:
                return info.servo?.diffVersion
            default:
                return nil
            }
        }
        return nil
    }
}

public enum KYLMotorDirection:Int{
    case clockwise = 1
    case anticlockwise = 2
}

public enum KYLServoRotationMode:UInt8{
    case stop          = 0
    case clockwise     = 1
    case anticlockwise = 2
}

public enum KYLServoLEDState:UInt8{
    case on    = 0
    case off   = 1
}

public enum KYLLEDControlState :UInt8{
    case always      = 0
    case off         = 1
    case singleFlash = 2
    case doubleFlash = 3
}

public enum KYLRGBLightExpression:UInt16 {
    case sleep = 0
    case shy   = 1
}

public enum KYLVerifyError:Int{
    case unsupported = 1, systemError
}


public enum KYLReadError:Int{
    case badResponse = 1, restarted, systemError
}


public enum KYLWritePriority:Int{
    case low = 1, normal, high, highest
}

public enum KYLConnectState:Int{
    case disconnected, connecting, connected, disconnecting
}


public struct KYLDeviceInfo {
    public var version:String?
    public var power:KYLPowerInfo?
    
    public var servo:KYLPeriInfo?
    
    public var infrared:KYLPeriInfo?
    public var motor:KYLPeriInfo?
    public var gyro:KYLPeriInfo?
    public var touch:KYLPeriInfo?
    public var led:KYLPeriInfo?
    public var horn:KYLPeriInfo?
    public var color:KYLPeriInfo?
    public var ultrasound:KYLPeriInfo?
    public var rgbLight:KYLPeriInfo?
    
}

public struct KYLPeriInfo {
    public var normal:[UInt]?
    public var abnormal:[UInt]?
    public var diffVersion:[UInt]?
    public var version:String? //版本不一致的时候 取最小ID的版本号
}

public enum KYLDeviceUpdatedInfo{
    
    case lowPower
    case highPower
    case charging
    case servoAngle
    case power(Int)
    case blocked(KYLComponentType,[UInt8])
    
    var desc:String{
        switch self {
        case .lowPower:
            return KYLLocalizedString("Battery_less_than").replacingOccurrences(of: "{0}", with: "20")
        case .servoAngle:
            return KYLLocalizedString("hand_damp_warming_tips")
        case .power(let n):
            if n == 0 {
                return KYLLocalizedString("系统电量过低")
            }
            return KYLLocalizedString("系统电量过高")
        default:
            return ""
        }
    }
}


public enum KYLErrorOption{
    //case version //版本问题
    case lowPower(type:KYLComponentType,ids:[UInt])
    case highPower(type:KYLComponentType,ids:[UInt])
    case blocked(type:KYLComponentType,ids:[UInt])       //堵转保护
    case temperature(type:KYLComponentType,ids:[UInt])   //温度保护
    case overvoltage(type:KYLComponentType,ids:[UInt])   //过压保护
    case undervoltage(type:KYLComponentType,ids:[UInt])  //欠压保护
    case current(type:KYLComponentType,ids:[UInt])       //电流保护
    case fuseEncrypt(type:KYLComponentType,ids:[UInt])   //熔丝位或加密位错误保护
    case other(type:KYLComponentType,ids:[UInt])         //其它类型异常
    
    var description:String{
        switch self {
        case .lowPower(_,_):
            return KYLLocalizedString("exception_tip_19")
        case .highPower(_,_):
            return KYLLocalizedString("exception_tip_20")
        case .blocked(let type,let ids):
            if type == .servo{
                return KYLLocalizedString("exception_tip_1").replacingOccurrences(of: "%s", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }else{
                return KYLLocalizedString("exception_tip_6").replacingOccurrences(of: "%s", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }
        case .temperature(let type,let ids):
            if type == .servo{
                return KYLLocalizedString("exception_tip_3").replacingOccurrences(of: "%s", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }else{
                return "马达无该异常"
            }
        case .overvoltage(let type, let ids):
            if type == .servo{
                return KYLLocalizedString("exception_tip_2").replacingOccurrences(of: "%s", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }else{
                return "马达无该异常"
            }
        case .undervoltage(let type, let ids):
            if type == .servo{
                return KYLLocalizedString("exception_tip_2").replacingOccurrences(of: "%s", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }else{
                return "马达无该异常"
            }
        case .current(let type,let ids):
            if type == .servo{
                return KYLLocalizedString("exception_tip_2").replacingOccurrences(of: "%s", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }else{
                return "马达无该异常"
            }
        case .fuseEncrypt(let type,let ids):
            if type == .servo{
                return KYLLocalizedString("exception_tip_25").replacingOccurrences(of: "%s", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }else{
                return "马达无该异常"
            }
        case .other(let type,let ids):
            if type == .servo{
                return KYLLocalizedString("exception_other_servo").replacingOccurrences(of: "{0}", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }else{
                return KYLLocalizedString("other_exception_motor").replacingOccurrences(of: "{0}", with: "\(ids.map{String($0)}.joined(separator: ","))")
            }
        }
    }
}

//Add by Glen @2019.5.15
public enum KYLConnectErrorType: String {
    case searchJimu = "searchJimu"
    case servoIdRepeat = "servoIdRepeat"
    case servoVSLine = "servoVSLine"
    case servoNumVsLine = "servoNumVsLine"
    case servoLineError = "servoLineError"
    case firmwareUpdateError = "firmwareUpdateError"
    case systemHelp = "systemHelp"
    case connectFail = "connectFail"
}

public struct KYLPowerInfo {
    public var voltage:Float?    //电压值
    public var percent:Float?    //电压百分比
    public var charging:Bool?    //是否充电
    public var complete:Bool?    //充电是否完成
    public var isDryBattery:Bool? //是否干电池 大于12.8v
}


public enum KYLPhoneStateError:Int{
    case unsupported    = 1
    case unauthorized
    case powerOff
}

public enum KYLConnectError:Int{
    case unexisting = 1
    case systemError
}

public enum KYLDisconnectError:Int{
    case systemError    = 1
}


public enum KYLComponentsMatchResult:Int {
    case normal
    case added
    case missing
    case duplicated
    case only
}

public enum KYLComponentsMatchResultLevel:Int{
    case error    = 0
    case warning  = 1
    case common   = 2
}


public enum KYLMasterboardType:Int{
    case old = 0
    case new
}


public enum KYLBluetoothDisConnectType:Int{
    case normal
    case upgrading
}

