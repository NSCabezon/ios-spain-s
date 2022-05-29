//
//  ControlTest.swift
//  OpenKitTests
//
//  Created by Juan Carlos López Robles on 3/21/22.
//

import XCTest
import OpenCombine
import UI
import UIKit

class UIControlTest: XCTestCase {

    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Given_maxPageCount_When_pageChange_Then_add_pageNumberToValue() throws {
        let maxPageCount = 10
        var values = [Int]()
        let pageControl = UIPageControl()
        pageControl.numberOfPages = maxPageCount
        pageControl
            .currentPagePublisher
            .sink { newValue in
                values.append(newValue)
            }.store(in: &subscriptions)
        
        for page in 1..<maxPageCount {
            pageControl.currentPage = page
        }
        XCTAssertEqual(values, Array(0..<maxPageCount))
    }
}
