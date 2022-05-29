//
//  IntelligentBankingRestClientTests.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 15/07/2019.
//

import XCTest
import OHHTTPStubs
import Nimble
@testable import FinantialTimeline

class IntelligentBankingRestClientTests: XCTestCase {
    
    var restClient: IntelligentBankingRestClient!
    
    override func setUp() {
        super.setUp()
        restClient = IntelligentBankingRestClient()
    }
    
    override func tearDown() {
        restClient = nil
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func test_intelligentBankingRestClient_withoutQueryParams_shouldLoadUrlCorrectly() {
        stub(condition: isHost("test") && isPath("/timeline/events"), response: { _ in return TestHelpers.stubResponse(with: "empty.json", statusCode: 200) })
        waitUntil { done in
            self.restClient.request(host: "https://test", path: "/timeline/events", method: .get, headers: [:], params: .none) { result in
                switch result {
                case .success:
                    XCTAssertTrue(true)
                    done()
                default:
                    break
                }
            }
        }
    }
    
    func test_intelligentBankingRestClient_withQueryParams_shouldLoadUrlCorrectly() {
        stub(condition: isHost("test") && isPath("/timeline/events") && containsQueryParams(["param": "value"]), response: { _ in return TestHelpers.stubResponse(with: "empty.json", statusCode: 200) })
        waitUntil { done in
            self.restClient.request(host: "https://test", path: "/timeline/events", method: .get, headers: [:], params: .params(params: ["param": "value"], encoding: .url(destination: .url))) { result in
                switch result {
                case .success:
                    XCTAssertTrue(true)
                    done()
                default:
                    break
                }
            }
        }
    }
    
    func test_intelligentBankingRestClient_withHeaders_shouldLoadRequestCorrectly() {
        stub(condition: isHost("test") && isPath("/timeline/events") && hasHeaderNamed("header", value: "value"), response: { _ in return TestHelpers.stubResponse(with: "empty.json", statusCode: 200) })
        waitUntil { done in
            self.restClient.request(host: "https://test", path: "/timeline/events", method: .get, headers: ["header": "value"], params: .none) { result in
                switch result {
                case .success:
                    XCTAssertTrue(true)
                    done()
                default:
                    break
                }
            }
        }
    }
    
    func test_intelligentBankingRestClient_withBodyParams_shouldLoadRequestCorrectly() {
        stub(condition: isHost("test") && isPath("/timeline/events") && hasJsonBody(["example": "12"]), response: { _ in return TestHelpers.stubResponse(with: "empty.json", statusCode: 200) })
        waitUntil { done in
            self.restClient.request(host: "https://test", path: "/timeline/events", method: .post, headers: [:], params: .params(params: ["example": "12"], encoding: .json)) { result in
                switch result {
                case .success:
                    XCTAssertTrue(true)
                    done()
                default:
                    break
                }
            }
        }
    }
}
