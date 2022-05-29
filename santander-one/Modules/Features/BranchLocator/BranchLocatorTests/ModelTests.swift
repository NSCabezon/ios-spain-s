//
//  ModelTests.swift
//  BranchLocatorTests
//
//  Created by vectoradmin on 13/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest

@testable import BranchLocator

class ModelTests: XCTestCase {
    

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFullAddress() {
        guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
        XCTAssert(poi.location!.fullAddress == poi.location!.address! + ", " + poi.location!.city!)
        
        var addrPoi = poi
        addrPoi.location?.address = nil
        XCTAssert(addrPoi.location!.fullAddress == poi.location!.city!)
        
        addrPoi = poi
        addrPoi.location?.city = nil
        XCTAssert(addrPoi.location!.fullAddress == poi.location!.address)

        addrPoi.location?.address = nil
        XCTAssert(addrPoi.location?.fullAddress == "")
    }
    
    func testGetFirstPhoneRelatedPOI() {
        guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
        guard let cd = ContactData(JSONString: kContactData) else { return }
        
        XCTAssert(poi.getFirstPhoneFromRelatedPoi() == nil)
        
        var cdPOI = poi
        cdPOI.contactData = cd
        cdPOI.relatedPOIs.append(cdPOI)
        XCTAssert(cdPOI.getFirstPhoneFromRelatedPoi() == "123456789" )
        
    }
    
    func testSchedule() {
        guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
        
        var poi2 = poi
        poi2.objectType.code = .atm
        XCTAssert(poi.hasSchedule() == true)
        
        poi2.objectType.code = .branch
        XCTAssert(poi.hasSchedule() == true)
        poi2.schedule?.monday.removeAll()
        poi2.schedule?.tuesday.removeAll()
        poi2.schedule?.wednesday.removeAll()
        poi2.schedule?.thursday.removeAll()
        poi2.schedule?.friday.removeAll()
        poi2.schedule?.saturday.removeAll()
        poi2.schedule?.sunday.removeAll()
        XCTAssert(poi2.hasSchedule() == false)
    }
	/*
	func testFilterTypeTitle() {
		let allFilterTitles = FilterType.all.map({ $0.title })
		XCTAssertEqual(allFilterTitles.count, FilterType.all.count)
		XCTAssertEqual(allFilterTitles.count, FilterType.all.count)
	}
*/
    func testFinancialService() {
        guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
        XCTAssertTrue(poi.hasFinancialServices())
    }
	
    func testNoFinancialServices() {
        guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
        XCTAssertTrue(poi.hasNoFinancialServices())
    }
    
     func testPOIStatus() {
        let status = POIStatus(rawValue: "active")
        XCTAssert(status == .active)
        
        let status2 = POIStatus(rawValue: "ACTIVE")
        XCTAssert(status2 == .active)
        
        let other = POIStatus(rawValue: "patata")
        XCTAssert(other == .unknown)
        
        let otr = POIStatus(rawValue: "PATATA")
        XCTAssert(otr == .unknown)
    }
}
