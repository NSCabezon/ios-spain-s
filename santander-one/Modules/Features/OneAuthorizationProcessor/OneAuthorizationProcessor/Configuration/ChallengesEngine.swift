//
//  ChallengesEngine.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 5/10/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class ChallengesEngine {
    
    private let challenges: [ChallengeRepresentable]
    private weak var delegate: ChallengesHandlerDelegate?
    
    init(challenges: [ChallengeRepresentable], delegate: ChallengesHandlerDelegate?) {
        self.challenges = challenges
        self.delegate = delegate
    }
    
    func start(_ completion: @escaping (Result<[ChallengeVerificationRepresentable], Error>) -> Void) {
        guard challenges.count > 0 else { return completion(.success([])) }
        startChallenge(
            at: 0,
            verifications: [],
            completion: completion
        )
    }
}

private extension ChallengesEngine {
    
    var handler: ChallengesHandler {
        return CountryChallengesHandler(delegate: delegate, next: CoreChallengesHandler())
    }
    
    func startChallenge(at index: Int, verifications: [ChallengeVerificationRepresentable], completion: @escaping (Result<[ChallengeVerificationRepresentable], Error>) -> Void) {
        let challenge = challenges[index]
        handler.handle(challenge) { [weak self] result in
            switch result {
            case .success(let verification):
                let nextIndex = index + 1
                guard self?.challenges.indices.contains(nextIndex) == true else {
                    return completion(.success(verifications + [verification]))
                }
                self?.startChallenge(
                    at: nextIndex,
                    verifications: verifications + [verification],
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private protocol ChallengesHandler {
    func handle(_ challenge: ChallengeRepresentable, completion: @escaping (Result<ChallengeVerificationRepresentable, Error>) -> Void)
}

private struct CoreChallengesHandler: ChallengesHandler {
    
    func handle(_ challenge: ChallengeRepresentable, completion: @escaping (Result<ChallengeVerificationRepresentable, Error>) -> Void) {
        // Currently we don't have any challenge defined in Core
        completion(.failure(NSError()))
    }
}

private struct CountryChallengesHandler: ChallengesHandler {
    
    weak var delegate: ChallengesHandlerDelegate?
    let next: ChallengesHandler
    
    func handle(_ challenge: ChallengeRepresentable, completion: @escaping (Result<ChallengeVerificationRepresentable, Error>) -> Void) {
        guard let delegate = self.delegate else { return next.handle(challenge, completion: completion) }
        delegate.handle(challenge, authorizationId: "") { result in
            switch result {
            case .handled(let verification):
                completion(.success(verification))
            case .notHandled:
                next.handle(challenge, completion: completion)
            case .failed(let error):
                completion(.failure(error))
            }
        }
    }
}
