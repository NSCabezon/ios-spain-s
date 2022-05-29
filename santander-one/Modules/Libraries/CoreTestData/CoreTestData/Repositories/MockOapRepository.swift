//
//  MockOapRepository.swift
//  CoreTestData
//
//  Created by José Carlos Estela Anguita on 19/10/21.
//

import CoreDomain

public struct MockOapRepository: OneAuthorizationProcessorRepository {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func authorizeOperation(authorizationId: String, scope: String) throws -> Result<RedirectUriRepresentable, Error> {
        return mockDataInjector.mockDataProvider.oapData.authorizeOperation
    }
    
    public func getChallenges(authorizationId: String) throws -> Result<[ChallengeRepresentable], Error> {
        return mockDataInjector.mockDataProvider.oapData.challenges
    }
    
    public func confirmChallenges(authorizationId: String, verification: [ChallengeVerificationRepresentable]) throws -> Result<Void, Error> {
        return mockDataInjector.mockDataProvider.oapData.confirmChallenges
    }
}
