//
//  TestCardTransactionDetailViewModel.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import Foundation
import XCTest
import UnitTestCommons
import CoreFoundationLib
import CoreTestData
import CoreDomain
import SANLegacyLibrary
@testable import Cards

class TestCardTransactionDetailViewModel: XCTestCase {
    private let card = MockCard()
    private let transaction = MockCardTransaction()
    private lazy var configuration: CardTransactionDetailConfiguration = {
        let cardEntity = CardEntity(card)
        let cardTransactionEntity = CardTransactionEntity(CardTransactionDTO())
        return CardTransactionDetailConfiguration(selectedCard: cardEntity,
                                           selectedTransaction: cardTransactionEntity,
                                           allTransactions: [cardTransactionEntity])
    }()
    private lazy var item: CardTransactionViewItemRepresentable = {
        MockCardTransactionViewItem(card: card,
                                    transaction: transaction,
                                    showAmountBackground: true)
    }()
    private lazy var sut: CardTransactionDetailViewModel = {
        CardTransactionDetailViewModel(dependencies: dependencies)
    }()
    private lazy var dependencies: TestCardTransactionDetailDependencies = {
        let external = TestCardTransactionExternalDependencies(injector: self.mockDataInjector)
        return TestCardTransactionDetailDependencies(injector: self.mockDataInjector,
                                               externalDependencies: external)
    }()
    private lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.injectMockCardData()
        return injector
    }()
}

extension TestCardTransactionDetailViewModel {
    func test_open_menu() throws {
        sut.viewDidLoad()
        sut.dataBinding.set(configuration)
        sut.viewDidLoad()
        sut.didSelectOpenMenu()
        XCTAssertTrue(self.dependencies.mockCoordinator.openMenuCalled)
    }
    
    func test_easyPay() throws {
        sut.viewDidLoad()
        sut.dataBinding.set(configuration)
        sut.viewDidLoad()
        sut.didSelectFractionate()
        XCTAssertTrue(self.dependencies.mockCoordinator.easyPayCalled)
    }
    
    func test_monthlyFee() throws {
        sut.viewDidLoad()
        sut.dataBinding.set(configuration)
        sut.viewDidLoad()
        sut.didSelectMonthlyFee(nil)
        XCTAssertTrue(self.dependencies.mockCoordinator.easyPayCalled)
    }
    
    func test_mapView() throws {
        sut.viewDidLoad()
        sut.dataBinding.set(configuration)
        sut.viewDidLoad()
        sut.didSelectMap()
        XCTAssertFalse(self.dependencies.mockCoordinator.mapViewCalled)
    }
    
    func test_offer() throws {
        sut.viewDidLoad()
        sut.dataBinding.set(configuration)
        sut.viewDidLoad()
        sut.didSelectOffer(item: item)
        XCTAssertFalse(self.dependencies.mockCoordinator.openMenuCalled)
    }
}
