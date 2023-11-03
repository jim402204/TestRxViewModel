//
//  RxBlockingTest.swift
//  TestRxViewModelTests
//
//  Created by Jim on 2023/11/2.
//

@testable import TestRxViewModel
import XCTest
import RxSwift
import RxBlocking

final class RxBlockingTest: XCTestCase {

    var sut: LoginViewModel!
    var bag: DisposeBag!
    
    override func setUpWithError() throws {
        bag = DisposeBag()
        sut = LoginViewModel(api: APIStub())
    }

    override func tearDownWithError() throws {
        bag = nil
        sut = nil
    }

    func test1() {
        
        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("402204jim")
        
        XCTAssert(sut.output.buttonIsEncable.value)
        
//        let result = try? sut.output.buttonIsEncable.take(1).skip(1).toBlocking().first()
//        let result = try? sut.output.buttonIsEncable.toBlocking().first()
//        dump(result, name: "test1")
//        XCTAssertEqual(result, true)
    }
    
    func test2() throws {
        
        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("402204jim")
        
        sut.output.toastInfo
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                XCTAssertEqual(model, ToastInfo.getMsg(.success))
            })
            .disposed(by: bag)
        
        sut.input.tapButton.accept(())
    }
    
    func test22() throws {
        
        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("402204jim")
        
        DispatchQueue.main.async {
            self.sut.input.tapButton.accept(())
        }
        
        let result = try sut.output.toastInfo.toBlocking(timeout: 1).first()
        XCTAssertEqual(result, ToastInfo.getMsg(.success))
    }
    
    func testToastInfoAfterDoubleTapButton() throws {
        
        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("402204jim")

        // 异步触发两次点击
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.sut.input.tapButton.accept(())
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sut.input.password.accept("1")
            self.sut.input.tapButton.accept(())
        }

        // 尝试获取两个元素
        let results = try sut.output.toastInfo.take(2).toBlocking(timeout: 1).toArray()
        dump(results, name: "results")
        // 断言结果是否有两个元素
        XCTAssertEqual(results, [ToastInfo.getMsg(.success), ToastInfo.getMsg(.invalidPassword)])
    }
    
    func test3() {
        
        sut.input.email.accept("invalidEmail")
        sut.input.password.accept("402204jim")
        
        DispatchQueue.main.async {
            self.sut.input.tapButton.accept(())
        }
        
        let result = try? sut.output.toastInfo.toBlocking(timeout: 1).first()
       
        XCTAssertEqual(result, ToastInfo.getMsg(.invalidEmail))
    }
    
    func test4() {
        
        sut.input.email.accept("jim402204@gmail.com")
        sut.input.password.accept("invalidPassword")
        
        // 创建后台队列的 Scheduler
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

        // 在后台队列上异步执行 tapButton
        scheduler.schedule(()) { _ in
            self.sut.input.tapButton.accept(())
            return Disposables.create()
        }
        
        let result = try? sut.output.toastInfo.toBlocking(timeout: 1).first()
//        dump(result, name: "result")
        
        XCTAssertEqual(result, ToastInfo.getMsg(.invalidPassword))
    }
    
    
}
