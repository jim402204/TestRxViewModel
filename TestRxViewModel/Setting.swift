//
//  Setting.swift
//  TestRxViewModel
//
//  Created by Jim on 2023/11/1.
//

import Foundation

extension String {
    
    func trimming() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func matches(pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// EMAIL格式即必須要有@gmail.com  、 @yahoo.com.tw等含@的格式 即僅接受字母(a-z)、數字(0-9)和小數點(.)
    func isEmail() -> Bool {
        return self.matches(pattern: "^[a-zA-Z0-9.+]+@[a-zA-Z0-9.]+$")
    }
    
    func isPassword() -> Bool {
        return self.matches(pattern: "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$")
    }
}

protocol ViewModelType: AnyObject {
   associatedtype Input
   associatedtype Output

   var input: Input { get }
   var output: Output { get }
}

enum InfoType: Equatable {
    case error
    case info
}

struct ToastInfo: Equatable {
    let type: InfoType
    let text: String
    
    enum MagType {
        case invalidEmail
        case invalidPassword
        case success
    }
    
    static func getMsg(_ type: MagType) -> ToastInfo {
        
        switch type {
        case .invalidEmail: return ToastInfo(type: .error, text: "信箱格式錯誤，請重新輸入")
        case .invalidPassword: return ToastInfo(type: .error, text: "密碼格式錯誤，請重新輸入")
        case .success: return ToastInfo(type: .info, text: "登入成功！")
        }
    }
    
}
