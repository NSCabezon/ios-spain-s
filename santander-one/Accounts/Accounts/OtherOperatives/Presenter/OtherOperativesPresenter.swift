//
//  OtherOperativesPresenter.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 10/12/2019.
//

import Foundation
import CoreFoundationLib

protocol OtherOperativesPresenterProtocol: AnyObject {
    var view: OtherOperativesViewProtocol? {get set}
    func finishAndDismissView()
    func viewDidLoad()
}

final class OtherOperativesPresenter {
    weak var view: OtherOperativesViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var otherOperativesCoordinator: OtherOperativesCoordinator {
        self.dependenciesResolver.resolve(for: OtherOperativesCoordinator.self)
    }
    var otherOperativesUseCase: GetOtherOperativesUseCase {
        dependenciesResolver.resolve(for: GetOtherOperativesUseCase.self)
    }
    var accountOtherOperativesActionUseCase: GetAccountOtherOperativesActionUseCaseProtocol {
        dependenciesResolver.resolve(for: GetAccountOtherOperativesActionUseCaseProtocol.self)
    }
    
    // MARK: - Pull offers
    
    var locations: [PullOfferLocation] {
        guard let locations = self.dependenciesResolver.resolve(forOptionalType: AccountModifierProtocol.self)?.accountsOtherOperatives else {
            return PullOffersLocationsFactoryEntity().accountsOtherOperatives
        }
        return locations
    }
    var offers: [PullOfferLocation: OfferEntity] = [:]

    // MARK: - Public
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: - Private
    
    private func otherOperativeActions(type: AccountActionType, account: AccountEntity) {
        if let trackName = type.trackName {
            trackEvent(.operative, parameters: [.accountOperative: trackName])
        }
        self.otherOperativesCoordinator.goToAction(type: type, account: account)
    }
}

extension OtherOperativesPresenter: OtherOperativesPresenterProtocol {
    func finishAndDismissView() {
        otherOperativesCoordinator.dismiss()
    }
    
    func viewDidLoad() {
        let input = GetOtherOperativesUseCaseInput(locations: locations)
        Scenario(useCase: otherOperativesUseCase, input: input)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.loadResult(result)
            }
    }
    
    func classifyInSections(arrayAccountActionsviewModel: [AccountActionViewModel], account: AccountEntity) {
        let input = GetAccountOtherOperativesActionUseCaseInput(account: account)
        Scenario(useCase: accountOtherOperativesActionUseCase, input: input)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                var arrayAccountActionsTuples: [(AccountActionViewModel, AccountActionSection)] = []
                let everyDayOperatives = result.everyDayOperatives
                let adjustAccounts = result.adjustAccounts
                let queries = result.queriesActions
                let contract = result.contractActions
                let officeArrangement = result.officeArrangementActions
                for accountAction in arrayAccountActionsviewModel {
                    switch accountAction.actionType {
                    case everyDayOperatives:
                        arrayAccountActionsTuples.append((accountAction, .everyDayOperatives))
                    case adjustAccounts:
                        arrayAccountActionsTuples.append((accountAction, .adjustAccount))
                    case queries:
                        arrayAccountActionsTuples.append((accountAction, .queries))
                    case contract:
                        arrayAccountActionsTuples.append((accountAction, .contract))
                    case officeArrangement:
                        arrayAccountActionsTuples.append((accountAction, .officeArrangement))
                    default:
                        break
                    }
                }
                let arraySection = AccountActionSection.allCases
                for section in arraySection {
                    let (model, title) = self.getSectionsFromDictionary(
                        actionSection: section,
                        arrayAcountActionsTuples: arrayAccountActionsTuples
                    )
                    self.view?.addActions(
                        model,
                        sectionTitle: title,
                        sectionTitleIdentifier: section.titleIdentifier
                    )
                }
            }
    }
    
    func getSectionsFromDictionary(actionSection: AccountActionSection, arrayAcountActionsTuples: [(AccountActionViewModel, AccountActionSection)]) -> ([AccountActionViewModel], String) {
        var arrayActionsForSection: [AccountActionViewModel] = []
        for (accountAction, section) in arrayAcountActionsTuples where section == actionSection {
            arrayActionsForSection.append(accountAction)
        }
        var sectionTitle: String
        switch actionSection {
        case .everyDayOperatives:
            sectionTitle = localized("option_title_daytoDayOperation")
        case .adjustAccount:
            sectionTitle = localized("option_title_adjustAccount")
        case .queries:
            sectionTitle = localized("option_title_queries")
        case .contract:
            sectionTitle = localized("option_title_contract")
        case .officeArrangement:
            sectionTitle = localized("option_title_managementOffice")
        }
        return (arrayActionsForSection, sectionTitle)
    }
}

extension OtherOperativesPresenter: AutomaticScreenEmmaActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: AccountsHomePage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.accountsEventID
        return AccountsHomePage(emmaToken: emmaToken)
    }
}

private extension OtherOperativesPresenter {
    func loadResult(_ response: GetOtherOperativesUseCaseOkOutput) {
        let input = GetAccountOtherOperativesActionUseCaseInput(account: response.configuration.account)
        Scenario(useCase: accountOtherOperativesActionUseCase, input: input)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.offers = response.pullOfferCandidates
                let actionsViewModels = self.dependenciesResolver.resolve(for: AccountActionAdapter.self).getOtherOperativeActions(
                    entity: response.configuration.account,
                    offers: response.pullOfferCandidates,
                    action: self.otherOperativeActions,
                    accounts: response.accounts,
                    otherOperativesActions: result.otherOperativeActions)
                self.classifyInSections(arrayAccountActionsviewModel: actionsViewModels, account: response.configuration.account)
            }
    }
}
