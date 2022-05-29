//
//  SavingTipsFactory.swift
//  Menu
//
//  Created by David Gálvez Alonso on 23/03/2020.
//

import CoreFoundationLib

public class SavingTipsFactory {
    public static func getSavingTipsActions() -> [SavingTipsActionType] {
        return SavingTipsActionType.allCases
    }
}

public struct SavingTipsAction {
    let title: String
    let largeTitle: String
    let description: String
    let imageName: String
    let accessibilityIdentifier: String
}

public enum SavingTipsActionType: String, CaseIterable {
    case monthlyExpenses
    case travels
    case supermarket
    case extraMoney
    case excessiveExpenses
        
    public func values() -> SavingTipsAction {
        let values: [SavingTipsActionType: SavingTipsAction] = [
            .monthlyExpenses: SavingTipsAction(title: "analysis_title_monthlyExpenses",
                                               largeTitle: "analysis_title_monthlyExpensesLarge",
                                               description: "analysis_text_monthlyExpensesLarge",
                                               imageName: "icnMonthlyExpenses",
                                               accessibilityIdentifier: "btnExpenses"),
            .travels: SavingTipsAction(title: "analysis_title_travels",
                                       largeTitle: "analysis_title_travelsLarge",
                                       description: "analysis_text_travelsLarge",
                                       imageName: "icnTravels",
                                       accessibilityIdentifier: "btnTravel"),
            .supermarket: SavingTipsAction(title: "analysis_title_supermarket",
                                           largeTitle: "analysis_title_supermarketLarge",
                                           description: "analysis_text_supermarketLarge",
                                           imageName: "icnSupermarket",
                                           accessibilityIdentifier: "btnSupermarket"),
            .extraMoney: SavingTipsAction(title: "analysis_title_extraMoney",
                                          largeTitle: "analysis_title_extraMoneyLarge",
                                          description: "analysis_text_extraMoneyLarge",
                                          imageName: "icnExtraMoney",
                                          accessibilityIdentifier: "btnExtraMoney"),
            .excessiveExpenses: SavingTipsAction(title: "analysis_title_excessiveExpenses",
                                                 largeTitle: "analysis_title_excessiveExpensesLarge",
                                                 description: "analysis_text_excessiveExpensesLarge",
                                                 imageName: "icnExcessiveExpenses",
                                                 accessibilityIdentifier: "btnExcessiveExpenses")
        ]
        
        return values[self] ?? SavingTipsAction(title: self.rawValue, largeTitle: "", description: "", imageName: "", accessibilityIdentifier: "")
    }
}
