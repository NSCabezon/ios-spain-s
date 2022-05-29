//
//  TestHelpers.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by José Carlos Estela Anguita on 05/07/2019.
//

import Foundation
import OHHTTPStubs
import XCTest
@testable import FinantialTimeline

class UIHelpers<T: UIViewController> {
    
    private var rootWindow: UIWindow!
    
    func setup(withViewController viewController: T) {
        rootWindow = UIWindow(frame: UIScreen.main.bounds)
        rootWindow.isHidden = false
        rootWindow.rootViewController = viewController
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }
    
    func tearDown() {
        guard let rootWindow = rootWindow as? UIWindow,
            let rootViewController = rootWindow.rootViewController as? T else {
                XCTFail("tearDownTopLevelUI() was called without setupTopLevelUI() being called first")
                return
        }
        rootViewController.viewWillDisappear(false)
        rootViewController.viewDidDisappear(false)
        rootWindow.rootViewController = nil
        rootWindow.isHidden = true
        self.rootWindow = nil
    }
}

class TestHelpers {
    
    static func date(from string: String, format: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    static func file(path: String, type: String) throws -> Data {
        let path = Bundle(for: TestHelpers.self).path(forResource: path, ofType: type)!
        return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    }
    
    static func mockResponse(forPath urlPath: String, withFile jsonFile: String, statusCode: Int32 = 200) {
        stub(condition: {
            return $0.url?.path.range(of: urlPath, options: .regularExpression) != nil
        }, response: { _ in
            return TestHelpers.stubResponse(with: jsonFile, statusCode: statusCode)
        })
    }
    
    static func stubResponse(with json: String, statusCode: Int32) -> OHHTTPStubsResponse {
        return OHHTTPStubsResponse(
            fileAtPath: OHPathForFile(json, TestHelpers.self)!,
            statusCode: statusCode,
            headers: ["Content-Type": "application/json"]
        )
    }
    
    static func stubPublicConfiguration() -> Configuration {
        let delegateClass = IntegrationAppController()
        return Configuration.native(
            host: URL(string: "https://test/timeline")!,
            configurationURL: URL(string: "https://test/timeline/configuration")!,
            currencySymbols: [
                "MXN": "$"
            ],
            authorization: .token(""),
            timeLineDelegate: delegateClass,
            actions: [.init(reference: "goToAccounts"),
            .init(reference: "goToCards")]
        )
    }
}

extension XCTestCase {
    
    func wait(for duration: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting")
        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            waitExpectation.fulfill()
        }
        // We use a buffer here to avoid flakiness with Timer on CI
        waitForExpectations(timeout: duration + 0.5)
    }
}
