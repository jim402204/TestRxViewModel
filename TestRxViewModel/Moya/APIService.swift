//
//  APIService.swift
//  vxu
//
//  Created by 江俊瑩 on 2022/3/4.
//

import Moya
import RxSwift

struct BaseResponseData<T: Codable>: Codable {
    var status: Int
    var data: T?
    var msg: String?
}

var apiService = APIService.shared

final class APIService {
    static let shared = APIService()
    
    init() {}
    lazy var provider = MoyaProvider<MultiTarget>(session: customSession())
    
    func request<Request: ApiTargetType>(_ request: Request) -> Single<Request.ResponseDataType> {
        
        let target = MultiTarget.init(request)
   
        return provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .map(Request.ResponseDataType.self)
            
    }
    
    func customSession(timeout: Double = 20) -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        return Session(configuration: configuration, startRequestsImmediately: false)
    }
    
}

protocol APIServiceProtocol {
    func request<Request: ApiTargetType>(_ request: Request) -> Single<Request.ResponseDataType>
}

extension APIService: APIServiceProtocol {}

class APIStub: APIServiceProtocol {}

extension APIStub {
    func request<Request: ApiTargetType>(_ request: Request) -> RxSwift.Single<Request.ResponseDataType> {
        //LoginApi.Login.ResponseDataType
        let responseData = BaseResponseData<Int>(status: 200, data: 0, msg: "APIStub() mock API") as! Request.ResponseDataType
        return Single.just(responseData)
    }
}

