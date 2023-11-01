//
//  ApiProtocol.swift
//  vxu
//
//  Created by 江俊瑩 on 2022/3/4.
//

import Foundation
import Moya


var apiDomain = "https://api.dev.coursepass.tw"

/// 預先指定response的data type
protocol DecodableResponseTargetType: TargetType {
    associatedtype ResponseDataType: Codable
}

/// API的共用protocol，設定API共用參數，且api的response皆要可以被decode
protocol ApiTargetType: DecodableResponseTargetType {
    var timeout: TimeInterval { get }
}

let apiVersion = "/api/v1.3/"

/// 共用參數
extension ApiTargetType {
    var baseURL: URL { return URL(string: (apiDomain + apiVersion))! }
    var path: String { fatalError("path for ApiTargetType must be override") }
    var method: Moya.Method { return .get }
    var headers: [String : String]? { return nil }
    var task: Task { return .requestPlain }
    var timeout: TimeInterval { return 20 } //10
}


