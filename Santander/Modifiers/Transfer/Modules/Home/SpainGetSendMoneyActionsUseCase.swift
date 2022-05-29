//
//  SpainGetSendMoneyActionsUseCase.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 21/12/21.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib
import Transfer

enum SpainSendMoneyActionTypeIdentifier: String {
    case bizum
    case onePayFx
    case correosCash
}

struct SpainGetSendMoneyActionsUseCase {
    private struct SpainSendMoneyAction {
        let identifier: String
        let title: String
        let description: String
        let icon: String

        func toSendMoneyActionType(_ offer: OfferRepresentable) -> SendMoneyHomeActionType {
            return .custom(
                identifier: self.identifier,
                title: self.title,
                description: self.description,
                icon: self.icon,
                offer: offer
            )
        }
    }
    
    private struct SpainTransferPullOffers {
        static let fxpayTransferHomeOffer = "FXPAY_TRANSFER_HOME"
        static let correosCashOffer = "CORREOS_CASH_TRANSFER_HOME"
    }
    
    private let bizum: SendMoneyHomeActionType = .custom(
        identifier: SpainSendMoneyActionTypeIdentifier.bizum.rawValue,
        title: "transferOption_button_bizum",
        description: "transferOption_text_bizum",
        icon: "oneIcnBizum"
    )
    
    private var onePayFx = SpainSendMoneyAction(
        identifier: SpainSendMoneyActionTypeIdentifier.onePayFx.rawValue,
        title: "transferOption_button_onePay",
        description: "transferOption_text_onePay",
        icon: "icnOnePay"
    )
    
    private var correosCash = SpainSendMoneyAction(
        identifier: SpainSendMoneyActionTypeIdentifier.correosCash.rawValue,
        title: "transferOption_button_correosCash",
        description: "transferOption_text_correosCash",
        icon: "icnCorreosCash"
    )
    
    private var candidateOfferUseCase: GetCandidateOfferUseCase
    
    public init(candidateOfferUseCase: GetCandidateOfferUseCase) {
        self.candidateOfferUseCase = candidateOfferUseCase
    }
}

extension SpainGetSendMoneyActionsUseCase: GetSendMoneyActionsUseCase {
    func fetchSendMoneyAction(_ location: PullOfferLocation) -> AnyPublisher<SendMoneyHomeActionType, Error> {
        offersPublisher(location)
            .compactMap { offer -> SendMoneyHomeActionType? in
                switch location.stringTag {
                case SpainTransferPullOffers.fxpayTransferHomeOffer:
                    return self.onePayFx.toSendMoneyActionType(offer)
                case TransferPullOffers.donationTransferOffer:
                    return SendMoneyHomeActionType.donations(offer)
                case SpainTransferPullOffers.correosCashOffer:
                    return self.correosCash.toSendMoneyActionType(offer)
                default: return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func fetchSendMoneyActions(_ locations: [PullOfferLocation], page: String?) -> AnyPublisher<[SendMoneyHomeActionType], Never> {
        let locations = locations + getSpainLocations(page)
        let actions = locations.map(fetchSendMoneyAction)
        return Publishers.MergeMany(actions)
            .collect(locations.count)
            .replaceError(with: [])
            .map(getHomeSendMoneyActions)
            .eraseToAnyPublisher()
    }
    
    func offersPublisher(_ location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        return candidateOfferUseCase
            .fetchCandidateOfferPublisher(location: location)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

private extension SpainGetSendMoneyActionsUseCase {
    func getHomeSendMoneyActions(_ offerActions: [SendMoneyHomeActionType]) -> [SendMoneyHomeActionType] {
        var actions = [.transfer, .transferBetweenAccounts, bizum, .atm, .scheduleTransfers]
        for action in offerActions {
            switch action {
            case .donations:
                actions.append(action)
            case .custom(let identifier, _, _, _, _)
                where SpainSendMoneyActionTypeIdentifier(rawValue: identifier) == .onePayFx:
                actions.insert(action, at: 3)
            case .custom(let identifier, _, _, _, _)
                where SpainSendMoneyActionTypeIdentifier(rawValue: identifier) == .correosCash:
                actions.insert(action, at: 5)
            default: break
            }
        }
        return actions
    }
    
    func getSpainLocations(_ page: String?) -> [PullOfferLocation] {
        return [PullOfferLocation(stringTag: SpainTransferPullOffers.fxpayTransferHomeOffer,
                                  hasBanner: false, pageForMetrics: page),
                PullOfferLocation(stringTag: SpainTransferPullOffers.correosCashOffer,
                                  hasBanner: false, pageForMetrics: page)]
    }
}
