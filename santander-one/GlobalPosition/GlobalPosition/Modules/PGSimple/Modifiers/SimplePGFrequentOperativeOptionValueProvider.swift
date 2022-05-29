//
//  SimplePGFrequentOperativeOptionValueProvider.swift
//  GlobalPosition
//
//  Created by José Norberto Hidalgo Romero on 20/4/22.
//

import Foundation
import CoreFoundationLib

struct SimplePGFrequentOperativeOptionValueProvider: PGFrequentOperativeOptionValueProviderProtocol {
    static let literalKey: [PGFrequentOperativeOption: String] = [
        .operate: "frequentOperative_button_operate",
        .sendMoney: "frequentOperative_label_sendMoney",
        .billTax: "frequentOperative_label_billTax",
        .customerCare: "frequentOperative_label_customerCare",
        .contract: "frequentOperative_button_contract",
        .marketplace: "frequentOperative_label_marketplace",
        .analysisArea: "frequentOperative_label_tips",
        .financialAgenda: "frequentOperative_label_financialAgenda",
        .suscription: "cardsOption_button_subscriptions",
        .investmentPosition: "frequentOperative_label_investmentPosition",
        .impruve: "frequentOperative_label_impruve",
        .stockholders: "frequentOperative_label_stockholders",
        .atm: "frequentOperative_label_atm",
        .personalArea: "frequentOperative_label_personalArea",
        .myManage: "frequentOperative_label_myManage",
        .addBanks: "frequentOperative_label_addBanks",
        .financialAnalysis: "frequentOperative_label_financialAnalysis",
        .financialTips: "frequentOperative_label_financialAdvice",
        .consultPin: "frequentOperative_button_pin",
        .financing: "frequentOperative_label_financing",
        .correosCash: "accountOption_button_correosCash",
        .officeAppointment: "otherOption_button_appointmentInOffice",
        .investmentsProposals: "accountOption_button_ordersSigning",
        .automaticOperations: "accountOption_button_automaticOperations",
        .carbonFootprint: "menu_link_fingerPrint"
    ]
    static let accessibilityKey: [PGFrequentOperativeOption: String] = [
        .operate: "frequentOperative_button_operate",
        .sendMoney: "voiceover_sendMoney",
        .billTax: "frequentOperative_label_billTax",
        .customerCare: "frequentOperative_label_customerCare",
        .contract: "frequentOperative_button_contract",
        .marketplace: "frequentOperative_label_marketplace",
        .analysisArea: "frequentOperative_label_tips",
        .financialAgenda: "frequentOperative_label_financialAgenda",
        .suscription: "cardsOption_button_subscriptions",
        .investmentPosition: "frequentOperative_label_investmentPosition",
        .impruve: "frequentOperative_label_impruve",
        .stockholders: "frequentOperative_label_stockholders",
        .atm: "frequentOperative_label_atm",
        .personalArea: "frequentOperative_label_personalArea",
        .myManage: "frequentOperative_label_myManage",
        .addBanks: "frequentOperative_label_addBanks",
        .financialAnalysis: "frequentOperative_label_financialAnalysis",
        .financialTips: "frequentOperative_label_financialAdvice",
        .consultPin: "frequentOperative_button_pin",
        .financing: "frequentOperative_label_financing",
        .correosCash: "accountOption_button_correosCash",
        .officeAppointment: "otherOption_button_appointmentInOffice",
        .investmentsProposals: "accountOption_button_ordersSigning",
        .automaticOperations: "accountOption_button_automaticOperations",
        .carbonFootprint: "menu_link_fingerPrint"
    ]
    static let iconKey: [PGFrequentOperativeOption: String] = [
        .operate: "oneIcnShortcuts",
        .sendMoney: "oneIcnSendMoney",
        .billTax: "oneIcnBill",
        .customerCare: "oneIcnHelpCenter",
        .contract: "oneIcnContract",
        .marketplace: "icnMarket",
        .analysisArea: "btnAnalysis",
        .financialAgenda: "icnDiaryFinancial",
        .suscription: "icnSubscriptionCards",
        .investmentPosition: "icn_investmentPosition",
        .impruve: "icn_helpUsSlidebar",
        .stockholders: "icnShareholders",
        .atm: "icnAtm",
        .personalArea: "icnSettingOperation",
        .myManage: "icn_my_manager",
        .addBanks: "icnBanks",
        .financialAnalysis: "btnFinancialAnalysis",
        .financialTips: "icnFinancialTips",
        .financing: "icnFinancing",
        .consultPin: "icnPin",
        .onePlan: "icnOne",
        .officeAppointment: "icnCalendar",
        .investmentsProposals: "icnSignatureOrders",
        .automaticOperations: "icnAutomaticOperations",
        .carbonFootprint: "icnCarbonFootprint"
    ]
    static let smartIconKey: [PGFrequentOperativeOption: String] = [
        .onePlan: "icnOneSmart"
    ]
    static let backgroungKey: [PGFrequentOperativeOption: String] = [:]
}
