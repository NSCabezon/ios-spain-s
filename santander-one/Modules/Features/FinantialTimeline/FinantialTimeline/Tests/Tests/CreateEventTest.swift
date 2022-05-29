//
//  CreateEventTest.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 04/09/2019.
//

import Foundation
import XCTest
import Nimble
@testable import FinantialTimeline

class CreateEventTests: XCTestCase {
    
    var timeLineApiRepository: TimeLineApiRepository!
    
    override func setUp() {
        super.setUp()
        timeLineApiRepository = TimeLineApiRepository(
            host: URL(string: "https://ib-finantialtimeline-backend.develop.blue4sky.com")!,
            restClient: IntelligentBankingRestClient(),
            authorization: .token("test_ios")
        )
    }
    
    override func tearDown() {
        timeLineApiRepository = nil
        super.tearDown()
    }
    
//    func test_createEventService() {
//        let event = CreateCustomEvent(title: "Comprar comics", description: "Comprar comic de Spiderman", startDate: Date().string(format: .yyyyMMdd), endDate: nil, frequency: .withoutFrequency)
//        waitUntil { done in
//            self.timeLineApiRepository.createCustomEvent(event) { result in
//                switch result {
//                case .success:
//                    XCTAssert(true)
//                case .failure(let error):
//                    XCTFail(error.localizedDescription)
//                }
//                done()
//            }
//        }
//    }
}
