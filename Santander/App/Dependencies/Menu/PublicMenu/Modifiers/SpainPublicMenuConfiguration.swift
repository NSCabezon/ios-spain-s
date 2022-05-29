import CoreFoundationLib
import UI

public struct SpainPublicMenuConfiguration {
    private let recoveryPassItem = PublicMenuOption(
        kindOfNode: KindOfPublicMenuNode.recoverPassword,
        titleKey: KindOfPublicMenuNode.recoverPasswordViewModel.titleKey,
        iconKey: KindOfPublicMenuNode.recoverPasswordViewModel.iconKey,
        action: .openURL(url: ""),
        event: PublicMenuPage.Action.recoveryKeys.rawValue,
        accessibilityIdentifier: KindOfPublicMenuNode.recoverPasswordViewModel.accessibility,
        type: .smallButton(style: SmallButtonType.defaultStyle())
    )
    
    private let getPassItem = PublicMenuOption(
        kindOfNode: KindOfPublicMenuNode.getMagic,
        titleKey: KindOfPublicMenuNode.getMagicViewModel.titleKey,
        iconKey: KindOfPublicMenuNode.getMagicViewModel.iconKey,
        action: .openURL(url: ""),
        event: PublicMenuPage.Action.getKeys.rawValue,
        accessibilityIdentifier: KindOfPublicMenuNode.getMagicViewModel.accessibility,
        type: .smallButton(style: SmallButtonType.defaultStyle())
    )
    
    private lazy var passItems = PublicMenuElement(top: self.recoveryPassItem, bottom: self.getPassItem)
    
    private let emergencyCallItem = PublicMenuOption(
        kindOfNode: KindOfPublicMenuNode.none,
        titleKey: KindOfPublicMenuNode.fraudViewModel.titleKey,
        iconKey: KindOfPublicMenuNode.fraudViewModel.iconKey,
        action: .toggleSideMenu,
        event: PublicMenuPage.Action.swipe.rawValue,
        accessibilityIdentifier: KindOfPublicMenuNode.fraudViewModel.accessibility,
        type: .bigCallButton
    )
    
    private let viewCallNow = PublicMenuOption(
        kindOfNode: KindOfPublicMenuNode.commercialSegment,
        titleKey: KindOfPublicMenuNode.callNowViewModel.titleKey,
        iconKey: KindOfPublicMenuNode.callNowViewModel.iconKey,
        action: .callPhone(number: ""),
        event: PublicMenuPage.Action.cardEmergency.rawValue,
        accessibilityIdentifier: KindOfPublicMenuNode.callNowViewModel.accessibility,
        type: .phonesButton(top: "", bottom: "")
    )
    
