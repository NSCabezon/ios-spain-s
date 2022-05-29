//
//  OfferBannerLocations.swift
//  UI
//
//  Created by Laura González on 10/09/2020.
//

public enum AnalysisAreaLocations: String, CaseIterable {
    case moneyPlan = "ANALYSIS_MONEYPLAN"
    case customTip = "ANALYSIS_CUSTOM_TIPS"
    case piggyBank = "ANALYSIS_ZONE_HUCHA"
}

public enum WhatsNewLocations: String, CaseIterable {
    case operationInfo = "WHATSNEW_OPERATION_INFO"
    case recobro = "WHATSNEW_RECOBRO"
    case agentMessage = "WHATSNEW_MESSAGE_OFFER"
    case preconceived = "WHATSNEW_PRECON"
    case noPreconceived = "WHATSNEW_NO_PRECON"
    case preconceivedRobinson = "PRE_CONCEDIDOS_ROBINSON_BIG"
}

public enum FinancingCardsLocations: String, CaseIterable {
    case financingCards = "ZF_FINANCING_CARDS"
}
