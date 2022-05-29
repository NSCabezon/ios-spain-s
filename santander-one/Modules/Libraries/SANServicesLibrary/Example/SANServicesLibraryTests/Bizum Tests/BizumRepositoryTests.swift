//
//  BizumRepositoryTests.swift
//  SANServicesLibrayTests
//
//  Created by José Carlos Estela Anguita on 20/5/21.
//

import XCTest
@testable import SANServicesLibrary
import SANSpainLibrary

final class BizumRepositoryTests: XCTestCase {
    
    private lazy var servicesLibrary: ServicesLibrary = {
        return ServicesLibrary(soapClient: DemoClient(demoResponses: [:]), restClient: DemoClient(demoResponses: ["check-payment": 0]), environment: Environment.pre)
    }()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        _ = self.servicesLibrary.loginManager.loginWithUser("12345678z", magic: "14725836", type: "N")
    }
    
    override func tearDown() {
        super.tearDown()
        self.servicesLibrary.update(soapClient: DemoClient(demoResponses: [:]), restClient: DemoClient(demoResponses: ["check-payment": 0]))
    }
    
    func test_checkPayment_whenTheResponseIsSuccessfull_shouldReturnASuccessResponse() throws {
        let checkPaymentResponse = servicesLibrary.bizumRepository.checkPayment(defaultXPAN: "")
        switch checkPaymentResponse {
        case .failure:
            XCTExpectFailure()
        case .success:
            XCTAssert(true)
        }
    }
    
    func test_checkPayment_whenModifyingTheDefaultXPAN_theResponseShouldReturnTheProperXPAN() throws {
        self.servicesLibrary.update(
            soapClient: DemoClient(demoResponses: [:]),
            restClient: DemoClient(demoResponses: ["check-payment": 3])
        )
        let checkPaymentResponse = servicesLibrary.bizumRepository.checkPayment(defaultXPAN: "123123123")
        switch checkPaymentResponse {
        case .failure:
            XCTExpectFailure()
        case .success(let checkPayment):
            XCTAssert(checkPayment.xpan == "123123123")
        }
    }
    
    func test_checkPayment_whenTheResponseIsAnError_shouldReturnAnError() {
        self.servicesLibrary.update(
            soapClient: DemoClient(demoResponses: [:]),
            restClient: DemoClient(demoResponses: ["check-payment": 2])
        )
        let checkPaymentResponse = servicesLibrary.bizumRepository.checkPayment(defaultXPAN: "")
        switch checkPaymentResponse {
        case .failure:
            XCTAssert(true)
        case .success:
            XCTExpectFailure()
        }
    }
}


extension String: LoginTypeRepresentable {
    public var type: String {
        return self
    }
}
