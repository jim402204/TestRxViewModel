//
//  LoginApi.swift
//  TestRxViewModel
//
//  Created by Jim on 2023/11/1.
//

import Moya
import Foundation

/// API的共用protocol，設定共用參數，且response皆要可以被decode
protocol RegisterTargetType: ApiTargetType {}

/// 共用參數
extension RegisterTargetType {
        
    var headers: [String : String]? {
        return [
            "Content-Type":"application/json",
            "Device-Type":"ios",
            "Accept":"application/json",
//            "Authorization": "Bearer \(UserDefaultsHelper.token ?? "")"
        ]
    }
    
    typealias DefaultModel = [String:String]
}

enum LoginApi {
   
    //MARK: - 登入
    struct Login: RegisterTargetType {
        typealias ResponseDataType = BaseResponseData<Int>
        
        var method: Moya.Method { return .post }
        var path: String { return "user/login" }
        var task: Task { .requestParameters(parameters: parameters, encoding: JSONEncoding.default) }
        private var parameters: [String:Any] = [:]

        init(email: String, password: String, pushToken: String = "") {
            
            parameters["email"] = email
            parameters["password"] = password
            parameters["type"] = "ios"
        }
    }
    
    //MARK: - 登出
    struct Logout: RegisterTargetType {
        typealias ResponseDataType = BaseResponseData<String>
        
        var method: Moya.Method { return .post }
        var path: String { return "user/logout" }
        var task: Task { .requestParameters(parameters: parameters, encoding: JSONEncoding.default) }
        private var parameters: [String:Any] = [:]
    }
    
}

