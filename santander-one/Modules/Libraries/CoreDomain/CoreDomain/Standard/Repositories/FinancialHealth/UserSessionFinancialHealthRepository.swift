//
//  UserSessionFinancialHealthRepository.swift
//  CoreDomain
//
//  Created by Jose Javier Montes Romero on 24/2/22.
//

import Foundation
import OpenCombine

public protocol UserSessionFinancialHealthRepository {
    func saveUserDataAnalysisArea(_ userData: UserDataAnalysisAreaRepresentable) -> AnyPublisher<Void, Never>
    func getUserDataAnalysisArea() -> AnyPublisher<UserDataAnalysisAreaRepresentable?, Never>
}
