//
//  KYLPerpheralInfo.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/9.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import CoreBluetooth

class KYLPerpheralInfo: NSObject {
    var serviceUUID = CBUUID()
    var characteristics = NSMutableArray()
    override init() {
        self.characteristics = NSMutableArray.init()
    }
}
