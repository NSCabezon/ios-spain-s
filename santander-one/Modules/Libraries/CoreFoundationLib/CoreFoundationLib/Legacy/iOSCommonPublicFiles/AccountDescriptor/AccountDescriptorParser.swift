//
//  AccountDescriptorParser.swift
//  CoreFoundationLib
//
//  Created by Johann Casique on 20/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//

import Foundation

public struct AccountDescriptorParser: Parser {
    public init() {}
    
    public func serialize(_ responseString: String) -> AccountDescriptorArrayDTO? {
        var accountsArray: [AccountDescriptorDTO] = []
        var iberiaIconCardsArray: [AccountDescriptorDTO] = []
        var plansArray: [ProductAllianzDTO] = []
        var cardLabelscolors: [CardTextColorDTO] = []
        var chatOneProducts: [ProductRangeDescriptorDTO] = []
        var securityOneProducts: [ProductRangeDescriptorDTO] = []
        var paymentOneProducts: [ProductRangeDescriptorDTO] = []
        var vipOneProducts: [ProductRangeDescriptorDTO] = []
        var safeOneProducts: [ProductRangeDescriptorDTO] = []
        var accountGroupEntities: [GroupEntityDTO] = []
        var appIcons: [AppIconDTO] = []
        
        do {
            let document = try XML.parse(responseString)
            let accountsInfo = document["accounts_info"]
            
            accountsArray = accountsInfo["credit_accounts", "item"]
                .map { AccountDescriptorDTO(type: $0["type"].text,
                                            subType: $0["subtype"].text) }
            iberiaIconCardsArray = accountsInfo["IberiaIconCard", "TypeSubtype"]
                .map { AccountDescriptorDTO(type: $0["type"].text,
                                            subType: $0["subtype"].text) }
            plansArray = accountsInfo["plansAllianz", "productAllianz"]
                .map { ProductAllianzDTO(type: $0["type"].text,
                                         fromSubtype: $0["subtype_from"].text,
                                         toSubtype: $0["subtype_to"].text) }
            cardLabelscolors = accountsInfo["CardsColor", "CardColor"]
                .map{ CardTextColorDTO(cardCode: $0["CardCode"].text) }
            chatOneProducts = accountsInfo["productsOne", "productOneChat"]
                .map { ProductRangeDescriptorDTO(type: $0["type"].text,
                                                 fromSubtype: $0["subtype_from"].text,
                                                 toSubtype: $0["subtype_to"].text) }
            securityOneProducts = accountsInfo["productsOne", "productOneSecurity"]
                .map { ProductRangeDescriptorDTO(type: $0["type"].text,
                                                 fromSubtype: $0["subtype_from"].text,
                                                 toSubtype: $0["subtype_to"].text) }
            paymentOneProducts = accountsInfo["productsOne", "productOnePayment"]
                .map { ProductRangeDescriptorDTO(type: $0["type"].text,
                                                 fromSubtype: $0["subtype_from"].text,
                                                 toSubtype: $0["subtype_to"].text) }
            vipOneProducts = accountsInfo["productsOne", "productOneVIP"]
                .map { ProductRangeDescriptorDTO(type: $0["type"].text,
                                                 fromSubtype: $0["subtype_from"].text,
                                                 toSubtype: $0["subtype_to"].text) }
            safeOneProducts = accountsInfo["productsOne", "productOneSafe"]
            .map { ProductRangeDescriptorDTO(type: $0["type"].text,
                                             fromSubtype: $0["subtype_from"].text,
                                             toSubtype: $0["subtype_to"].text) }
            accountGroupEntities = accountsInfo["GroupEntities", "GroupEntityCode"]
                .map { GroupEntityDTO(entityCode: $0["EntityCode"].text) }
            appIcons = accountsInfo["AppIcon", "IconInfo"]
                .map { AppIconDTO(startDate: $0["StartDate"].text,
                                 endDate: $0["EndDate"].text,
                                 iconName: $0["IconName"].text) }
            
        } catch let error {
            print("❌ Failed to serialize XML ➡️ \(String(describing: AccountDescriptorParser.self)) with error \(error)")
        }
        return AccountDescriptorArrayDTO(accountsArray: accountsArray,
                                         iberiaIconCardsArray: iberiaIconCardsArray,
                                         plansArray: plansArray,
                                         cardsColorDTO: cardLabelscolors,
                                         chatProducts: chatOneProducts,
                                         securityOneProducts: securityOneProducts,
                                         paymentOneProducts: paymentOneProducts,
                                         vipOneProducts: vipOneProducts,
                                         safeOneProducts: safeOneProducts,
                                         accountGroupEntities: accountGroupEntities,
                                         appIcons: appIcons,
                                         xmlString: responseString)
    }
    
    public func deserialize(_ parseable: AccountDescriptorArrayDTO) -> String? {
        return parseable.xmlString
    }
}
