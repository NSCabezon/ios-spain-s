//
//  World123Helper.swift
//  RetailLegacy
//
//  Created by Laura González on 08/02/2021.
//

import CoreFoundationLib
import CoreDomain

final class World123Option: PrivateSubmenuOptionRepresentable {
    let type: World123OptionType
    
    var titleKey: String {
        switch type {
        case .mundoSimulate:
            return "pt_menuMundo_link_simulate"
        case .mundoWhatHave:
            return "pt_menuMundo_link_whatHave"
        case .mundoBenefits:
            return "pt_menuMundo_link_benefits"
        case .mundoSignUp:
            return "pt_menuMundo_link_signUp"
        }
    }
    
    var icon: String? {
        switch type {
        case .mundoSimulate:
            return "icnCalculator"
        case .mundoWhatHave:
            return "iconMundo123"
        case .mundoBenefits:
            return "icnBenefits"
        case .mundoSignUp:
            return "icnSignUp"
        }
    }
    
    public var submenuArrow: Bool {
        return false
    }
    
    init(type: World123OptionType) {
        self.type = type
    }
}

extension World123Option: AccessibilityProtocol {
    var accessibilityIdentifier: String? {
        switch type {
        case .mundoSimulate:
            return AccessibilitySideWorld123.btnMundoSimulate
        case .mundoWhatHave:
            return AccessibilitySideWorld123.btnMundoWhatHave
        case .mundoBenefits:
            return AccessibilitySideWorld123.btnMundoBenefits
        case .mundoSignUp:
            return AccessibilitySideWorld123.btnMundoSignUp
        }
    }
}

final class World123Helper {
    private var completion: (([PrivateSubmenuOptionRepresentable]) -> Void)?
    private weak var presenter: PrivateSubmenuPresenter?
    private var navigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu
    private weak var offerDelegate: PrivateSideMenuOfferDelegate?
    private var comingFeatures: Bool
    
    var privateMenuWrapper: PrivateMenuWrapper
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().world123SideMenu
    }
    
    init(privateMenuWrapper: PrivateMenuWrapper,
         presenter: PrivateSubmenuPresenter,
         navigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu,
         offerDelegate: PrivateSideMenuOfferDelegate,
         comingFeatures: Bool) {
        self.privateMenuWrapper = privateMenuWrapper
        self.presenter = presenter
        self.navigator = navigator
        self.offerDelegate = offerDelegate
        self.comingFeatures = comingFeatures
    }
    
    private func wrapperUpdated() {
        var options: [World123Option] = []
        getCandidateOffers { [weak self] candidates in
            guard let self = self else { return }
            if candidates[.MUNDO123_MENU_SIMULATE] != nil {
                options += [World123Option(type: .mundoSimulate)]
            }
            if candidates[.MUNDO123_MENU_WHATHAVE] != nil {
                options += [World123Option(type: .mundoWhatHave)]
            }
            if candidates[.MUNDO123_MENU_BENEFITS] != nil {
                options += [World123Option(type: .mundoBenefits)]
            }
            if candidates[.MUNDO123_MENU_SIGNUP] != nil {
                options += [World123Option(type: .mundoSignUp)]
            }
            self.completion?(options)
        }
    }
}

extension World123Helper: PrivateMenuSectionHelper {
    var titleKey: String {
        return "toolbar_title_world123"
    }
    var sidebarProductsTitle: String? { nil }
    var hasTitle: Bool { false }
    
    func getOptionsList(completion: @escaping (([PrivateSubmenuOptionRepresentable]) -> Void)) {
        self.completion = completion
        wrapperUpdated()
    }
    
    func titleForOption(_ option: PrivateSubmenuOptionRepresentable) -> String {
        guard let option = option as? World123Option else { return "" }
        return localized(option.titleKey)
    }
    
    func selected(option: PrivateSubmenuOptionRepresentable) {
        guard let option = option as? World123Option else {
            return
        }
        switch option.type {
        case .mundoSimulate:
            navigator.closeSideMenu()
            offerDelegate?.didSelectBanner(location: .MUNDO123_MENU_SIMULATE)
            navigator.setFirstViewControllerToGP()
        case .mundoWhatHave:
            navigator.closeSideMenu()
            offerDelegate?.didSelectBanner(location: .MUNDO123_MENU_WHATHAVE)
            navigator.setFirstViewControllerToGP()
        case .mundoBenefits:
            navigator.closeSideMenu()
            offerDelegate?.didSelectBanner(location: .MUNDO123_MENU_BENEFITS)
            navigator.setFirstViewControllerToGP()
        case .mundoSignUp:
            navigator.closeSideMenu()
            offerDelegate?.didSelectBanner(location: .MUNDO123_MENU_SIGNUP)
            navigator.setFirstViewControllerToGP()
        }
    }
}

extension World123Helper: LocationsResolver, PrivateSideMenuOfferDelegate {
    var useCaseProvider: UseCaseProvider {
        guard let presenter = presenter else { fatalError() }
        return presenter.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        guard let presenter = presenter else { fatalError() }
        return presenter.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        guard let presenter = presenter else { fatalError() }
        return presenter.genericErrorHandler
    }
    
    func didSelectBanner(location: PullOfferLocation) {
        offerDelegate?.didSelectBanner(location: location)
    }
    
    func executeOffer(action: OfferActionRepresentable?, offerId: String?, location: PullOfferLocationRepresentable?) {
        offerDelegate?.executeOffer(action: action, offerId: offerId, location: location)
    }
}
