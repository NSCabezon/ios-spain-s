//
//  Bills_ExampleTests.swift
//  Bills_ExampleTests
//
//  Created by César González Palomino on 19/10/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import UnitTestCommons
import UI
import CoreTestData
import SANLegacyLibrary
@testable import Bills

class BillsExampleTests: XCTestCase {
    
    var mockDataInjector = MockDataInjector()
    var dependenciesResolver: DependenciesDefault!
    var sut: BillAccountSelectorPresenterProtocol!
    var mockView: BillAccountSelectorViewProtocol!

    override func setUp() {
        dependenciesResolver = DependenciesDefault()
        self.mockDataInjector = MockDataInjector(mockDataProvider: MockDataProvider())
        self.defaultRegistration()
        self.registerDependencies()
        mockView = MockView()
        sut = BillAccountSelectorPresenter(dependenciesResolver: dependenciesResolver)
        sut.view = mockView
    }
    
    func registerDependencies() {
        dependenciesResolver.register(for: GetAccountsUseCase.self) { dependenciesResolver in
            return GetAccountsUseCase(dependenciesResolver: dependenciesResolver)
        }
        dependenciesResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        
        self.dependenciesResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return GlobalPositionMock(
                self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
                cardsData: [:],
                temporallyOffCards: [:],
                inactiveCards: [:],
                cardBalances: [:]
            )
        }
        
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        dependenciesResolver.register(for: GlobalPositionRepresentable.self) { dependenciesResolver in
            return globalPosition
            
        }
        
        dependenciesResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            return merger
        }
    }
    
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }

    func testExample() {
        sut.viewDidLoad()
    }
}

final class MockView: BillAccountSelectorViewProtocol {
    var viewModels: [AccountSelectionViewModelProtocol]?
    func setViewModels(_ viewModels: [BillAccountSelectionViewModel]) {
        self.viewModels = viewModels
    }
}
