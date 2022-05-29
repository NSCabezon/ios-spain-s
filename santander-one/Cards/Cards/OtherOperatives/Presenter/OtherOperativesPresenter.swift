//
//  OtherOperativesPresenter.swift
//  Card
//
//  Created by Boris Chirino Fernandez on 10/12/2019.
//

import Foundation
import CoreFoundationLib

protocol OtherOperativesPresenterProtocol: AnyObject {
    var view: OtherOperativesViewProtocol? { get set }
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
    var arrayActionsInSection: [CardActionViewModel] = []
    
    // MARK: - Pull offers
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().cards
    }
    var offers: [PullOfferLocation: OfferEntity] = [:]
    
    // MARK: - Public
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: - Private
    
    private func otherOperativeActions(type: OldCardActionType, card: CardEntity) {
        if let trackName = type.trackName {
            trackEvent(.operative, parameters: [.cardType: card.trackId, .cardOperative: trackName])
        }
        self.otherOperativesCoordinator.goToAction(type: type, card: card)
    }
}

extension OtherOperativesPresenter: OtherOperativesPresenterProtocol {
    func finishAndDismissView() {
        otherOperativesCoordinator.dismiss()
    }
    
    func viewDidLoad() {
        MainThreadUseCaseWrapper(
            with: otherOperativesUseCase.setRequestValues(requestValues: GetOtherOperativesUseCaseInput(locations: locations)),
            onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.offers = response.pullOfferCandidates
                
                let arrayActions = self.dependenciesResolver.resolve(firstTypeOf: CardActionFactoryProtocol.self)
                    .getOtherOperativesCardActions(
                        for: response.configuration.card,
                        offers: response.pullOfferCandidates,
                        cardActions: (self.otherOperativeActions, nil),
                        isOTPExcepted: response.isOTPExcepted
                    )
                switch response.configuration.card.cardType {
                case .credit:
                    let arrayCardActionsTuples = self.classifyCreditCardsIntoSections(arrayActions)
                    let arraySection = CreditCardActionSection.allCases
                    for section in arraySection {

                        let sectionWithActions = self.getSectionsFromDictionary(actionSection: section,
                                                                                 arrayCardActionsTuples: arrayCardActionsTuples)
                        self.view?.addActions(sectionWithActions.0,
                                              sectionTitle: sectionWithActions.1,
                                              sectionTitleIdentifier: "moreOptions_\(section.rawValue)_title")

                    }
                case .debit:
                    let arrayCardActionsTuples = self.classifyDebitCardsIntoSections(arrayActions)
                    let arraySection = DebitCardActionSection.allCases
                    for section in arraySection {

                        let sectionWithActions = self.getDebitSections(actionSection: section,
                                                                       arrayCardActionsTuples: arrayCardActionsTuples)
                        self.view?.addActions(sectionWithActions.0,
                                              sectionTitle: sectionWithActions.1,
                                              sectionTitleIdentifier: "moreOptions_\(section.rawValue)_title")

                    }
                case .prepaid:
                    let arrayCardActionsTuples = self.classifyPrepaidCardsIntoSections(arrayActions)
                    let arraySection = PrepaidCardActionSection.allCases
                    for section in arraySection {

                        let sectionWithActions = self.getPrepaidSections(actionSection: section,
                                                                         arrayCardActionsTuples: arrayCardActionsTuples)
                        self.view?.addActions(sectionWithActions.0,
                                              sectionTitle: sectionWithActions.1,
                                              sectionTitleIdentifier: "moreOptions_\(section.rawValue)_title")

                    }
                }
            }
        )
    }
    
    private func classifyCreditCardsIntoSections(_ arrayCardActionViewModel: [CardActionViewModel]) -> [(CardActionViewModel, CreditCardActionSection)] {
        var arrayCardActionsTuples: [(CardActionViewModel, CreditCardActionSection)] = []
        for cardAction in arrayCardActionViewModel {
            switch cardAction.actionType {
            case .delayPayment, .payOff, .financingBills:
                arrayCardActionsTuples.append((cardAction, .financing))
            case .modifyLimits, .solidarityRounding, .mobileTopUp, .configure, .applePay:
                arrayCardActionsTuples.append((cardAction, .otherOperatives))
            case .detail, .pdfExtract, .historicPdfExtract, .suscription, .fractionablePurchases, .subscriptions, .cvv:
                arrayCardActionsTuples.append((cardAction, .queries))
            case .hireCard:
                arrayCardActionsTuples.append((cardAction, .contract))
            case .block, .ces, .duplicateCard:
                arrayCardActionsTuples.append((cardAction, .security))
            case .custome(let values):
                guard let section = CreditCardActionSection(rawValue: values.section) else {
                    break
                }
                arrayCardActionsTuples.append((cardAction, section))
            default:
                break
            }
        }
        return arrayCardActionsTuples
    }
    
    func getSectionsFromDictionary(actionSection: CreditCardActionSection,
                                   arrayCardActionsTuples: [(CardActionViewModel, CreditCardActionSection)]) -> ([CardActionViewModel], String) {
        var arrayActionsForSection: [CardActionViewModel] = []
        
        for (cardAction, section) in arrayCardActionsTuples where section == actionSection {
            arrayActionsForSection.append(cardAction)
        }
        var sectionTitle: String
        switch actionSection {
        case .financing:
            sectionTitle = localized("option_title_financing")
        case .otherOperatives:
            sectionTitle = localized("productOption_text_moreOperations")
        case .queries:
            sectionTitle = localized("option_title_queries")
        case .contract:
            sectionTitle = localized("option_title_contract")
        case .security:
            sectionTitle = localized("option_title_ofSecurity")
        }
        return (arrayActionsForSection, sectionTitle)
    }
    
    // MARK: - Prepaid cards
    private func classifyPrepaidCardsIntoSections(_ arrayCardActionViewModel: [CardActionViewModel]) -> [(CardActionViewModel, PrepaidCardActionSection)] {
        var arrayCardActionsTuples: [(CardActionViewModel, PrepaidCardActionSection)] = []
        for cardAction in arrayCardActionViewModel {
            switch cardAction.actionType {
            case .detail, .suscription, .cvv:
                arrayCardActionsTuples.append((cardAction, .queries))
            case .hireCard:
                arrayCardActionsTuples.append((cardAction, .contract))
            case .duplicateCard, .block:
                arrayCardActionsTuples.append((cardAction, .security))
            case .custome(let values):
                guard let section = PrepaidCardActionSection(rawValue: values.section) else {
                    break
                }
                arrayCardActionsTuples.append((cardAction, section))
            default:
                break
            }
        }
        return arrayCardActionsTuples
    }
    
    func getPrepaidSections(actionSection: PrepaidCardActionSection, arrayCardActionsTuples: [(CardActionViewModel, PrepaidCardActionSection)]) -> ([CardActionViewModel], String) {
        var arrayActionsForSection: [CardActionViewModel] = []
        for (cardAction, section) in arrayCardActionsTuples where section == actionSection {
            arrayActionsForSection.append(cardAction)
        }
        var sectionTitle: String
        switch actionSection {
        case .queries:
            sectionTitle = localized("option_title_queries")
        case .contract:
            sectionTitle = localized("option_title_contract")
        case .security:
            sectionTitle = localized("option_title_ofSecurity")
        case.otherOperatives:
            sectionTitle = localized("productOption_text_moreOperations")
        }
        return (arrayActionsForSection, sectionTitle)
    }
    
    // MARK: - Debit cards
    private func classifyDebitCardsIntoSections(_ arrayCardActionViewModel: [CardActionViewModel]) -> [(CardActionViewModel, DebitCardActionSection)] {
        var arrayCardActionsTuples: [(CardActionViewModel, DebitCardActionSection)] = []
        for cardAction in arrayCardActionViewModel {
            switch cardAction.actionType {
            case .solidarityRounding, .mobileTopUp, .configure:
                arrayCardActionsTuples.append((cardAction, .otherOperatives))
            case .detail, .suscription, .subscriptions, .cvv:
                arrayCardActionsTuples.append((cardAction, .queries))
            case .hireCard:
                arrayCardActionsTuples.append((cardAction, .contract))
            case .block, .ces, .duplicateCard:
                arrayCardActionsTuples.append((cardAction, .security))
            case .custome(let values):
                guard let section = DebitCardActionSection(rawValue: values.section) else {
                    break
                }
                arrayCardActionsTuples.append((cardAction, section))
            default:
                break
            }
        }
        return arrayCardActionsTuples
    }
    
    func getDebitSections(actionSection: DebitCardActionSection, arrayCardActionsTuples: [(CardActionViewModel, DebitCardActionSection)]) -> ([CardActionViewModel], String) {
        var arrayActionsForSection: [CardActionViewModel] = []
        for (cardAction, section) in arrayCardActionsTuples where section == actionSection {
            arrayActionsForSection.append(cardAction)
        }
        var sectionTitle: String
        switch actionSection {
        case .otherOperatives:
            sectionTitle = localized("productOption_text_moreOperations")
        case .queries:
            sectionTitle = localized("option_title_queries")
        case .contract:
            sectionTitle = localized("option_title_contract")
        case .security:
            sectionTitle = localized("option_title_ofSecurity")
        }
        return (arrayActionsForSection, sectionTitle)
    }
}

extension OtherOperativesPresenter: AutomaticScreenEmmaActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: CardsHomePage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.cardsEventID
        return CardsHomePage(emmaToken: emmaToken)
    }
}
