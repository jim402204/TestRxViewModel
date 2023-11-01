//
//  GPTRxViewModelTest.swift
//  TestRxViewModelTests
//
//  Created by Jim on 2023/10/30.
//

@testable import TestRxViewModel
import XCTest
import RxSwift
import RxTest

final class GPTRxViewModelTest: XCTestCase {

    var viewModel: LoginViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var mockAPI: APIServiceProtocol!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        scheduler = TestScheduler(initialClock: 0, resolution: 0.1)
        disposeBag = DisposeBag()
        mockAPI = APIStub()
        viewModel = LoginViewModel(api: mockAPI, scheduler: scheduler)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        scheduler = nil
        disposeBag = nil
        mockAPI = nil
    }

    func testButtonEnabledWhenEmailAndPasswordAreValid() {
        // Arrange
        let expectedButtonEnabledEvents = [Recorded.next(0, false), Recorded.next(10, true)]
        let buttonObserver = scheduler.createObserver(Bool.self)

        viewModel.output.buttonIsEncable.bind(to: buttonObserver).disposed(by: disposeBag)
        
        // Act
        scheduler.createColdObservable([.next(10, ("validEmail@example.com", "validPassword123"))])
            .subscribe(onNext: { [weak self] email, password in
                self?.viewModel.input.email.accept(email)
                self?.viewModel.input.password.accept(password)
            })
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        // Assert
        XCTAssertEqual(buttonObserver.events, expectedButtonEnabledEvents)
    }
    
    func testButtonEnabledWhenEmailAndPasswordAreValid2() {
       
        let result = scheduler.record(viewModel.output.buttonIsEncable, disposeBag: disposeBag)
        
        scheduler.scheduleAt(10) {
            self.viewModel.input.email.accept("validEmail@example.com")
            self.viewModel.input.password.accept("validPassword123")
        }
        
        scheduler.scheduleAt(11) {
            self.viewModel.input.password.accept("")
        }
        
        scheduler.start()
        
        XCTAssertEqual(result.events, [
            Recorded.next(0, false),
            Recorded.next(10, true),
            Recorded.next(11, false)
        ])
        
    }
    
    func testInvalidEmailToastMessage() {
        
        let result = scheduler.record(viewModel.output.toastInfo, disposeBag: disposeBag)
        viewModel.input.email.accept("invalidEmail")
        viewModel.input.password.accept("validPassword123")
        
        scheduler.scheduleAt(7) {
            self.viewModel.input.tapButton.accept(())
        }
        
        scheduler.start()
        
        XCTAssertEqual(result.events, [Recorded.next(10, ToastInfo(type: .error, text: "信箱格式錯誤，請重新輸入"))])
    }

    func testInvalidPasswordToastMessage() {
        
        let result = scheduler.record(viewModel.output.toastInfo, disposeBag: disposeBag)
        viewModel.input.email.accept("validEmail@example.com")
        viewModel.input.password.accept("invalidPassword")
        
        scheduler.scheduleAt(7) {
            self.viewModel.input.tapButton.accept(())
        }
        
        scheduler.start()
        
        XCTAssertEqual(result.events, [Recorded.next(10, ToastInfo(type: .error, text: "密碼格式錯誤，請重新輸入"))])
    }

    func testSuccessfulLoginToastMessage() {
       
        let result = scheduler.record(viewModel.output.toastInfo, disposeBag: disposeBag)
        viewModel.input.email.accept("validEmail@example.com")
        viewModel.input.password.accept("validPassword123")
        
        scheduler.scheduleAt(7) {
            self.viewModel.input.tapButton.accept(())
        }
        
        scheduler.start()
        
        XCTAssertEqual(result.events, [Recorded.next(10, ToastInfo(type: .info, text: "登入成功！"))])
    }
    
}

