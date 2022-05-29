//
//  GetPeriodSelectedAnalysisAreaUseCase.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 23/2/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol ManagePeriodSelectedAnalysisAreaUseCase {
    func getPeriodSelectorPublisher() -> AnyPublisher<UserDataAnalysisAreaRepresentable?, Never>
    func savePeriodSelectorPublisher(userDataAnalysisArea: UserDataAnalysisAreaRepresentable) -> AnyPublisher<Void, Never>
}

struct DefaultManagePeriodSelectedAnalysisAreaUseCase {
    private let repository: UserSessionFinancialHealthRepository
    
    init(dependencies: AnalysisAreaHomeDependenciesResolver) {
        repository = dependencies.external.resolve()
    }
}

extension DefaultManagePeriodSelectedAnalysisAreaUseCase: ManagePeriodSelectedAnalysisAreaUseCase {
    func getPeriodSelectorPublisher() -> AnyPublisher<UserDataAnalysisAreaRepresentable?, Never> {
        return self.repository.getUserDataAnalysisArea()
    }
    
    func savePeriodSelectorPublisher(userDataAnalysisArea: UserDataAnalysisAreaRepresentable) -> AnyPublisher<Void, Never> {
        return self.repository.saveUserDataAnalysisArea(userDataAnalysisArea)
    }
}
