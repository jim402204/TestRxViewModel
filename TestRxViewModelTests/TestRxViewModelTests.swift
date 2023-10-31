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

class APIStub: APIService {
    func login() -> RxSwift.Single<Bool> {
        Single.just(true)
    }
}

final class TestRxViewModelTests: XCTestCase {
    
    var sut: LoginViewModel!
    
//    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = LoginViewModel(api: APIStub())
        bag = DisposeBag()
//        scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        bag = nil
//        scheduler = nil
    }

    func test1() {
        
//        let toastObserver = scheduler.createObserver((type: InfoType,text: String).self)
//        sut.output.toast.bind(to: toastObserver).disposed(by: bag)
        
        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("402204jim")
        
        XCTAssert(sut.output.buttonIsEncable.value)
        
        let item = BehaviorRelay<(type: InfoType,text: String)?>(value: nil)

        sut.output.toast
            .bind(to: item)
            .disposed(by: bag)

        sut.input.tapButton.accept(())

        dump(item.value)
        XCTAssert(item.value! == (.info,"登入成功！"))
//        XCTAssert(item.value == (.error,"信箱格式錯誤，請重新輸入"))
        
        
//        XCTAssertTrue(toastObserver.events[0].value.element! == (.info, "登入成功！"))
//        dump(toastObserver.events[0].value.element)
    }
    
    func test2() {

        sut.input.email.accept("jim402204@$")
        sut.input.password.accept("1")
        
        XCTAssert(sut.output.buttonIsEncable.value)
        
        let item = BehaviorRelay<(type: InfoType,text: String)?>(value: nil)
        sut.output.toast.bind(to: item).disposed(by: bag)

        sut.input.tapButton.accept(())

        dump(item.value)
        
        XCTAssert(item.value! == (.error,"信箱格式錯誤，請重新輸入"))
    }
    
    func test3() {

        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("1")
        
        XCTAssert(sut.output.buttonIsEncable.value)
        
        let item = BehaviorRelay<(type: InfoType,text: String)?>(value: nil)
        sut.output.toast.bind(to: item).disposed(by: bag)

        sut.input.tapButton.accept(())

        dump(item.value)
        
        XCTAssert(item.value! == (.error,"密碼格式錯誤，請重新輸入"))
    }

    func test4() {

        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("")
        
        XCTAssertFalse(sut.output.buttonIsEncable.value)
        
        let item = BehaviorRelay<(type: InfoType,text: String)?>(value: nil)
        sut.output.toast.bind(to: item).disposed(by: bag)

        sut.input.tapButton.accept(())

        dump(item.value)
        
        XCTAssertNil(item.value)
    }

}

