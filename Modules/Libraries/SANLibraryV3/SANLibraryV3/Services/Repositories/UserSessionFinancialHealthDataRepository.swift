//
//  UserSessionFinancialHealthDataRepository.swift
//  SANLibraryV3
//
//  Created by Jose Javier Montes Romero on 24/2/22.
//

import CoreDomain
import SANServicesLibrary
import OpenCombine

struct UserSessionFinancialHealthDataRepository: UserSessionFinancialHealthRepository {
    
    let storage: Storage
    
    func saveUserDataAnalysisArea(_ userData: UserDataAnalysisAreaRepresentable) -> AnyPublisher<Void, Never> {
        return Future { promise in
            self.storage.store(userData)
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func getUserDataAnalysisArea() -> AnyPublisher<UserDataAnalysisAreaRepresentable?, Never> {
        return Future { promise in
            let userDataAnalysisArea = self.storage.get(UserDataAnalysisAreaRepresentable.self)
            promise(.success(userDataAnalysisArea))
        }.eraseToAnyPublisher()
    }
}

