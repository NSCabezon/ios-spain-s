//
//  TimeLineConfigurationTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 16/09/2019.
//

import XCTest
@testable import FinantialTimeline

class TimeLineConfigurationTests: XCTestCase {
    
    override func setUp() {
        
    }

    override func tearDown() {
        
    }
    
    func testDecodeTimeLineConfiguration() {
        
        // G
        let decoder = JSONDecoder()
        var timeLineConfiguration: TimeLineConfiguration?
        
        // W
        do {
            timeLineConfiguration = try decoder.decode(TimeLineConfiguration.self, from: TestHelpers.file(path: "configuration", type: "json"))
        } catch {
            XCTFail()
        }
        
        // T        
        XCTAssertNotNil(timeLineConfiguration?.textProductCodes)
    }

}
