//
//  LoginViewModel.swift
//  CoursePass
//
//  Created by Jim on 2023/10/27.
//


import Foundation
import RxSwift
//import RxRelay
import RxCocoa

enum InfoType: Equatable {
case error
case info
}

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

protocol APIService {
    func login() -> Single<Bool>
}

struct ToastInfo: Equatable {
    let type: InfoType
    let text: String
}

class LoginViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let email: BehaviorRelay<String>
        let password: BehaviorRelay<String>
        let tapButton: PublishRelay<Void>
    }
    struct Output {
        let buttonIsEncable: BehaviorRelay<Bool>
        let toast: PublishRelay<(type: InfoType,text: String)>
        let toastInfo: PublishRelay<ToastInfo>
    }
    
    var input: Input
    var output: Output
    
    
    init(api: APIService, scheduler: SchedulerType = MainScheduler.instance) {

        let email = BehaviorRelay<String>(value: "")
        let password = BehaviorRelay<String>(value: "")
        
        let isEnabledRelay = BehaviorRelay<Bool>(value: false)
//        let isEnabled =
        Observable.combineLatest(email,password)
            .map { !$0.trimming().isEmpty && !$1.trimming().isEmpty }
            .distinctUntilChanged()
            .bind(to: isEnabledRelay)
            .disposed(by: disposeBag)

        let tapButton = PublishRelay<Void>()
        let toast = PublishRelay<(type: InfoType,text: String)>()
        let toastInfo = PublishRelay<ToastInfo>()
        
        self.input = Input(email: email, password: password,
                           tapButton: tapButton)
        
        self.output = Output(buttonIsEncable: isEnabledRelay,
                             toast: toast,
                             toastInfo: toastInfo)
        
        tapButton
            .debounce(.milliseconds(300), scheduler: scheduler)
            .filter { isEnabledRelay.value }
            .filter { [unowned self] in
                guard email.value.isEmail() else {
                    toast.accept((.error, "信箱格式錯誤，請重新輸入"))
                    toastInfo.accept(ToastInfo(type: .error,text: "信箱格式錯誤，請重新輸入"))
                    return false
                }
                guard password.value.isPassword() else {
                    toast.accept((.error, "密碼格式錯誤，請重新輸入"))
                    toastInfo.accept(ToastInfo(type: .error,text: "密碼格式錯誤，請重新輸入"))
                    return false
                }
                return true
            }
            .flatMapLatest { [unowned self] in
                api.login()
            }
            .subscribe(onNext: { [weak self] respone in
                guard let self = self else { return }
                //                 guard let model = respone.data else { return }
                
                
                toast.accept((.info, "登入成功！"))
                toastInfo.accept(ToastInfo(type: .info,text: "登入成功！"))
            })
            .disposed(by: disposeBag)
        
        
        
    }
    
    
}


//emailTextField.rx.text.orEmpty
//    .bind(to: viewModel.input.email)
//    .disposed(by: disposeBag)
//
//passwordTextField.rx.text.orEmpty
//    .bind(to: viewModel.input.password)
//    .disposed(by: disposeBag)
//
//viewModel.output.buttonIsEncable
//    .debug("buttonIsEncable")
//    .bindingColor(button: confirmButton, disposeBag: disposeBag)
//
//
//confirmButton.rx.tap
//    .bind(to: viewModel.input.tapButton)
//    .disposed(by: disposeBag)
//
//viewModel.output.toast
//    .subscribe(onNext: { [weak self] toast in
//        guard let self = self else { return }
//        ToastView().showView(type: toast.type, text: toast.text)
//    })
//    .disposed(by: disposeBag)
