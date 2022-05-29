//
//  GetAnalysisSectionsUseCase.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 24/04/2020.
//

import CoreFoundationLib

public enum AnalysisAreaSections {
    case monthsSelector
    case savingsBudgetCarrousel
    case movements
    case recommendations
    case piggyBank
    case savingTips
    case financialHealth
}

final class GetAnalysisSectionsUseCase: UseCase<Void, AnalysisSectionsUseCaseOutPut, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private var appConfigRepository: AppConfigRepositoryProtocol {
       dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<AnalysisSectionsUseCaseOutPut, StringErrorOutput> {
        let movementsSectionEnabled: Bool = self.appConfigRepository.getBool("enabledAnalysisZoneMovements") ?? true
        let isFinancialHealthEnabled = appConfigRepository.getBool("enabledAnalysisZoneFinancialHealth") ?? true

        var sections = [AnalysisAreaSections]()
        if isFinancialHealthEnabled {
            sections.append(AnalysisAreaSections.financialHealth)
        }
        
        if movementsSectionEnabled {
            sections.append(AnalysisAreaSections.movements)
        }
        
        return .ok(AnalysisSectionsUseCaseOutPut(enabledSections: sections) )
    }
}

struct AnalysisSectionsUseCaseOutPut {
    let enabledSections: [AnalysisAreaSections]
}
