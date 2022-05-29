//
//  ReactiveOperativeOTPViewModelTest.swift
//  Operative
//
//  Created by David Gálvez Alonso on 23/3/22.
//

import UnitTestCommons
import XCTest
import OpenCombine
import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary

@testable import Operative

class ReactiveOperativeOTPViewModelTest: XCTestCase {

    lazy var dependenciesExternal = TestReactiveOperativeOTPExternalDependenciesResolver()
    private var sut: ReactiveOperativeOTPViewModel<MockOTPStrategy>!
    
    override func setUp() {
        setDataBinding()
        self.sut = ReactiveOperativeOTPViewModel(dependencies: dependenciesExternal, capability: MockOTPStrategy(operative: MockOperative(dependencies: TestReactiveOperativeOTPExternalDependenciesResolver())))
    }
    
    func test_Given_MaxLength_When_LoadedStateIsCalled_Then_MaxLengthIsMoreThanZero() throws {
        let publisher = sut.state
            .case(ReactiveOperativeOTPState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertTrue(result.maxLength > 0)
    }
    
    func test_Given_MaxLength_When_SetCorrectOTP_Then_IsAvailableToContinue() throws {
        let publisher = sut.state
            .case(ReactiveOperativeOTPState.didChangeAvailabilityToContinue)
        sut.viewDidLoad()
        sut.didSetOTP("12345678")
        let result = try publisher.sinkAwait()
        XCTAssertTrue(result)
    }
    
    func test_Given_MaxLength_When_SetWrongOTP_Then_IsNotAvailableToContinue() throws {
        let publisher = sut.state
            .case(ReactiveOperativeOTPState.didChangeAvailabilityToContinue)
        sut.viewDidLoad()
        sut.didSetOTP("1234567")
        let result = try publisher.sinkAwait()
        XCTAssertFalse(result)
    }
    
    func test_Given_ResendCodeExecuted_Then_ErrorIsNotNil() throws {
        let publisher = sut.state
            .case(ReactiveOperativeOTPState.showError)
        sut.resendCode()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result)
    }
    
    func test_GivenMockOTPStrategyFailure_When_NextExecuted_Then_ErrorIsNotNil() throws {
        let publisher = sut.state
            .case(ReactiveOperativeOTPState.showError)
        sut.next()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result)
    }
}

extension ReactiveOperativeOTPViewModelTest {
    
    func setDataBinding() {
        let dataBinding: DataBinding = dependenciesExternal.resolve()
        let otpValidation: OTPValidationRepresentable = OTPValidationDTO()
        dataBinding.set(otpValidation)
    }
}
