//
//  DateTests.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 05/07/2019.
//

import XCTest
import Nimble
@testable import FinantialTimeline

private struct DateParseMock: DateParseable, Decodable {
    let date: Date
    let mock: MockObject
    
    static var formats: [String : String] {
        return [
            "date": "yyyy-MM-dd'T'HH:mm:ssZ",
            "mock.mocks.date": "yyyy-MM-dd"
        ]
    }
}

private struct MockObject: Decodable {
    let mocks: [SubMockObject]
}

private struct SubMockObject: Decodable {
    let date: Date
}

class DateParseableTests: XCTestCase {
    
    func test_dateParseable_shouldParseCorrectyAModelWithHierarchy() {
        do {
            let data = try TestHelpers.file(path: "date_parsing", type: "json")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(DateParseMock.decode)
            let decoded = try decoder.decode(DateParseMock.self, from: data)
            expect(decoded.date) == TestHelpers.date(from: "2019-03-15T05:00:00-06:00", format: "yyyy-MM-dd'T'HH:mm:ssZ")
            expect(decoded.mock.mocks.first?.date) == TestHelpers.date(from: "2019-02-10", format: "yyyy-MM-dd")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
