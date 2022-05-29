//
//  PreSetupCardOnOffUseCase.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 31/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

enum CardOnOffOption {
    case turnOn
    case turnOff
}

protocol PreSetupCardOnOffUseCaseProtocol: UseCase<PreSetupCardOnOffUseCaseInput, PreSetupCardOnOffUseCaseOkOutput, StringErrorOutput> {}

final class PreSetupCardOnOffUseCase: UseCase<PreSetupCardOnOffUseCaseInput, PreSetupCardOnOffUseCaseOkOutput, StringErrorOutput> {
    private let resolver: DependenciesResolver
    private let globalPosition: CoreFoundationLib.GlobalPositionRepresentable
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
        self.globalPosition = resolver.resolve(for: CoreFoundationLib.GlobalPositionRepresentable.self)
    }
    
    override func executeUseCase(requestValues: PreSetupCardOnOffUseCaseInput) throws -> UseCaseResponse<PreSetupCardOnOffUseCaseOkOutput, StringErrorOutput> {
        if requestValues.card == nil {
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            let visibleCards = merger.cards.visibles()
            let cards: [CardEntity]
            var error: String = ""
            if let option = requestValues.option {
                switch option {
                case .turnOn:
                    error = "deeplink_alert_errorNotOffCard"
                    cards = visibleCards.filter({ $0.isReadyForOn })
                case .turnOff:
                    error = "deeplink_alert_errorOffCard"
                    cards = visibleCards.filter({ $0.isReadyForOff })
                default:
                    cards = []
                }
            } else {
                cards = visibleCards
            }
            guard cards.count > 0 else {
                return .error(StringErrorOutput(error))
            }
            return .ok(PreSetupCardOnOffUseCaseOkOutput(cards: cards))
        } else {
            return .ok(PreSetupCardOnOffUseCaseOkOutput(cards: []))
        }
    }
}

extension PreSetupCardOnOffUseCase: PreSetupCardOnOffUseCaseProtocol {}

struct PreSetupCardOnOffUseCaseInput {
    let card: CardEntity?
    let option: CardBlockType?
}

struct PreSetupCardOnOffUseCaseOkOutput {
    let cards: [CardEntity]
}
