//
//  ReactiveOperativeSignatureViewModelTest.swift
//  Operative-Unit-Tests
//
//  Created by David Gálvez Alonso on 28/3/22.
//

import UnitTestCommons
import XCTest
import OpenCombine
import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary

@testable import Operative

class ReactiveOperativeSignatureViewModelTest: XCTestCase {

    lazy var dependenciesExternal = TestReactiveSignatureExternalDependenciesResolver()
    private var sut: ReactiveOperativeSignatureViewModel<MockSignatureStrategy>!
    
    override func setUp() {
        setDataBinding()
        self.sut = ReactiveOperativeSignatureViewModel(dependencies: dependenciesExternal, capability: MockSignatureStrategy(operative: MockOperative(dependencies: TestReactiveSignatureExternalDependenciesResolver())))
    }
    
    func test_Given_Signature_When_LoadedStateIsCalled_Then_SignatureRepresentableIsNotNil() throws {
        let publisher = sut.state
            .case(ReactiveOperativeSignatureState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.signature)
    }
    
    func test_Given_Signature_When_SetSignaturePositions_Then_IsAvailableToContinue() throws {
        let publisher = sut.state
            .case(ReactiveOperativeSignatureState.didChangeAvailabilityToContinue)
        sut.viewDidLoad()
        sut.didSetSignaturePositions(["1", "2", "3"])
        let result = try publisher.sinkAwait()
        XCTAssertTrue(result)
    }
    
    func test_Given_Signature_When_SetWrongSignaturePositions_Then_IsNotAvailableToContinue() throws {
        let publisher = sut.state
            .case(ReactiveOperativeSignatureState.didChangeAvailabilityToContinue)
        sut.viewDidLoad()
        sut.didSetSignaturePositions(["1", "2"])
        let result = try publisher.sinkAwait()
        XCTAssertFalse(result)
    }
    
    func test_GivenMockSignatureStrategyFailure_When_NextExecuted_Then_ErrorIsNotNil() throws {
        let publisher = sut.state
            .case(ReactiveOperativeSignatureState.showError)
        sut.next()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result)
    }
}

extension ReactiveOperativeSignatureViewModelTest {
    
    func setDataBinding() {
        let dataBinding: DataBinding = dependenciesExternal.resolve()
        let signatureRepresentable = SignatureDTO(length: 8, positions: [1, 3, 5])
        dataBinding.set(signatureRepresentable)
    }
}
