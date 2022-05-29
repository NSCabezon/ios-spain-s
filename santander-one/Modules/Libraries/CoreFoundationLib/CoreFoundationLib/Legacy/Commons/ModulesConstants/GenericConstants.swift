//
//  GenericConstants.swift
//  Commons
//
//  Created by Ignacio González Miró on 30/09/2020.
//

import Foundation

public struct GenericConstants {
    public static let relativeURl = "RWD/entidades/iconos"
    public static let iconBankExtension = ".png"
}

public struct InstallmentsConstants {
    public static let minimumInstallmentsNumber = 2
    public static let maximumInstallmentsNumber = 36
    public static let minimumFeeAmount: Decimal = 18.0
    public static let averageTermIndex: Int = 0
    public static let maximumTermIndex: Int = 1
    public static let allInOneNoInterestTerm = 3
    public static let allInOneCardUpperLimitQuote: Decimal = 1000
    public static let allInOneCardLowerLimitQuote: Decimal = 60
}

public struct StrategyPageTrackable: PageTrackable {
    public let strategy: TrackerPageAssociated?
    public let page: String

    public init(strategy: TrackerPageAssociated? = nil) {
        self.strategy = strategy
        self.page = strategy?.pageAssociated ?? ""
    }
}
