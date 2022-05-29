//
//  PublicMenuRepositoryMock.swift
//  Menu
//
//  Created by alvola on 16/12/2021.
//

import Foundation
import OpenCombine
import CoreFoundationLib

public struct PublicMenuRepositoryMock: PublicMenuRepository {
    public init() {}
    public func getPublicMenuConfiguration() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        let menuItemMock = MenuItemMock()
        return Just(menuItemMock.items).eraseToAnyPublisher()
    }
}

public struct SelectOptionButtonModel: SelectOptionButtonModelRepresentable {
    public var titleKey: String
    public var action: PublicMenuAction
    public var event: String
    public var node: KindOfPublicMenuNode
    public var accessibilityIdentifier: String?
}

private struct PublicMenuOption: PublicMenuOptionRepresentable {
    var kindOfNode: KindOfPublicMenuNode
    var titleKey: String
    var iconKey: String
    var action: PublicMenuAction
    var event: String
    var accessibilityIdentifier: String?
    var type: PublicMenuOptionType

    init() {
        self.kindOfNode = .none
        self.titleKey = ""
        self.iconKey = ""
        self.action = .none
        self.event = ""
        self.accessibilityIdentifier = nil
        self.type = .bigCallButton
    }

    init(kindOfNode: KindOfPublicMenuNode,
         titleKey: String,
         iconKey: String,
         action: PublicMenuAction,
         accessibilityIdentifier: String?,
         type: PublicMenuOptionType) {
        self.kindOfNode = kindOfNode
        self.titleKey = titleKey
        self.iconKey = iconKey
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.event = ""
        self.type = type
    }
}

private struct PublicMenuElement: PublicMenuElementRepresentable {
    var top: PublicMenuOptionRepresentable?
    var bottom: PublicMenuOptionRepresentable?
}

private struct MenuItemMock {
    
    private let recoveryPassItem = PublicMenuOption(kindOfNode: KindOfPublicMenuNode.recoverPassword,
                                                    titleKey: KindOfPublicMenuNode.recoverPasswordViewModel.titleKey,
                                                    iconKey: KindOfPublicMenuNode.recoverPasswordViewModel.iconKey,
                                                    action: .openURL(url: ""),
                                                    accessibilityIdentifier: KindOfPublicMenuNode.recoverPasswordViewModel.accessibility,
                                                    type: .bigCallButton)
    
    private let getPassItem = PublicMenuOption(kindOfNode: KindOfPublicMenuNode.getMagic,
                                               titleKey: KindOfPublicMenuNode.getMagicViewModel.titleKey,
                                               iconKey: KindOfPublicMenuNode.getMagicViewModel.iconKey,
                                               action: .openURL(url: ""),
                                               accessibilityIdentifier: nil,
                                               type: .bigCallButton)
    
    private lazy var passItems = PublicMenuElement(top: self.recoveryPassItem,
                                            bottom: self.getPassItem)
    
