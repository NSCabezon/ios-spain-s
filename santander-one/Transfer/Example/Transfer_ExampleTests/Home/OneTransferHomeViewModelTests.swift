//
//  OneTransferHomeViewModelTests.swift
//  Transfer_ExampleTests
//
//  Created by Francisco del Real Escudero on 10/1/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import UnitTestCommons
import CoreTestData
import QuickSetup
@testable import Transfer

class OneTransferHomeViewModelTests: XCTestCase {
    private var mockDataInjector: MockDataInjector!
    private var externalDependencies: OneTransferHomeExternalDependenciesResolverMock!
    private var dependencies: OneTransferHomeDependenciesResolverMock!
    private var oldDependencies: (DependenciesInjector & DependenciesResolver)!
    private var trackManager: TrackerManagerMock!
    private var coordinator: OneTransferHomeCoordinatorMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        trackManager = TrackerManagerMock()
        mockDataInjector = MockDataInjector()
        oldDependencies = DependenciesDefault()
        externalDependencies = OneTransferHomeExternalDependenciesResolverMock(
            oldDependencies: oldDependencies,
            mockDataInjector: mockDataInjector
        )
        dependencies = OneTransferHomeDependenciesResolverMock(
            external: externalDependencies
        )
        coordinator = OneTransferHomeCoordinatorMock(dependencies: dependencies)
        dependencies.coordinator = coordinator
        defaultRegistration()
    }
    
    func test_WhenViewDidLoad_AndThereAreFavorites_ThenFavoritesAreLoaded() throws {
        externalDependencies.contactsUseCase = GetReactiveContactsUseCaseMock(
            sucess: mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers
        )
        
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        sut.subscribeFavorites()
        
        let publisher = sut.state
            .case { OneTransferHomeState.receivedPayee }
        let result = try publisher.sinkAwait()
        
        XCTAssert(
            result.allSatisfy { payee in
                mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers.contains(where: { payee.equalsTo(other: $0) })
            }
        )
    }
    
    func test_WhenViewDidLoad_AndThereAreNoFavorites_ThenNoFavoritesAreLoaded() throws {
        externalDependencies.contactsUseCase = GetReactiveContactsUseCaseMock(
            sucess: []
        )
        
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        sut.subscribeFavorites()
        
        let publisher = sut.state
            .case { OneTransferHomeState.receivedPayee }
        let result = try publisher.sinkAwait()
        
        XCTAssert(result.isEmpty)
    }
    
    func test_WhenViewDidLoad_AndThereIsAnErrorWithFavorites_ThenNoFavoritesAreLoaded() throws {
        externalDependencies.contactsUseCase = GetReactiveContactsUseCaseMock(
            error: ErrorMock()
        )
        
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        sut.subscribeFavorites()
        
        let publisher = sut.state
            .case { OneTransferHomeState.receivedPayee }
        let result = try publisher.sinkAwait()
        
        XCTAssert(result.isEmpty)
    }
    
    func test_WhenViewDidLoad_AndThereAreNoActions_ThenNoActionsAreLoaded() throws {
        externalDependencies.actionsUseCase = GetSendMoneyActionsUseCaseMock(
            sucess: []
        )
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        sut.subscribeSendMoneyActions()
        
        let publisher = sut.state
            .case { OneTransferHomeState.sendMoneyActionsLoaded }
        let result = try publisher.sinkAwait()
        
        XCTAssert(result.isEmpty)
    }
    
    func test_WhenViewDidLoad_AndThereAreActions_ThenActionsAreLoaded() throws {
        externalDependencies.actionsUseCase = GetSendMoneyActionsUseCaseMock(
            sucess: [.transfer, .transferBetweenAccounts, .scheduleTransfers]
        )
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        sut.subscribeSendMoneyActions()
        
        let publisher = sut.state
            .case { OneTransferHomeState.sendMoneyActionsLoaded }
        let result = try publisher.sinkAwait()
        
        XCTAssertFalse(result.isEmpty)
    }
    
    func test_WhenSelectedTransfer_ThenCoordinatorLaunchesTransfers_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.transfer)
        
        XCTAssert(coordinator.didGoToTransfer)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.transfer.rawValue)" }))
    }
    
    func test_WhenSelectedSwitches_ThenCoordinatorLaunchesSwitches_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.transferBetweenAccounts)
        
        XCTAssert(coordinator.didGoToSwitches)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.switches.rawValue)" }))
    }
    
    func test_WhenSelectedOnePayFX_AndThereIsNoOffer_ThenCoordinatorLaunchesOnePayFX() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.onePayFX(nil))
        
        XCTAssert(coordinator.executedOfferId == "no_offer")
    }
    
    func test_WhenSelectedOnePayFX_AndThereIsOffer_ThenCoordinatorLaunchesOnePayFX() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.onePayFX(OfferEntity(
            OfferDTO(
                product: OfferProductDTO(
                    identifier: "one_pay_offer",
                    neverExpires: false,
                    transparentClosure: nil,
                    description: nil,
                    rulesIds: [],
                    iterations: 0,
                    banners: [],
                    bannersContract: [],
                    action: nil,
                    startDateUTC: nil,
                    endDateUTC: nil
                )
            )
        )))
        
        XCTAssert(coordinator.executedOfferId == "one_pay_offer")
    }
    
    func test_WhenSelectedATM_ThenCoordinatorLaunchesATM() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.atm)
        
        XCTAssert(coordinator.didGoToATM)
    }
    
    func test_WhenSelectedCorreosCash_AndThereIsNoOffer_ThenCoordinatorReceivesNoOffer() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.correosCash(nil))
        
        XCTAssert(coordinator.executedOfferId == "no_offer")
    }
    
    func test_WhenSelectedCorreosCash_AndThereIsOffer_ThenCoordinatorLaunchesCorreosCash() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.correosCash(OfferEntity(
            OfferDTO(
                product: OfferProductDTO(
                    identifier: "correos_cash_offer",
                    neverExpires: false,
                    transparentClosure: nil,
                    description: nil,
                    rulesIds: [],
                    iterations: 0,
                    banners: [],
                    bannersContract: [],
                    action: nil,
                    startDateUTC: nil,
                    endDateUTC: nil
                )
            )
        )))
        
        XCTAssert(coordinator.executedOfferId == "correos_cash_offer")
    }
    
    func test_WhenSelectedScheduleTransfers_ThenCoordinatorLaunchesScheduleTransfers_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.scheduleTransfers)
        
        XCTAssert(coordinator.didGoToScheduleTransfers)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.scheduled.rawValue)" }))
    }
    
    func test_WhenSelectedDonations_AndThereIsNoOffer_ThenCoordinatorReceivesNoOffer() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.donations(nil))
        
        XCTAssert(coordinator.executedOfferId == "no_offer")
    }
    
    func test_WhenSelectedDonations_AndThereIsOffer_ThenCoordinatorLaunchesDonations() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.donations(OfferEntity(
            OfferDTO(
                product: OfferProductDTO(
                    identifier: "donations_offer",
                    neverExpires: false,
                    transparentClosure: nil,
                    description: nil,
                    rulesIds: [],
                    iterations: 0,
                    banners: [],
                    bannersContract: [],
                    action: nil,
                    startDateUTC: nil,
                    endDateUTC: nil
                )
            )
        )))
        
        XCTAssert(coordinator.executedOfferId == "donations_offer")
    }
    
    func test_WhenSelectedCustome_ThenCoordinatorLaunchesCustome() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.custome(identifier: "", title: "", description: "", icon: ""))
        
        XCTAssert(coordinator.didGoToCustome)
    }
    
    func test_WhenSelectedReuse_ThenCoordinatorLaunchesReuse() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.didSelectSendMoneyAction(.reuse(IBANRepresented(ibanString: ""), ""))
        
        XCTAssert(coordinator.didGoToReuse)
    }
    
    func test_WhenExecutedShowAllFavorites_ThenCoordinatorLaunchesContactList_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showAllFavorites()
        
        XCTAssert(coordinator.didGoToContactList)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.seeFavorites.rawValue)" }))
    }
    
    func test_WhenExecutedShowHistorical_ThenCoordinatorLaunchesHistorical_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showHistorical()
        
        XCTAssert(coordinator.didGoToHistorical)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.history.rawValue)" }))
    }
    
    func test_WhenExecutedShowPastTransfer_AndTransferIsEmitted_ThenCoordinatorLaunchesTransferDetail_AndMetricIsSent() throws {
        mockDataInjector.register(
            for: \.transferData.loadEmittedTransfers,
               filename: "TransferEmittedListDTOMock"
        )
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        let emittedTransfer = try XCTUnwrap(mockDataInjector.mockDataProvider.transferData.loadEmittedTransfers.transactionDTOs.first)
        sut.showPastTransfer(emittedTransfer)
        
        XCTAssert(coordinator.didGoToPastTransfer)
        XCTAssert(coordinator.isPastTransferEmitted)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.emmited.rawValue)" }))
    }
    
    func test_WhenExecutedShowPastTransfer_AndTransferIsReceived_ThenCoordinatorLaunchesTransferDetail_AndMetricIsSent() throws {
        mockDataInjector.register(
            for: \.transferData.getAccountTransactions,
               filename: "AccountTransactionsListDTOMock"
        )
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        let receivedTransfer = try XCTUnwrap(mockDataInjector.mockDataProvider.transferData.getAccountTransactions.transactionDTOs.first)
        sut.showPastTransfer(receivedTransfer)
        
        XCTAssert(coordinator.didGoToPastTransfer)
        XCTAssert(coordinator.isPastTransferReceived)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.received.rawValue)" }))
    }
    
    func test_WhenExecutedShowTooltip_ThenCoordinatorLaunchesTooltip_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showTooltip()
        
        XCTAssert(coordinator.didGoToTooltip)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.tooltip.rawValue)" }))
    }
    
    func test_WhenExecutedShowNewTransfer_ThenCoordinatorLaunchesNewTransfer_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showNewTransfer()
        
        XCTAssert(coordinator.didGoToTransfer)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.newSend.rawValue)" }))
    }
    
    func test_WhenExecutedShowNewContact_ThenCoordinatorLaunchesNewContact_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showNewContact()
        
        XCTAssert(coordinator.didGoToNewContact)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.newContact.rawValue)" }))
    }
    
    func test_WhenExecutedShowContactDetail_AndContactIsInList_ThenCoordinatorLaunchesContactDetail_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        sut.subscribeFavorites()
        _ = try sut.state
            .case { OneTransferHomeState.receivedPayee }
            .sinkAwait()
        let favoriteAlias = "Luis test2"
        
        sut.showContactDetail(favoriteAlias)
        
        XCTAssert(coordinator.didGoToContactDetail)
        XCTAssert(coordinator.lastFavoriteId == favoriteAlias)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.favouriteDetail.rawValue)" }))
    }
    
    func test_WhenExecutedShowContactDetail_AndContactIsNotInList_ThenNothingHappens() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        sut.subscribeFavorites()
        let favoriteAlias = "Monforte de Lemos"
        
        sut.showContactDetail(favoriteAlias)
        
        XCTAssertFalse(coordinator.didGoToContactDetail)
        XCTAssert(coordinator.lastFavoriteId == nil)
        XCTAssertFalse(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.favouriteDetail.rawValue)" }))
    }
    
    func test_WhenExecutedShowContactDetail_AndThereAreNoContactsLoaded_ThenNothingHappens() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        let favoriteAlias = "Luis test2"
        
        sut.showContactDetail(favoriteAlias)
        
        XCTAssertFalse(coordinator.didGoToContactDetail)
        XCTAssert(coordinator.lastFavoriteId == nil)
        XCTAssertFalse(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.favouriteDetail.rawValue)" }))
    }
    
    func test_WhenExecutedShowTip_AndThereIsNoOffer_ThenCoordinatorReceivesNoOffer() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showTip(nil)
        
        XCTAssert(coordinator.executedOfferId == "no_offer")
    }
    
    func test_WhenExecutedShowTip_AndThereIsOffer_ThenCoordinatorLaunchesTip() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showTip(
            OfferEntity(
                OfferDTO(
                    product: OfferProductDTO(
                        identifier: "tips_offer",
                        neverExpires: false,
                        transparentClosure: nil,
                        description: nil,
                        rulesIds: [],
                        iterations: 0,
                        banners: [],
                        bannersContract: [],
                        action: nil,
                        startDateUTC: nil,
                        endDateUTC: nil
                    )
                )
            )
        )
        
        XCTAssert(coordinator.executedOfferId == "tips_offer")
    }
    
    func test_WhenExecutedShowVirtualAssistant_ThenCoordinatorLaunchesVirtualAssistant_AndMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.showVirtualAssistant()
        
        XCTAssert(coordinator.didGoToVirtualAssistant)
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.virtualAssistant.rawValue)" }))
    }
    
    func test_WhenExecutedRecentAndScheduledSwipe_ThenMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.recentAndScheduledSwipe()
        
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.swipeRecentAndScheduled.rawValue)" }))
    }
    
    func test_WhenExecutedFavoritesSwipe_ThenMetricIsSent() throws {
        let sut: OneTransferHomeViewModel = dependencies.resolve()
        
        sut.favoritesSwipe()
        
        XCTAssert(trackManager.trackedEvents.contains(where: { $0.0 == "\(OneTransferPage().page)\(OneTransferPage.Action.swipeFavorites.rawValue)" }))
    }
    
    func defaultRegistration() {
        oldDependencies.register(for: TrackerManager.self) { _ in
            return self.trackManager
        }
        oldDependencies.register(for: EmmaTrackEventListProtocol.self) { _ in
            return EmmaTrackEventListMock()
        }
        mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
        mockDataInjector.register(
            for: \.transferData.loadAllUsualTransfers,
               filename: "TransfersDTOMock"
        )
        mockDataInjector.register(
            for: \.transferData.loadEmittedTransfers,
               filename: "TransferEmittedListDTOMock"
        )
        mockDataInjector.register(
            for: \.transferData.getAccountTransactions,
               filename: "AccountTransactionsListDTOMock"
        )
        externalDependencies.contactsUseCase = GetReactiveContactsUseCaseMock(
            sucess: mockDataInjector.mockDataProvider.transferData.loadAllUsualTransfers
        )
        externalDependencies.actionsUseCase = GetSendMoneyActionsUseCaseMock(
            sucess: [.transfer, .transferBetweenAccounts, .scheduleTransfers]
        )
        externalDependencies.emittedTransfersUseCase = GetAllTransfersReactiveUseCaseMock(mockDataInjector: mockDataInjector)
    }
}
