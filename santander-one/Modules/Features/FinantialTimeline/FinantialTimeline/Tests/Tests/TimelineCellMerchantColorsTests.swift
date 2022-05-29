//
//  TimelineCellMerchantColorsTests.swift
//  FinantialTimeline-Unit-TimeLineTests
//
//  Created by Jose Ignacio de Juan Díaz on 24/09/2019.
//

import XCTest
@testable import FinantialTimeline

class TimelineCellMerchantColorsTests: XCTestCase {
    
    var merchantColors: TimelineCellMerchantColors!

    override func setUp() {
        merchantColors = TimelineCellMerchantColors.shared
    }

    override func tearDown() {
        merchantColors = nil
    }
    
    func testAssignColorToMerchant() {
        // G
        let netflixMerchant = "Netflix"
        let telefonicaMerchant = "Telefónica"
        let iberdrolaMerchant = "Iberdrola"
        let canalMerchant = "Canal Isabel II"
        let gymMerchant = "Gym"
        let netflixDuplicatedMerchant = "Netflix"
        let gymDuplicatedMerchant = "Gym"
        let merchants = [netflixMerchant, telefonicaMerchant, iberdrolaMerchant, canalMerchant, gymMerchant, netflixDuplicatedMerchant, gymDuplicatedMerchant]
        merchantColors.colorIndex = 0
        
        // W
        merchants.forEach {_ = merchantColors.assignColorTo(merchant: $0)}
         
        // T
        XCTAssertEqual(merchantColors.merchantsSet.count, 5)
        
    }
    
    func testgetColorFromMerchant() {
        // G
        let netflixMerchant = "Netflix"
        let telefonicaMerchant = "Telefónica"
        let iberdrolaMerchant = "Iberdrola"
        let canalMerchant = "Canal Isabel II"
        let gymMerchant = "Gym"
        
        // W // T
        
        let _ = merchantColors.getColorFrom(merchant: netflixMerchant)
        let _ = merchantColors.getColorFrom(merchant: telefonicaMerchant)
        let _ = merchantColors.getColorFrom(merchant: iberdrolaMerchant)
        let _ = merchantColors.getColorFrom(merchant: canalMerchant)
        let _ = merchantColors.getColorFrom(merchant: gymMerchant)
    }
}
