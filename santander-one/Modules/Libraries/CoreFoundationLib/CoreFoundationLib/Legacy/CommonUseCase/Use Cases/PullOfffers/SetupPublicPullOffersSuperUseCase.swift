//
//  SetupPublicPullOffersSuperUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/24/20.
//

import Foundation
import SANLegacyLibrary

public protocol SetupPublicPullOffersSuperUseCaseDelegate: AnyObject {
    func onSuccess()
}

public final class SetupPublicPullOffersSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    weak var delegate: SetupPublicPullOffersSuperUseCaseDelegate?

    public func onSuccess() {
        self.delegate?.onSuccess()
    }
    
    public func onError(error: String?) { }
}

public class SetupPublicPullOffersSuperUseCase: SuperUseCase<SetupPublicPullOffersSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handlerDelegate: SetupPublicPullOffersSuperUseCaseDelegateHandler
    
    public weak var delegate: SetupPublicPullOffersSuperUseCaseDelegate? {
        get { return self.handlerDelegate.delegate }
        set { self.handlerDelegate.delegate = newValue }
    }
    
    private var calculateLocationsUseCase: CalculateLocationsUseCase {
        let calculateLocationsUseCase = self.dependenciesResolver.resolve(for: CalculateLocationsUseCase.self)
        _ = calculateLocationsUseCase.setRequestValues(requestValues: CalculateLocationsUseCaseInput())
        return calculateLocationsUseCase
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        let extractedExpr: SetupPublicPullOffersSuperUseCaseDelegateHandler = SetupPublicPullOffersSuperUseCaseDelegateHandler()
        self.handlerDelegate = extractedExpr
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handlerDelegate)
    }
    
    public override func setupUseCases() {
        self.add(self.dependenciesResolver.resolve(for: SetupPullOffersUseCase.self))
        self.add(self.dependenciesResolver.resolve(for: LoadPublicPullOffersVarsUseCase.self))
        self.add(self.calculateLocationsUseCase)
    }
}
