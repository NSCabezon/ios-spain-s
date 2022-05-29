//
//  SpainKindOfPublicMenuNode.swift
//  Santander
//
//  Created by Juan Jose Acosta González on 25/1/22.
//
import CoreFoundationLib

extension KindOfPublicMenuNode {
    static let recoverPasswordViewModel = (titleKey: "menuPublic_link_lostKey",
                                           iconKey: "icnRecoverKey",
                                           accessibility: "publicMenuRecoverKeys")
    
    static let fraudViewModel = (titleKey: "menuPublic_link_emergency",
                                 iconKey: "icnBlockCard1",
                                 accessibility:"publicMenuSoSCardsFront")
    
    static let mobileWebViewModel = (titleKey: "menuPublic_link_accessWeb",
                                    iconKey: "icnWorld2",
                                    accessibility: "publicMenuMobileWeb")
    
    static let getMagicViewModel = (titleKey: "menuPublic_link_getKey",
                                    iconKey: "icnGetYourKeys",
                                    accessibility: "publicMenuGetKeys")
    
    static let stockholdersViewModel = (titleKey: "menuPublic_link_santanderStockholders",
                                        iconKey: "icnEquities",
                                        accessibility: "publicMenuStockholders")
    
    static let becomeAClientViewModel = (titleKey: "menuPublic_link_becomeClient",
                                         iconKey: "icnHandShake",
                                         accessibility: "publicMenuBecomeCustomerFront")
    
    static let publicProductsViewModel = (titleKey: "menuPublic_link_ourProduct",
                                          iconKey: "icnBuyStock1",
                                          accessibility: "publicMenuOurProducts")
    
    static let homeTipsViewModel = (titleKey: "menuPublic_link_discoverOurTips",
                                    iconKey: "icnAdvices",
                                    accessibility: "publicMenuTips")
    
    static let atmViewModel = (titleKey: "menuPublic_link_checkAtm",
                               iconKey: "icnMapPointSan",
                               accessibility: "publicMenuNearbyATM")
    
    static let callNowViewModel = (titleKey: "general_button_callNow",
                                   iconKey: "icnPhoneWhite",
                                   accessibility: "publicMenuSoSCardsBack")
    
    static let selectOptionIdentifier = "publicMenuBecomeCustomerBack"
}
