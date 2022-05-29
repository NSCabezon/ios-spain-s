//
//  SpainGetCreditCardUseCase.swift
//  Santander
//
//  Created by Hernán Villamil on 11/3/22.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import OpenCombine
import Menu

final class SpainGetCreditCardUseCase: UseCase<Void, GetCreditCardUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCreditCardUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let cardList = globalPosition.cards
            .visibles()
            .filter({ $0.isCreditCard })
        cardList.forEach({wait(untilFinished: $0)})
        return .ok(GetCreditCardUseCaseOkOutput(cardList: cardList))
    }
}

extension SpainGetCreditCardUseCase: GetCreditCardUseCase, CardPFMWaiter {}
