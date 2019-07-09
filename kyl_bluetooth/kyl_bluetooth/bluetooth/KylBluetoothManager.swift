//
//  KylBluetoothManager.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/8.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import Foundation


@objc final class KylBluetoothManager:NSObject {
    @objc static let shared = KylBluetoothManager()
    @objc var isBluetoothOpened = false
    @objc var curDevice:KylBluetooth?
}