    private let emergencyCallItem = PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                                                     titleKey: KindOfPublicMenuNode.fraudViewModel.titleKey,
                                                     iconKey: KindOfPublicMenuNode.fraudViewModel.iconKey,
                                                     action: .toggleSideMenu,
                                                     accessibilityIdentifier: nil,
                                                     type: .bigCallButton)
    
    private let viewCallNow = PublicMenuOption(kindOfNode: KindOfPublicMenuNode.commercialSegment,
                                               titleKey: KindOfPublicMenuNode.mobileWebViewModel.titleKey,
                                               iconKey: KindOfPublicMenuNode.mobileWebViewModel.iconKey,
                                               action: .callPhone(number: ""),
                                               accessibilityIdentifier: nil,
                                               type: .phonesButton(top: "", bottom: ""))
    
    private lazy var emergencyCallAndPhonesItem = PublicMenuElement(top: viewCallNow,
                                                             bottom: nil)
    
    private let ourProductsItem = PublicMenuElement(top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.enablePublicProducts,
                                                                   titleKey: KindOfPublicMenuNode.publicProductsViewModel.titleKey,
                                                                   iconKey: KindOfPublicMenuNode.publicProductsViewModel.iconKey,
                                                                   action: .goToOurProducts,
                                                                   accessibilityIdentifier: KindOfPublicMenuNode.publicProductsViewModel.accessibility,
                                                                   type: .bigCallButton),
                                             bottom: nil)
    
    private let homeTipsItem = PublicMenuElement(top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                                                                titleKey: KindOfPublicMenuNode.homeTipsViewModel.titleKey,
                                                                iconKey: KindOfPublicMenuNode.homeTipsViewModel.iconKey,
                                                                action: .goToHomeTips,
                                                                accessibilityIdentifier: KindOfPublicMenuNode.homeTipsViewModel.accessibility,
                                                                type: .bigCallButton),
                                          bottom: nil)
    
    private let mobileWebItem = PublicMenuElement(top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.mobileWeb,
                                                                 titleKey: KindOfPublicMenuNode.mobileWebViewModel.titleKey,
                                                                 iconKey: KindOfPublicMenuNode.mobileWebViewModel.iconKey,
                                                                 action: .openURL(url: ""),
                                                                 accessibilityIdentifier: KindOfPublicMenuNode.mobileWebViewModel.accessibility,
                                                                 type: .bigCallButton),
                                           bottom: nil)
    
    private let optionBecomeClient = SelectOptionButtonModel(titleKey: "menu_link_newHighStart",
                                                             action: .openURL(url: ""),
                                                             event: "",
                                                             node: .becomeClient,
                                                             accessibilityIdentifier: "")
    private let optionRecoverProcess = SelectOptionButtonModel(titleKey: "menu_link_continueHigh",
                                                               action: .openURL(url: ""),
                                                               event: "",
                                                               node: .recoverProcess,
                                                               accessibilityIdentifier: "")
    private lazy var becomeAndRecoverCell = PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                                                             titleKey: "",
                                                             iconKey: "",
                                                             action: .none,
                                                             accessibilityIdentifier: nil,
                                                             type: .selectOptionButton(options: [optionBecomeClient, optionRecoverProcess]))
    private let becomeAClientItem = PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                                                     titleKey: KindOfPublicMenuNode.becomeAClientViewModel.titleKey,
                                                     iconKey: KindOfPublicMenuNode.becomeAClientViewModel.iconKey,
                                                     action: .toggleSideMenu,
                                                     accessibilityIdentifier: KindOfPublicMenuNode.becomeAClientViewModel.accessibility,
                                                     type: .bigCallButton)
    private lazy var becomeClientAndRecoverItems = PublicMenuElement(top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                                                                                    titleKey: "",
                                                                                    iconKey: "",
                                                                                    action: .none,
                                                                                    accessibilityIdentifier: nil,
                                                                                    type: .flipButton(principalItem: becomeAClientItem, secondaryItem: becomeAndRecoverCell, time: 6.0)),
                                                              bottom: nil)
    
    private let atmItem = PublicMenuElement(top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                                                           titleKey: KindOfPublicMenuNode.publicProductsViewModel.titleKey,
                                                           iconKey: KindOfPublicMenuNode.publicProductsViewModel.iconKey,
                                                           action: .goToATMLocator,
                                                           accessibilityIdentifier: KindOfPublicMenuNode.publicProductsViewModel.accessibility,
                                                           type: .atm(bgImage: "btnAtmPublicMenu")),
                                     bottom: nil)
    
    private let stockholdersItem = PublicMenuElement(top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.enableStockholders,
                                                                    titleKey: KindOfPublicMenuNode.stockholdersViewModel.titleKey,
                                                                    iconKey: KindOfPublicMenuNode.stockholdersViewModel.iconKey,
                                                                    action: .goToStockholders,
                                                                    accessibilityIdentifier: KindOfPublicMenuNode.stockholdersViewModel.accessibility,
                                                                    type: .bigCallButton),
                                              bottom: nil)
    
    private let rowNil = PublicMenuElement(top: nil, bottom: nil)
    
    public var items: [[PublicMenuElementRepresentable]] = []
    
    public init() {
        self.items = [
            [passItems, stockholdersItem],
            [atmItem],
            [becomeClientAndRecoverItems, emergencyCallAndPhonesItem],
            [ourProductsItem, mobileWebItem],
            [homeTipsItem]
        ]
    }
}

public extension KindOfPublicMenuNode {
    static let recoverPasswordViewModel = (titleKey: "menuPublic_link_lostKey", iconKey: "icnRecoverKey", accessibility: "btnRecoverKey")
    static let fraudViewModel = (titleKey: "menuPublic_link_emergency", iconKey: "icnBlockCard1", accessibility: "btnCardEmergency")
    static let mobileWebViewModel = (titleKey: "menuPublic_link_accessWeb", iconKey: "icnWorld2", accessibility: "btnWordWeb")
    static let getMagicViewModel = (titleKey: "menuPublic_link_getKey", iconKey: "icnGetYourKeys", accessibility: "btnRecoverKey")
    static let stockholdersViewModel = (titleKey: "menuPublic_link_santanderStockholders", iconKey: "icnEquities", accessibility: "btnStockholders")
    static let becomeAClientViewModel = (titleKey: "menuPublic_link_becomeClient", iconKey: "icnHandShake", accessibility: "btnHandshake")
    static let publicProductsViewModel = (titleKey: "menuPublic_link_ourProduct", iconKey: "icnBuyStock1", accessibility: "btnSuitcase")
    static let homeTipsViewModel = (titleKey: "menuPublic_link_discoverOurTips", iconKey: "icnAdvices", accessibility: "publicMenuBtnTips")
    static let prepaidLoginViewModel = (titleKey: "menuPublic_link_loginPrePaid", iconKey: "icnLoginPrepaid", accessibility: "")
    static let shareHoldersViewModel = (titleKey: "menuPublic_link_santanderStockholders", iconKey: "icnShareHoldersPublicMenu", accessibility: "")
    static let pricingConditions = (titleKey: "menuPublic_link_priceAndConditions", iconKey: "icnPricing", accessibility: "")
}
