//
//  KYLLog.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/9.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import Foundation


let KSCREEN_WIDTH = UIScreen.main.bounds.size.width
let KSCREEN_HEIGHT = UIScreen.main.bounds.size.height
func KYLLog<T>(message : T?,file: String = #file,methodName: String = #function, lineNumber: Int = #line){
    #if DEBUG
    let fileName = NSString.init(string: (file as String)).lastPathComponent
    let line = String.init(format: "第%d行", lineNumber)
    let name = "======>"
    let date = NSDate()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyy-MM-dd 'at' HH:mm:ss.SSS"
    let strNowTime = timeFormatter.string(from: date as Date) as String
    print("[\(strNowTime)][\(fileName)\(line)]\(methodName)\(name)\(message)")
    #endif
}
