//
//  MockOapDataProvider.swift
//  CoreTestData
//
//  Created by José Carlos Estela Anguita on 19/10/21.
//

import CoreDomain

public class MockOapDataProvider {
    public var authorizeOperation: Result<RedirectUriRepresentable, Error>!
    public var challenges: Result<[ChallengeRepresentable], Error>!
    public var confirmChallenges: Result<Void, Error>!
}