    private lazy var emergencyCallAndPhonesItem = PublicMenuElement(
        top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                              titleKey: "",
                              iconKey: "",
                              action: .none,
                              event: "",
                              accessibilityIdentifier: nil,
                              type: .flipButton(principalItem: emergencyCallItem,
                                                secondaryItem: viewCallNow,
                                                time: 2.0)),
        bottom: nil
    )
    
    private let ourProductsItem = PublicMenuElement(
        top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.enablePublicProducts,
                              titleKey: KindOfPublicMenuNode.publicProductsViewModel.titleKey,
                              iconKey: KindOfPublicMenuNode.publicProductsViewModel.iconKey,
                              action: .goToOurProducts,
                              event: PublicMenuPage.Action.products.rawValue,
                              accessibilityIdentifier: KindOfPublicMenuNode.publicProductsViewModel.accessibility,
                              type: .bigButton(style: BigButtonType().forPublicMenu())),
        bottom: nil
    )
    
    private let homeTipsItem = PublicMenuElement(
        top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                              titleKey: KindOfPublicMenuNode.homeTipsViewModel.titleKey,
                              iconKey: KindOfPublicMenuNode.homeTipsViewModel.iconKey,
                              action: .goToHomeTips,
                              event: PublicMenuPage.Action.tips.rawValue,
                              accessibilityIdentifier: KindOfPublicMenuNode.homeTipsViewModel.accessibility,
                              type: .smallButton(style: SmallButtonType.defaultStyle())),
        bottom: nil
    )
    
    private let mobileWebItem = PublicMenuElement(
        top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.mobileWeb,
                              titleKey: KindOfPublicMenuNode.mobileWebViewModel.titleKey,
                              iconKey: KindOfPublicMenuNode.mobileWebViewModel.iconKey,
                              action: .openURL(url: ""),
                              event: PublicMenuPage.Action.web.rawValue,
                              accessibilityIdentifier: KindOfPublicMenuNode.mobileWebViewModel.accessibility,
                              type: .bigButton(style: BigButtonType().forPublicMenu())),
        bottom: nil
    )
    
    private let optionBecomeClient = SelectOptionButtonModel(
        titleKey: "menu_link_newHighStart",
        action: .openURL(url: ""),
        node: .becomeClient,
        accessibilityIdentifier: "",
        event: PublicMenuPage.Action.newEntry.rawValue
    )
    
    private let optionRecoverProcess = SelectOptionButtonModel(
        titleKey: "menu_link_continueHigh",
        action: .openURL(url: ""),
        node: .recoverProcess,
        accessibilityIdentifier: "",
        event: PublicMenuPage.Action.continueEntry.rawValue
    )
    
    private lazy var becomeAndRecoverCell = PublicMenuOption(
        kindOfNode: KindOfPublicMenuNode.none,
        titleKey: "",
        iconKey: "",
        action: .none,
        event: "",
        accessibilityIdentifier: KindOfPublicMenuNode.selectOptionIdentifier,
        type: .selectOptionButton(options: [optionBecomeClient, optionRecoverProcess])
    )
    
    private let becomeAClientItem = PublicMenuOption(
        kindOfNode: KindOfPublicMenuNode.none,
        titleKey: KindOfPublicMenuNode.becomeAClientViewModel.titleKey,
        iconKey: KindOfPublicMenuNode.becomeAClientViewModel.iconKey,
        action: .toggleSideMenu,
        event: PublicMenuPage.Action.swipe.rawValue,
        accessibilityIdentifier: KindOfPublicMenuNode.becomeAClientViewModel.accessibility,
        type: .bigButton(style: BigButtonType().forPublicMenu())
    )
    
    private lazy var becomeClientAndRecoverItems = PublicMenuElement(
        top: PublicMenuOption(
            kindOfNode: KindOfPublicMenuNode.none,
            titleKey: "",
            iconKey: "",
            action: .none,
            event: "",
            accessibilityIdentifier: nil,
            type: .flipButton(principalItem: becomeAClientItem,
                              secondaryItem: becomeAndRecoverCell,
                              time: 6.0)),
        bottom: nil)
    
    private let atmItem = PublicMenuElement(
        top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.none,
                              titleKey: KindOfPublicMenuNode.atmViewModel.titleKey,
                              iconKey: KindOfPublicMenuNode.atmViewModel.iconKey,
                              action: .goToATMLocator,
                              event: PublicMenuPage.Action.branch.rawValue,
                              accessibilityIdentifier: KindOfPublicMenuNode.atmViewModel.accessibility,
                              type: .atm(bgImage: "btnAtmPublicMenu")),
        bottom: nil
    )
    
    private let stockholdersItem = PublicMenuElement(
        top: PublicMenuOption(kindOfNode: KindOfPublicMenuNode.enableStockholders,
                              titleKey: KindOfPublicMenuNode.stockholdersViewModel.titleKey,
                              iconKey: KindOfPublicMenuNode.stockholdersViewModel.iconKey,
                              action: .goToStockholders,
                              event: PublicMenuPage.Action.stockholders.rawValue,
                              accessibilityIdentifier: KindOfPublicMenuNode.stockholdersViewModel.accessibility,
                              type: .bigButton(style: BigButtonType().forPublicMenu())),
        bottom: nil
    )
    
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
