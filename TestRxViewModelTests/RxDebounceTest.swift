//
//  RxDebounceTest.swift
//  TestRxViewModelTests
//
//  Created by Jim on 2023/10/31.
//

@testable import TestRxViewModel
import XCTest
import RxSwift
import RxTest
import RxCocoa
import RxRelay

class RxDebounceTest: XCTestCase {

    //virtual time unit is ceil(seconds / resolution).
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp() //resolution 0.1  milliseconds(300) = 3
        scheduler = TestScheduler(initialClock: 0, resolution: 0.1)
        disposeBag = DisposeBag()
    }

    func testSuccessfulLoginToast() {
        
        // Arrange
        let mockAPIService = MockLoginAPI()
        let viewModel = LoginViewModel(api: mockAPIService, scheduler: scheduler)
        
//        let toastInfoObserver = scheduler.createObserver(ToastInfo.self)
//        viewModel.output.toastInfo.bind(to: toastInfoObserver).disposed(by: disposeBag)

        let result = scheduler.record(viewModel.output.toastInfo, disposeBag: disposeBag)
        
        viewModel.input.email.accept("test@example.com")
        viewModel.input.password.accept("Password123")

        scheduler.scheduleAt(10) {
            viewModel.input.tapButton.accept(())
        }
        // Act
//        scheduler.createColdObservable([.next((10), ())])
//            .subscribe(onNext: { _ in
//                viewModel.input.tapButton.accept(())
//            })
//            .disposed(by: disposeBag)

        scheduler.start()

        
        //TestTime 只比較正數 單位是秒 sec 在小都會視為1sec
        XCTAssertEqual(result.events, [Recorded.next(13, ToastInfo(type: .info, text: "登入成功！"))])
    }
    
    
//    func testDebounceEffect() {
////        let scheduler = TestScheduler(initialClock: 0)
////        let disposeBag = DisposeBag()
//
//        let input = PublishSubject<String>()
//        let output = input.debounce(.milliseconds(10), scheduler: scheduler)
//
//        let observer = scheduler.createObserver(String.self)
//        output.subscribe(observer).disposed(by: disposeBag)
//
//        // 在 tick 1 發射一個值
//        scheduler.createColdObservable([.next(1, "Value1"), .next(9, "Value2"), .next(11, "Value3")])
//            .bind(to: input)
//            .disposed(by: disposeBag)
//
//        // 進度到 tick 20
//        scheduler.advanceTo(20)
//
//        // 因為 debounce 的效果，只有 "Value3" 在 10ms 後被發射
//        XCTAssertEqual(observer.events, [Recorded.next(21, "Value3")])
//    }
    
}
