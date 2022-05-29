//
//  AccountActionAdapter.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import Foundation
import CoreFoundationLib

enum AccountActionSection: CaseIterable {
    case everyDayOperatives
    case adjustAccount
    case queries
    case contract
    case officeArrangement
    
    public var titleIdentifier: String {
        switch self {
        case .everyDayOperatives:
            return "option_title_daytoDayOperation"
        case .adjustAccount:
            return "option_title_adjustAccount"
        case .queries:
            return "option_title_queries"
        case .contract:
            return "option_title_contract"
        case .officeArrangement:
            return "option_title_managementOffice"
        }
    }
}

final class AccountActionAdapter {
    private let dependenciesResolver: DependenciesResolver
    private var otherActions: [AccountActionViewModel] = []
    private var accountOtherOperativeActionData: AccountOtherOperativeActionData?
    private lazy var accountHomeActionModifier: AccountHomeActionModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: AccountHomeActionModifierProtocol.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func getHomeActions(accountTypes: [AccountActionType], entity: AccountEntity, action: ((AccountActionType, AccountEntity) -> Void)?) -> [AccountActionViewModel] {
         guard !entity.isPiggyBankAccount else { return [] }
         guard let accountHomeModifier = self.accountHomeActionModifier else { return [] }
         
         let homeActions: [AccountActionViewModel] = accountTypes.map {
             let viewType = accountHomeModifier.getActionButtonFillViewType(for: $0)
             return AccountActionViewModel(
                 type: $0,
                 viewType: viewType,
                 entity: entity,
                 action: action
             )
         }
         
        return homeActions
    }
    
    func getOtherOperativeActions(
        entity: AccountEntity,
        offers: [PullOfferLocation: OfferEntity],
        action: ((AccountActionType, AccountEntity) -> Void)?,
        accounts: [AccountEntity], otherOperativesActions: [AccountActionType]
    ) -> [AccountActionViewModel] {
        guard !entity.isPiggyBankAccount else { return [] }
        self.otherActions = []
        self.accountOtherOperativeActionData = AccountOtherOperativeActionData(entity: entity, offers: offers, action: action)
        
        otherOperativesActions.forEach {
            switch $0 {
            case .fxPay:
                self.appendFxPay()
            case .donation:
                self.appendDonation()
            case .one:
                self.appendOne()
            case .contractAccount:
                self.appendContractAccount()
            case .ownershipCertificate:
                self.appendOwnershipCertificate()
            case .foreignExchange:
                self.appendForeignExchange()
            case .correosCash:
                self.appendCorreosCash()
            case .internalTransfer:
                self.appendInternalTransfer(accounts)
            case .receiptFinancing:
                self.appendReceiptFinancing()
            case .automaticOperations:
                self.appendAutomaticOperations()
            default:
                self.appendAction(type: $0)
            }
        }
        
        return self.otherActions
    }
}

private extension AccountActionAdapter {
    func appendInternalTransfer(_ accounts: [AccountEntity]) {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }
        if accounts.count > 1 {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .internalTransfer,
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                )
            )
        }
    }
    
    func allowContract(_ stringLocation: String, offers: [PullOfferLocation: OfferEntity]) -> Bool {
        let isOfferCandidate = self.isThereCandidateOffer(for: stringLocation, offers: offers)
        let isSanflixEnabled = isAppConfigEnabled(node: "enableApplyBySanflix")
        return (isOfferCandidate && isSanflixEnabled) || !isSanflixEnabled
    }
    
    func isThereCandidateOffer(for location: String, offers: [PullOfferLocation: OfferEntity]) -> Bool {
        return offers.contains(location: location)
    }
    
    func isAppConfigEnabled(node: String) -> Bool {
        return self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self).getBool(node) ?? false
    }
    
    func appendAction(type: AccountActionType) {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }
        self.otherActions.append(
            AccountActionViewModel(
                type: type,
                entity: accountOtherOperativeActionData.getAccountEntity(),
                action: accountOtherOperativeActionData.getAction()
            )
        )
    }
    
    func appendFxPay() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }

        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.fxPayAccountsHome) {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .fxPay(offer.offer),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.fxPayAccountsHome,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
    
    func appendDonation() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }

        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.accountsHomeDonations) {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .donation(offer.offer),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.accountsHomeDonations,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
    
    func appendOne() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }

        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.oneAcccountButton) {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .one(offer.offer),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.oneAcccountButton,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
    
    func appendContractAccount() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }
        let location = self.getContractAccountLocation()
        if allowContract(location, offers: accountOtherOperativeActionData.getOffers()) {
            let offer = accountOtherOperativeActionData.getOffers()
                .location(key: location)
            self.otherActions.append(
                AccountActionViewModel(
                    type: .contractAccount(offer?.location),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                )
            )
        }
    }
    
    func getContractAccountLocation() -> String {
        if let contractAccountLocation = self.dependenciesResolver.resolve(forOptionalType: AccountModifierProtocol.self)?.contractAccountLocation {
            return contractAccountLocation
        } else {
            return AccountsPullOffers.newAccountButton
        }
    }
    
    func appendOwnershipCertificate() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }
        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.certificateAccountButton) {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .ownershipCertificate(offer.offer),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.certificateAccountButton,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
    
    func appendForeignExchange() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }

        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.requestForeignCurrency) {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .foreignExchange(offer.offer),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.requestForeignCurrency,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
    
    func appendCorreosCash() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }

        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.correosCash) {
            let viewType: ActionButtonFillViewType? = {
                guard let contractOfferImage = offer.offer.banner?.url else { return nil }
                var viewmodel = OfferImageViewActionButtonViewModel(url: contractOfferImage)
                viewmodel.identifier = "icnCorreosCash"
                return .offer(viewmodel)
            }()
            self.otherActions.append(
                AccountActionViewModel(
                    type: .correosCash(offer.offer),
                    viewType: viewType,
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.correosCash,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
    
    func appendReceiptFinancing() {
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData else { return }
        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.receiptFinancing) {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .receiptFinancing(offer.offer),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.receiptFinancing,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
    
    func appendAutomaticOperations() {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve()
        guard let accountOtherOperativeActionData = self.accountOtherOperativeActionData,
              globalPosition.accounts.all().count >= 2
        else { return }
        if let offer = accountOtherOperativeActionData.getOffers()
            .location(key: AccountsPullOffers.automaticOperations) {
            self.otherActions.append(
                AccountActionViewModel(
                    type: .automaticOperations(offer.offer),
                    entity: accountOtherOperativeActionData.getAccountEntity(),
                    action: accountOtherOperativeActionData.getAction()
                ),
                conditionedBy: isThereCandidateOffer(
                    for: AccountsPullOffers.automaticOperations,
                    offers: accountOtherOperativeActionData.getOffers()
                )
            )
        }
    }
}
