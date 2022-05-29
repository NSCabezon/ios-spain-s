//
//  SpainCardTransactionFiltersValidator.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 28/4/22.
//

import Foundation
import UIKit
import Cards
import CoreFoundationLib
import UI
import CoreDomain
import OpenCombine

final class DefaultOldDialogView: OldDialogViewPresentationCapable {
    
    let dependencies: CardTransactionFiltersExternalDependenciesResolver
    
    init(dependencies: CardTransactionFiltersExternalDependenciesResolver) {
        self.dependencies = dependencies
    }

    var associatedOldDialogView: UIViewController {
        return dependencies.resolve().viewController
    }
    var associatedGenericErrorDialogView: UIViewController {
        return dependencies.resolve().viewController
    }
}

protocol SpainCardTransactionFilterValidatorDependenciesResolver {
    func resolve() -> OldDialogViewPresentationCapable
    func resolve() -> TrackerManager
}

final class SpainCardTransactionFilterValidator: CardTransactionFilterValidator {
    
    let dependencies: SpainCardTransactionFilterValidatorDependenciesResolver
    
    init(dependencies: SpainCardTransactionFilterValidatorDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func fetchFiltersPublisher(given filters: [CardTransactionFilterType], card: CardRepresentable) -> AnyPublisher<[CardTransactionFilterType], Never> {
        return Future { promise in
            self.validateFilters(filters, card: card) { modifiedFilters in
                promise(.success(modifiedFilters))
            }
        }.eraseToAnyPublisher()
    }
}

private extension SpainCardTransactionFilterValidator {
    
    func validateFilters(_ filters: [CardTransactionFilterType], card: CardRepresentable, completion: @escaping ([CardTransactionFilterType]) -> Void) {
        guard filters.contains(where: { $0.isByConcept }) && filters.contains(where: { $0.isByDate }) && filters.contains(where: { $0.diffOfDays >= 90 }) else { return completion(filters) }
        showDialog(
            applyOtherFiltersBlock: {
                var newFilters = filters
                newFilters.removeAll(where: { $0.isByConcept })
                completion(newFilters)
            },
            applyByTermFilterBlock: {
                let concept = filters.first(where: { $0.isByConcept })?.conceptValue
                let newFilters = concept.map({ [CardTransactionFilterType.byConcept($0)] })
                self.trackEvent(.apply, parameters: [.cardType: card.trackId, .searchType: concept ?? ""])
                completion(newFilters ?? [])
            }
        )
    }
    
    func showDialog(applyOtherFiltersBlock: @escaping () -> Void, applyByTermFilterBlock: @escaping () -> Void) {
        dependencies.resolve().showOldDialog(
            title: localized("search_alertTitle_filter"),
            description: localized("search_alertText_filter"),
            acceptAction: DialogButtonComponents(titled: localized("search_alertButton_applyFilters"), does: applyOtherFiltersBlock),
            cancelAction: DialogButtonComponents(titled: localized("search_alertButton_searchName"), does: applyByTermFilterBlock),
            isCloseOptionAvailable: true
        )
    }
}

extension SpainCardTransactionFilterValidator: AutomaticScreenActionTrackable {
    
    var trackerManager: TrackerManager {
        return dependencies.resolve()
    }
    
    var trackerPage: CardsSearchPage {
        return CardsSearchPage()
    }
}

private extension CardTransactionFilterType {
    
    var conceptValue: String? {
        guard case .byConcept(let value) = self else { return nil }
        return value
    }
    
    var diffOfDays: Int {
        guard case .byDate(let date) = self else { return 0 }
        return Calendar.current.dateComponents([.day], from: date.startDate, to: date.endDate).day ?? 0
    }
}
