//
//  MockUserSessionFinancialHealthRepository.swift
//  CoreTestData
//
//  Created by Miguel Ferrer Fornali on 7/3/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public final class MockUserSessionFinancialHealthRepository: UserSessionFinancialHealthRepository {
    var saveUserData: Void!
    var getUserData: UserDataAnalysisAreaRepresentable!
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }
    
    public init(mockDataInjector: MockDataInjector) {
        getUserData = mockDataInjector
            .mockDataProvider
            .userSessionFinancialHealthData
            .getUserData
        
        saveUserData = mockDataInjector
            .mockDataProvider
            .userSessionFinancialHealthData
            .saveUserData
    }
    
    public func saveUserDataAnalysisArea(_ userData: UserDataAnalysisAreaRepresentable) -> AnyPublisher<Void, Never> {
        return Just(saveUserData)
            .eraseToAnyPublisher()
    }
    
    public func getUserDataAnalysisArea() -> AnyPublisher<UserDataAnalysisAreaRepresentable?, Never> {
        return Just(getUserData)
            .eraseToAnyPublisher()
    }
}
