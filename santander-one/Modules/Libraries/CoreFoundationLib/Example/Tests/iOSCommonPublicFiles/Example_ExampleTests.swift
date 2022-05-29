//
//  Example_ExampleTests.swift
//  Example_ExampleTests
//
//  Created by Jorge Ouahbi Martin on 9/9/21.
//

import XCTest
import CoreFoundationLib
@testable import CoreFoundationLib

class Example_ExampleTests: XCTestCase {

    // MARK: - Clients
    let netClient = NetClientImplementation()
    let assetClient = AssetsClient()
    let fileClient = FileClient()
    var accountDS:AccountDescriptorRepository?
    var segmentsDS:UserSegmentsRepository?
    var segmentsPbDS: UserSegmentsRepositoryPb?
    var servicesForYou: ServicesForYouRepository?

    func testRepositories() throws {
        
        accountDS = AccountDescriptorRepository(netClient: netClient,
                                                assetsClient: assetClient,
                                                fileClient: fileClient)
        
        if let dto = accountDS?.get() {

            XCTAssert(dto.accountGroupEntities.count > 0)
            XCTAssert(dto.accountsArray.count > 0)
            XCTAssert(dto.xmlString.count > 0)
            
        } else {
            XCTFail("AccountDescriptorRepository")
        }
        
        segmentsDS = UserSegmentsRepository(netClient: netClient,
                                            assetsClient: assetClient,
                                            fileClient: fileClient)

        if let dto = segmentsDS?.get() {
            XCTAssert(dto.bdpSegments.count > 0)
        } else {
            XCTFail("UserSegmentsRepository")
        }
        
        segmentsPbDS = UserSegmentsRepositoryPb(netClient: netClient,
                                                assetsClient: assetClient,
                                                fileClient: fileClient)
        
        if let dto = segmentsPbDS?.get() {
            XCTAssert(dto.bdpSegments.count > 0)
        } else {
            XCTFail("UserSegmentsRepositoryPb")
        }
        
        let servicesForYou = ServicesForYouRepository(netClient: netClient,
                                                      assetsClient: assetClient)
        
        if let dto = servicesForYou.get() {
            XCTAssert(dto.categories.count > 0)
        } else {
            XCTFail("ServicesForYouRepository")
        }
    }
}
