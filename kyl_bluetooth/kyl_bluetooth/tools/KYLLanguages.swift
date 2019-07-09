//
//  KYLLanguages.swift
//  kyl_bluetooth
//
//  Created by yulu kong on 2019/7/8.
//  Copyright © 2019 yulu kong. All rights reserved.
//

import Foundation


public enum KYLLanguagesCode: String {
    /** 未知的 */
    case Unknown = "unknown"
    /** 英文 */
    case English = "en"
    /** 中文简体 */
    case ChineseSimplified = "zh-hans"
    /** 中文繁体 */
    case ChineseTraditional = "zh-hant"
    /** 法文 */
    case French = "fr"
    /** 德文 */
    case German = "de"
    /** 日文 */
    case Japanese = "ja"
    /** 西班牙文 */
    case Spanish = "es"
    /** 意大利文 */
    case Italian = "it"
    /** 葡萄牙文 */
    case Portugal = "pt"
    /** 韩文 */
    case Korean = "ko"
    /** 俄文 */
    case Russian = "ru"
    /** 波兰文 */
    case Polish = "pl"
    /** 阿拉伯文 */
    //case Arabic = "ar"
    /** 土耳其文 */
    case Turkish = "tr"
    /** 丹麦文 */
    case Danish = "da"
    /** 印尼语 */
    case Indonesian = "id"
    /** 泰语 */
    case Thai = "th"
    
    /** Unity语言编码 */
    func unityLanguageCode() -> String {
        var unityLanguageCode = "English"
        
        switch self {
        case .ChineseSimplified:
            unityLanguageCode = "China"
        case .ChineseTraditional:
            unityLanguageCode = "HokongChinese"
        case .German:
            unityLanguageCode = "German"
        case .Japanese:
            unityLanguageCode = "Japan"
        case .Italian:
            unityLanguageCode = "Italy"
        case .Korean:
            unityLanguageCode = "Korean"
        case .French:
            unityLanguageCode = "French"
        case .Spanish:
            unityLanguageCode = "Spanish"
        case .Portugal:
            unityLanguageCode = "Portugal"
        case .Russian:
            unityLanguageCode = "Russian"
        case .Polish:
            unityLanguageCode = "Polski"
        case .Turkish:
            unityLanguageCode = "Turkish"
        case .Danish:
            unityLanguageCode = "Danish"
        case .Indonesian:
            unityLanguageCode = "Indonesian"
        case .Thai:
            unityLanguageCode = "Thai"
        default:
            break
        }
        
        return unityLanguageCode
    }
}

class KYLLanguages: NSObject {
    private static var languageCode: KYLLanguagesCode = .Unknown
    
    /** 匹配系统语言 */
    @discardableResult
    public class func matchSystemLanguage() -> Bool {
        var result = false
        
        if languageCode != .Unknown {
            return true
        }
        
        let languages = Locale.preferredLanguages
        if languages.count > 0 {
            result = true
            let currentLanguage = languages[0].lowercased()
            if currentLanguage.hasPrefix(KYLLanguagesCode.ChineseSimplified.rawValue) {
                languageCode = .ChineseSimplified
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.ChineseTraditional.rawValue) || currentLanguage.hasPrefix("zh-hk") || currentLanguage.hasPrefix("zh-tw") {
                languageCode = .ChineseTraditional
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.German.rawValue) {
                languageCode = .German
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Japanese.rawValue) {
                languageCode = .Japanese
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Italian.rawValue) {
                languageCode = .Italian
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.French.rawValue) {
                languageCode = .French
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Spanish.rawValue) {
                languageCode = .Spanish
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Portugal.rawValue) {
                languageCode = .Portugal
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.English.rawValue) {
                languageCode = .English
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Korean.rawValue) {
                languageCode = .Korean
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Russian.rawValue) {
                languageCode = .Russian
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Polish.rawValue) {
                languageCode = .Polish
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Turkish.rawValue) {
                languageCode = .Turkish
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Danish.rawValue) {
                languageCode = .Danish
            } else if currentLanguage.hasPrefix(KYLLanguagesCode.Indonesian.rawValue) {
                languageCode = .Indonesian
            }else if currentLanguage.hasPrefix(KYLLanguagesCode.Thai.rawValue) {
                languageCode = .Thai
            }
            else {
                result = false
            }
        }
        
        return result
    }
    
    @objc public class func languageCodeToUnity() -> String {
        return languageCode.unityLanguageCode()
    }
    
    public class func languageCodeToService() -> KYLLanguagesCode {
        if languageCode == .Unknown {
            return KYLLanguagesCode.English
        }
        return languageCode
    }
    
    //blockly不支持印尼语，先用英文代替, 待blockly支持印尼语后去掉这个方法，用languageCodeToService代替
    public class func languageCodeToBlockly() -> KYLLanguagesCode {
        if languageCode == .Unknown{
            return KYLLanguagesCode.English
        }
        return languageCode
    }
}

public func KYLLocalizedString(_ key: String, comment: String = "") -> String {
    return NSLocalizedString(key, comment: comment)
}

/** 替换占位符(两个#) */
public func KYLLocalizedReplacingPlaceholder(localizedString: String, replace: String) -> String {
    var string = localizedString
    
    do {
        let pattern = "#.*?#"
        let regular = try NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        string = regular.stringByReplacingMatches(in: localizedString, options: .reportProgress, range: NSMakeRange(0, localizedString.count), withTemplate: replace)
    } catch {}
    
    return string
}
