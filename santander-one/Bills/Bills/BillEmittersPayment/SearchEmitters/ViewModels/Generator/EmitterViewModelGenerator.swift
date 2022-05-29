//
//  EmitterViewModelGenerator.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import Foundation
import CoreFoundationLib

final class EmitterViewModelGenerator {
    private let baseUrl: String?
    
    init(dependenciesResolver: DependenciesResolver) {
        let urlProvider = dependenciesResolver.resolve(for: BaseURLProvider.self)
        self.baseUrl = urlProvider.baseURL
    }
    
    func emitterViewModels(_ emitters: [EmitterListElement]) -> [EmitterViewModel] {
        return emitters.map({ self.emitterViewModel(for: $0.emitter, $0.incomes) })
    }
    
    func emitterViewModel(for emitter: EmitterEntity, _ incomes: [IncomeEntity]) -> EmitterViewModel {
        let incomesViewMomels = incomes.map({ IncomeViewModel($0) })
        return EmitterViewModel(emitter, incomes: incomesViewMomels, baseUrl: baseUrl)
    }
}
