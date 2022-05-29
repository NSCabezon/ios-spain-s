//
//  GetInsuranceDetailEnabledUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

@testable import PrivateMenu
import XCTest

class GetInsuranceDetailEnabledUseCaseTest: XCTestCase {
    func test_When_fetchInsuranceDetailEnabled_Then_insuranceDetailEnabledReturned() throws {
        let sut = DefaultGetInsuranceDetailEnabledUseCase()
        
        let insuranceDetailEnabled = try sut.fetchInsuranceDetailEnabled().sinkAwait()
        XCTAssertNotNil(insuranceDetailEnabled)
        XCTAssertEqual(insuranceDetailEnabled, true)
    }
}
