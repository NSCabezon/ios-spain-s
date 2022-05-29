//
//  OneAuthorizationProcessorRepository.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 4/10/21.
//

import Foundation

public protocol OneAuthorizationProcessorRepository {
    func authorizeOperation(authorizationId: String, scope: String) throws -> Result<RedirectUriRepresentable, Error>
    func getChallenges(authorizationId: String) throws -> Result<[ChallengeRepresentable], Error>
    func confirmChallenges(authorizationId: String, verification: [ChallengeVerificationRepresentable]) throws -> Result<Void, Error>
}
