//
//  CardboardingProxy.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/13/20.
//

import CoreFoundationLib
import Foundation

final class CardboardingProxy: ModuleProxy {
    typealias Output = CardboardingConfiguration
    private var onSuccess: ((Output) -> Void)?
    private var onError: ((UseCaseError<StringErrorOutput>) -> Void)?
    private let dependenciesResolver: DependenciesResolver
    
    private lazy var preSetupSuperUseCase: CardboardingPreSetupSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: CardboardingPreSetupSuperUseCase.self)
        superUseCase.handlerDelegate = self
        return superUseCase
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func run(onSuccess: ((Output) -> Void)?, onError: ((UseCaseError<StringErrorOutput>) -> Void)?) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.preSetupSuperUseCase.execute()
    }
}

extension CardboardingProxy: CardboardingPreSetupSuperUseCaseDelegate {
    func didFinishSuccessfuly(_ configuration: CardboardingConfiguration) {
        self.onSuccess?(configuration)
    }
    
    func didFinishWithError(error: UseCaseError<StringErrorOutput>) {
        self.onError?(error)
    }
}
