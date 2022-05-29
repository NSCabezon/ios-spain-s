//
//  TestSpainCardTransactionFilterValidator.swift
//  SantanderTests
//
//  Created by José Carlos Estela Anguita on 28/4/22.
//

import Foundation
import XCTest
import Cards
import CoreFoundationLib
import UI
import UIOneComponents
import OpenCombine
import CoreDomain
import CoreTestData
@testable import Santander
import UnitTestCommons

final class TestSpainCardTransactionFilterValidator: XCTestCase {
    
    var trackerManager: TrackerManagerMock!
    var validator: SpainCardTransactionFilterValidator!
    var dependencies: SpainCardTransactionFilterValidatorDependenciesResolver!
    var dialog: OldDialogViewMock!
    
    override func setUp() {
        super.setUp()
        trackerManager = TrackerManagerMock()
        dialog = OldDialogViewMock()
        dependencies = Dependencies(dialog: dialog, trackerManager: trackerManager)
        validator = SpainCardTransactionFilterValidator(dependencies: dependencies)
    }
    
    override func tearDown() {
        super.tearDown()
        dependencies = nil
        validator = nil
    }
    
    func test_filterValidator_whenThereAreFiltersOfConceptAndDate_andDateRangeIsMoreThan90Days_shouldShowTheDialog() throws {
        // W
        _ = validator.fetchFiltersPublisher(given: [.byConcept("hello"), .byDate(CardTransactionFilterDate(startDate: Date(), endDate: Date().dateByAdding(days: 90), indexRange: 0))], card: MockCard())
        let result = try dialog.spyShowDialog.sinkAwait()
        // T
        XCTAssert(result == true)
    }
    
    func test_filterValidator_whenThereAreFiltersOfConceptAndDate_andDateRangeIsLessThan90Days_shouldNotShowTheDialog() throws {
        // W
        _ = validator.fetchFiltersPublisher(given: [.byConcept("hello"), .byDate(CardTransactionFilterDate(startDate: Date(), endDate: Date().dateByAdding(days: 30), indexRange: 0))], card: MockCard())
        let result = try dialog.spyShowDialog.sinkAwait()
        // T
        XCTAssert(result == false)
    }
    
    func test_filterValidator_whenTheDialogHasBeenShown_andTheFilterByTermOptionHasBeenSelected_shouldReturnOnlyTheTermFilter() throws {
        // G
        dialog.result = .cancel
        // W
        let publisher = validator.fetchFiltersPublisher(given: [.byConcept("hello"), .byDate(CardTransactionFilterDate(startDate: Date(), endDate: Date().dateByAdding(days: 90), indexRange: 0))], card: MockCard())
        let filters = try publisher.sinkAwait()
        // T
        XCTAssert(filters.count == 1 && filters.contains(where: { $0.isByConcept }))
    }
    
    func test_filterValidator_whenTheDialogHasBeenShown_andTheOthersFiltersOptionHasBeenSelected_shouldReturnAllFiltersExceptTheTerm() throws {
        // G
        dialog.result = .accept
        // W
        let publisher = validator.fetchFiltersPublisher(given: [.byConcept("hello"), .byDate(CardTransactionFilterDate(startDate: Date(), endDate: Date().dateByAdding(days: 90), indexRange: 0)), .byAmount(.from(10))], card: MockCard())
        let filters = try publisher.sinkAwait()
        // T
        XCTAssert(filters.count == 2 && !filters.contains(where: { $0.isByConcept }))
    }
    
    func test_filterValidator_whenTheDialogHasBeenShown_andTheFilterByTermOptionHasBeenSelected_shouldCallToTrackerManager() throws {
        // G
        dialog.result = .cancel
        var card = MockCard()
        card.trackId = "credito"
        // W
        _ = validator.fetchFiltersPublisher(given: [.byConcept("hello"), .byDate(CardTransactionFilterDate(startDate: Date(), endDate: Date().dateByAdding(days: 90), indexRange: 0))], card: card)
        // T
        
        XCTAssert(trackerManager.screenId == "/card/filter")
        XCTAssert(trackerManager.eventId == "apply_filter")
        XCTAssert(trackerManager.extraParameters?.contains(where: { $0.key == "tipo_busqueda" && $0.value == "hello" }) == true)
        XCTAssert(trackerManager.extraParameters?.contains(where: { $0.key == "tipo_tarjeta" && $0.value == "credito" }) == true)
    }
}

private struct Dependencies: SpainCardTransactionFilterValidatorDependenciesResolver {
    
    let dialog: OldDialogViewMock
    let trackerManager: TrackerManagerMock
    
    func resolve() -> OldDialogViewPresentationCapable {
        return dialog
    }
    
    func resolve() -> TrackerManager {
        return trackerManager
    }
    
}

class OldDialogViewMock: UIViewController, OldDialogViewPresentationCapable {
    
    enum DialogResult {
        case accept
        case cancel
    }
    
    var result: DialogResult = .accept
    var spyShowDialog = CurrentValueSubject<Bool, Never>(false)
    
    func showOldDialog(title: LocalizedStylableText?, description: LocalizedStylableText, acceptAction: DialogButtonComponents, cancelAction: DialogButtonComponents?, isCloseOptionAvailable: Bool) {
        spyShowDialog.send(true)
        switch result {
        case .accept:
            acceptAction.action?()
        case .cancel:
            cancelAction?.action?()
        }
    }
}
