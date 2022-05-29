//
//  ContactsUseCaseTests.swift
//  Transfer_ExampleTests
//
//  Created by Francisco del Real Escudero on 4/1/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import CoreFoundationLib
import UnitTestCommons
import CoreTestData
import OpenCombine
import CoreDomain
import QuickSetup
import XCTest
@testable import Transfer

class MockGetReactiveContactsUseCaseDependenciesResolver: GetReactiveContactsUseCaseDependenciesResolver {
    private let mockDataInjector: MockDataInjector
    private let appRepositoryProtocol: AppRepositoryProtocol
    private let globalPositionRepository: GlobalPositionDataRepository
    
    init(mockDataInjector: MockDataInjector, appRepositoryProtocol: AppRepositoryProtocol) {
        self.mockDataInjector = mockDataInjector
        self.appRepositoryProtocol = appRepositoryProtocol
        self.globalPositionRepository = DefaultGlobalPositionDataRepository()
    }
    
    func resolve() -> AppRepositoryProtocol {
        return appRepositoryProtocol
    }
    
    func resolve() -> GlobalPositionRepresentable {
        return GlobalPositionMock(
            mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
            cardsData: [:],
            temporallyOffCards: [:],
            inactiveCards: [:],
            cardBalances: [:]
        )
    }
    
    func resolve() -> TransfersRepository {
        return MockTransfersRepository(mockDataInjector: mockDataInjector)
    }
    
    func resolve() -> GetReactiveContactsUseCase {
        return DefaultGetReactiveContactsUseCase(dependencies: self)
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository
    }
}

class ContactsUseCaseTests: XCTestCase {
    private var mockDataInjector: MockDataInjector!
    private var appRepository: AppRepositoryMock!
    private var dependenciesResolver: GetReactiveContactsUseCaseDependenciesResolver!
    private var globalPositionRepository: GlobalPositionDataRepository {
        return dependenciesResolver.resolve()
    }
    
    override func setUp() {
        super.setUp()
        self.mockDataInjector = MockDataInjector()
        self.appRepository = AppRepositoryMock()
        self.dependenciesResolver = MockGetReactiveContactsUseCaseDependenciesResolver(
            mockDataInjector: mockDataInjector,
            appRepositoryProtocol: appRepository
        )
        defaultRegistration()
    }
    
    func testFetchContactsWithResponseAndNoUserPref() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOMock"
        )
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
    }
    
    func testFetchContactsWithEmptyResponseAndNoUserPref() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "emptyArrayResponse"
        )
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(list.isEmpty)
    }
    
    func testFetchContactsWithResponseAndFavoritesInUserPref() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOMock"
        )
        let globalPosition = try globalPositionRepository.getGlobalPosition().sinkAwait()
        let userPref = appRepository.getUserPreferences(userId: globalPosition.userId!)
        let favorites = ["Luis test2", "Luis test", "Luis test3"]
        userPref.pgUserPrefDTO.favoriteContacts = favorites
        appRepository.setUserPreferences(userPref: userPref)
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
    }
    
    func testFetchContactsWithResponseAndFavoritesInUserPrefDifferentFromResponse() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOMock"
        )
        let globalPosition = try globalPositionRepository.getGlobalPosition().sinkAwait()
        let userPref = appRepository.getUserPreferences(userId: globalPosition.userId!)
        let favorites = ["AirPods", "HomePod", "TV", "Watch"]
        userPref.pgUserPrefDTO.favoriteContacts = favorites
        appRepository.setUserPreferences(userPref: userPref)
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
    }
    
    func testFetchContactsWithResponseAndFavoritesInUserPrefShouldBeOrdered() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOMock"
        )
        let globalPosition = try globalPositionRepository.getGlobalPosition().sinkAwait()
        let userPref = appRepository.getUserPreferences(userId: globalPosition.userId!)
        let favorites = ["Luis test2", "Luis test", "Luis test3"]
        userPref.pgUserPrefDTO.favoriteContacts = favorites
        appRepository.setUserPreferences(userPref: userPref)
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(list.compactMap({ $0.payeeAlias }).elementsEqual(favorites, by: ==))
    }
    
    func testFetchContactsWithResponseWithoutUserId() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOMock"
        )
        mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobalWithoutUserId"
        )
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
    }
    
    func testFetchContactsWithNoSepaResponseAndNoUserPref() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOWithNoSepaMock"
        )
        mockDataInjector.register(
            for: \.transferData.noSepaPayeeDetail,
               filename: "NoSepaPayeeDetailDTOMock"
        )
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
        let noSepaContacts = list.filter { $0.isNoSepa }
        XCTAssert(noSepaContacts.count == 1)
        XCTAssert(noSepaContacts.first!.countryCode == "ES")
    }
    
    func testFetchContactsWithNoSepaResponseWithNoCountryCodeAndNoUserPref() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOWithNoSepaMock"
        )
        mockDataInjector.register(
            for: \.transferData.noSepaPayeeDetail,
               filename: "NoSepaPayeeDetailDTOWithNoCountryCodeMock"
        )
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
        let noSepaContacts = list.filter { $0.isNoSepa }
        XCTAssert(noSepaContacts.count == 1)
        XCTAssert(noSepaContacts.first!.countryCode == "723")
    }
    
    func testFetchContactsWithNoSepaResponseWithNoPayeeAliasAndNoUserPref() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTONoSepaWithNoAliasMock"
        )
        mockDataInjector.register(
            for: \.transferData.noSepaPayeeDetail,
               filename: "emptyResponse"
        )
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
        let noSepaContacts = list.filter { $0.isNoSepa }
        XCTAssert(noSepaContacts.isEmpty)
    }
    
    func testFetchContactsWithNoSepaResponseWithNoRecipientTypeAndNoUserPref() throws {
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTONoSepaWithNoRecipientTypeMock"
        )
        mockDataInjector.register(
            for: \.transferData.noSepaPayeeDetail,
               filename: "emptyResponse"
        )
        let useCase: GetReactiveContactsUseCase = dependenciesResolver.resolve()
        
        let list = try useCase.fetchContacts()
            .sinkAwait()
        
        XCTAssert(
            list.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
        let noSepaContacts = list.filter { $0.isNoSepa }
        XCTAssert(noSepaContacts.isEmpty)
    }
    
    func defaultRegistration() {
        mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
        globalPositionRepository.send(mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock)
    }
}
