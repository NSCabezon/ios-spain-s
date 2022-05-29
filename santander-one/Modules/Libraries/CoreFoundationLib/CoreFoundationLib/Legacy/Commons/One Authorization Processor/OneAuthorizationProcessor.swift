//
//  OneAuthorizationProcessor.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 4/10/21.
//

import Foundation
import CoreDomain

public protocol OneAuthorizationProcessorDelegate: AnyObject {
    func authorizationDidFinishSuccessfully()
    func authorizationDidFinishWithError(_ error: Error)
}

public protocol OneAuthorizationProcessor {
    var delegate: OneAuthorizationProcessorDelegate? { get set }
    var challengesDelegate: ChallengesHandlerDelegate? { get set }
    func start(authorizationId: String, scope: String)
}

public protocol OneAuthorizationProcessorLauncher {
    var dependenciesResolver: DependenciesResolver { get }
    func goToAuthorizationProcessor(authorizationId: String, scope: String)
}

public enum ChallengeResult {
    case handled(ChallengeVerificationRepresentable)
    case notHandled
    case failed(Error)
}

public protocol ChallengesHandlerDelegate: AnyObject {
    func handle(_ challenge: ChallengeRepresentable, authorizationId: String, completion: @escaping (ChallengeResult) -> Void)
}
