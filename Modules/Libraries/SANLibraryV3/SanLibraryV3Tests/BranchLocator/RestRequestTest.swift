//

import XCTest
@testable import SanLibraryV3

class RestRequestTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_RestRequest_getHttpBody() {
        let dictionaryParams = ["name": "Juana", "class": "math"]
        let testRequestDictionary = RestRequest.getHttpBody(params: dictionaryParams, removesEscapeCharacters: false, contentType: .json)
        guard let encodedDictionaryData = testRequestDictionary else {
            return
        }
        XCTAssertEqual(encodedDictionaryData.bytes.count, 42)
    }
    
    func test_RestRequest_getQueryString() {
        let dictionaryParams = ["name": "Juana", "class": "math"]
        guard let queryString = RestRequest.getQueryString(params: dictionaryParams) else {
            return
        }
        XCTAssert(queryString.description.contains("name=Juana"))
        XCTAssert(queryString.description.contains("class=math"))
        XCTAssert(queryString.description.last != "&")
    }
    
    func test_RestRequest_bodyData() {
        let input = BranchLocatorATMParameters(lat: 40.425168, lon: -3.68463, customer: false, country: .es)
        let testRequestCodable = RestRequest.bodyData(for: input)
        guard let encodedData = testRequestCodable else {
            return
        }
        XCTAssertEqual(encodedData.bytes.count, 84)
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(BranchLocatorATMParameters.self, from: encodedData)
            XCTAssertEqual(decodedData.lat, 40.425168)
            XCTAssertEqual(decodedData.lon, -3.68463)
            XCTAssertEqual(decodedData.country, "ES")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_asQueryString_extension() {
        let dictionaryParams = ["name": "Juana", "class": "math"]
        var queryString = dictionaryParams.asQueryString()
        XCTAssertNotNil(queryString)
        XCTAssertEqual(queryString.count, 21)
        let emptyDictionaryParams = [String: Any]()
        queryString = emptyDictionaryParams.asQueryString()
        XCTAssertNotNil(queryString)
    }
}
