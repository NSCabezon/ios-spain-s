//
//  TestSpainCardDetailConfiguration.swift
//  Santander
//
//  Created by Gloria Cano López on 10/3/22.
//

import CoreTestData
import XCTest
import UnitTestCommons
import Cards
@testable import Santander

class TestGetSpainCardDetailConfigurationUseCase: XCTestCase {
    lazy var dependencies: TestCardDetailDependencies = {
        let external = TestCardDetailExternalDependencies(injector: self.mockDataInjector)
        return TestCardDetailDependencies(injector: self.mockDataInjector,
                                          externalDependencies: external)
    }()
    var cardConfiguration: CardDetailConfiguration?
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        return injector
    }()
    
    func test_When_FetchConfiguration_Expect_ShowCardPANIsEnabled() throws {
        let sut = SpainGetCardDetailConfigurationUseCase()
        
        _ = sut.fetchCardDetailConfiguration(card: MockCard(), cardDetail: MockCardDetail()).sink(receiveValue: { [unowned self] detail in
            cardConfiguration = detail
            
        })
        XCTAssert(cardConfiguration?.isShowCardPAN == false)
        XCTAssert(cardConfiguration?.isCardPANMasked == false)
        
    }
    
    func test_When_FetchConfiguration_Expect_HolderIsEnabled() throws {
        let sut = SpainGetCardDetailConfigurationUseCase()
        
        _ = sut.fetchCardDetailConfiguration(card: MockCard(), cardDetail: MockCardDetail()).sink(receiveValue: { [unowned self] detail in
            cardConfiguration = detail
            
        })
        XCTAssert(cardConfiguration?.isCardHolderEnabled == true)
    }
    
    func test_When_FetchConfiguration_Expect_CardDetailElements() throws {
        let sut = SpainGetCardDetailConfigurationUseCase()
        
        _ = sut.fetchCardDetailConfiguration(card: MockCard(), cardDetail: MockCardDetail()).sink(receiveValue: { [unowned self] detail in
            cardConfiguration = detail
            
        })
        XCTAssert(cardConfiguration?.creditCardHeaderElements == [.limitCredit, .availableCredit, .withdrawnCredit])
        XCTAssert(cardConfiguration?.debitCardHeaderElements == [.spentThisMonth, .tradeLimit, .atmLimit])
        XCTAssert(cardConfiguration?.prepaidCardHeaderElements == [.availableBalance, .spentThisMonth])
        XCTAssert(cardConfiguration?.cardDetailElements == [.pan, .alias, .holder, .beneficiary, .linkedAccount, .situation, .expirationDate, .type])
    }
    
}
