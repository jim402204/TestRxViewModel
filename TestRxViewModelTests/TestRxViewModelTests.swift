//
//  TestRxViewModelTests.swift
//  TestRxViewModelTests
//
//  Created by Jim on 2023/10/27.
//

@testable import TestRxViewModel

import XCTest
import RxSwift
import RxCocoa
import RxTest

final class TestRxViewModelTests: XCTestCase {
    
    var sut: LoginViewModel!
    
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        bag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0, resolution: 0.1)
        sut = LoginViewModel(api: APIStub(), scheduler: scheduler)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        bag = nil
        scheduler = nil
    }

    func test1() {
        
        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("402204jim")
        
        XCTAssert(sut.output.buttonIsEncable.value)
        
        let item = BehaviorRelay<ToastInfo?>(value: nil)
        sut.output.toastInfo.bind(to: item).disposed(by: bag)

        self.sut.input.tapButton.accept(())
        scheduler.start()
        
        dump(item.value)
        XCTAssert(item.value! == ToastInfo(type: .info,text: "登入成功！"))
    }
    
    func test2() {

        sut.input.email.accept("jim402204@$")
        sut.input.password.accept("1")
        
        XCTAssert(sut.output.buttonIsEncable.value)
        
        let item = BehaviorRelay<ToastInfo?>(value: nil)
        sut.output.toastInfo.bind(to: item).disposed(by: bag)

        sut.input.tapButton.accept(())
        scheduler.start()

        dump(item.value)
        XCTAssert(item.value! == ToastInfo(type: .error,text: "信箱格式錯誤，請重新輸入"))
    }
    
    func test3() {

        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("1")
        
        XCTAssert(sut.output.buttonIsEncable.value)
        
        let item = BehaviorRelay<ToastInfo?>(value: nil)
        sut.output.toastInfo.bind(to: item).disposed(by: bag)

        sut.input.tapButton.accept(())
        scheduler.start()

        dump(item.value)
        XCTAssert(item.value! == ToastInfo(type: .error,text: "密碼格式錯誤，請重新輸入"))
    }

    func test4() {

        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("")
        
        XCTAssertFalse(sut.output.buttonIsEncable.value)
        scheduler.start()
        
        let item = BehaviorRelay<ToastInfo?>(value: nil)
        sut.output.toastInfo.bind(to: item).disposed(by: bag)

        sut.input.tapButton.accept(())

        dump(item.value)
        XCTAssertNil(item.value)
    }

}

