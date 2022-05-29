//
//  AnalysisAreaCategoryType.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 9/3/22.
//

import Foundation
import UI
import CoreFoundationLib
import UIOneComponents
import UIKit
import CoreDomain

extension AnalysisAreaCategorization {
    
    var iconKey: String {
        switch self {
        case .expenses:
            return "imgFire"
        case .payments:
            return "oneIcnShoppingCart"
        case .incomes:
            return "imgGasoline"
        }
    }
    
    var categorieKey: String {
        switch self {
        case .expenses: return "expenses"
        case .payments: return "payments"
        case .incomes: return "incomes"
        }
    }
    
    var prefixKey: String {
          switch self {
          case .expenses: return "analysis_expenses_"
          case .payments: return "analysis_payments_"
          case .incomes: return "analysis_incomes_"
          }
      }
}

extension AnalysisAreaCategoryType {
    
    init?(_ categoryCode: String?) {
        guard let code = categoryCode,
              let type = (AnalysisAreaCategoryType.allCases.first {
                  $0.matchKey.compare(code, options: .caseInsensitive) == .orderedSame }
              ) else { return nil }
        self = type
    }
    
    var literalKey: String {
        switch self {
        case .education:
            return localized("categorization_label_education")
        case .transport:
            return localized("categorization_label_transport")
        case .leisure:
            return localized("categorization_label_leisure")
        case .health:
            return localized("categorization_label_health")
        case .otherExpenses:
            return localized("categorization_label_otherExpenses")
        case .helps:
            return localized("categorization_label_helps")
        case .atms:
            return localized("categorization_label_atms")
        case .banksAndInsurance:
            return localized("categorization_label_banksAndInsurances")
        case .home:
            return localized("categorization_label_home")
        case .managements:
            return localized("categorization_label_managements")
        case .payroll:
            return localized("categorization_label_payroll")
        case .purchasesAndFood:
            return localized("categorization_label_purchasesAndFood")
        case .saving:
            return localized("categorization_label_saving")
        case .taxes:
            return localized("categorization_label_taxes")
        }
    }
    
    var key: String {
        switch self {
        case .education:
            return "categorization_label_education"
        case .transport:
            return "categorization_label_transport"
        case .leisure:
            return "categorization_label_leisure"
        case .health:
            return "categorization_label_health"
        case .otherExpenses:
            return "categorization_label_otherExpenses"
        case .helps:
            return "categorization_label_helps"
        case .atms:
            return "categorization_label_atms"
        case .banksAndInsurance:
            return "categorization_label_banksAndInsurances"
        case .home:
            return "categorization_label_home"
        case .managements:
            return "categorization_label_managements"
        case .payroll:
            return "categorization_label_payroll"
        case .purchasesAndFood:
            return "categorization_label_purchasesAndFood"
        case .saving:
            return "categorization_label_saving"
        case .taxes:
            return "categorization_label_taxes"
        }
    }
    
    var matchKey: String {
        switch self {
        case .education:
            return "Educación"
        case .transport:
            return "Transporte y automoción"
        case .leisure:
            return "Ocio"
        case .health:
            return "Salud, Belleza y Bienestar"
        case .otherExpenses:
            return "Otros gastos"
        case .helps:
            return "Ayudas"
        case .atms:
            return "Cajeros y transferencias"
        case .banksAndInsurance:
            return "Bancos y seguros"
        case .home:
            return "Casa y Hogar"
        case .managements:
            return "Gestiones personales y profesionales"
        case .payroll:
            return "Nóminas"
        case .purchasesAndFood:
            return "Comercio y Tiendas"
        case .saving:
            return "Ahorro"
        case .taxes:
            return "Impuestos y tasas"
        }
    }
    
    var iconKey: String {
        switch self {
        case .otherExpenses:
            return "oneIcnOthersCat"
        default:
            return "oneIcn\(self.rawValue.capitalizingFirstLetter() + "Cat")"
        }
    }
    
    public var darkColor: UIColor {
        switch self {
        case .education:
            return .oneBlueAnthracita
        case .transport:
            return .oneOrange
        case .leisure:
            return .oneTurquoise7Dark
        case .health:
            return .oneSantanderRed
        case .purchasesAndFood:
            return .oneGreen
        case .home:
            return .oneDarkPurple
        case .otherExpenses:
            return .oneDarkGrey
        case .atms:
            return .oneBlue5Dark
        case .managements:
            return .oneVermilion
        case .payroll:
            return .oneGreenEmerald
        case .taxes:
            return .oneLightBrown
        case .saving:
            return .onePink
        case .banksAndInsurance:
            return .oneAccessibleSky
        case .helps:
            return .oneViolet
        }
    }
    
    public var color: UIColor {
        switch self {
        case .education:
            return .oneMediumAntracita
        case .transport:
            return .oneMediumYellow
        case .leisure:
            return .oneFlTurquoise7
        case .health:
            return .oneFlSantander5
        case .purchasesAndFood:
            return .oneMediumGreen
        case .home:
            return .oneMediumPurple
        case .otherExpenses:
            return .oneMediumGrey
        case .atms:
            return .oneFlBlue5
        case .managements:
            return .oneMediumVermilion
        case .payroll:
            return .oneMediumGreenEmeral
        case .taxes:
            return .oneLightBrown3
        case .saving:
            return .oneMediumPink
        case .banksAndInsurance:
            return .oneFlMediumSky
        case .helps:
            return .oneMediumViolet
        }
    }
    
    public var lightColor: UIColor {
        switch self {
        case .education:
            return .oneLightAntracita
        case .transport:
            return .oneLightYellow
        case .leisure:
            return .oneLightTurquoise
        case .health:
            return .oneLightSantander
        case .purchasesAndFood:
            return .oneLightGreen
        case .home:
            return .oneLightPurple
        case .otherExpenses:
            return .oneLightGrey
        case .atms:
            return .oneLightBlue
        case .managements:
            return .oneLightVermilion
        case .payroll:
            return .oneLightGreenEmerald
        case .taxes:
            return .oneLightBrown2
        case .saving:
            return .oneLightPink
        case .banksAndInsurance:
            return .oneLightSky
        case .helps:
            return .oneLightViolet
        }
    }
    
    var subcategories: [FinancialHealthSubcategoryType] {
        switch self {
        case .education:
            return [.courses, .schoolUniversity, .academies, .ong]
        case .transport:
            return [.otherTransport, .gasStation, .parking, .tolls, .buyRentMaintenance, .publicTransport, .privateTransport]
        case .leisure:
            return [.entertainment, .restaurants, .hotels, .trips, .otherLeisure, .deliveryService]
        case .health:
            return [.pharmacy, .gym, .healthCare, .beautyProducts, .otherHealths]
        case .otherExpenses:
            return []
        case .helps:
            return [.unemploymentBenefit, .otherHelps, .pensions]
        case .atms:
            return [.otherAtms, .atms, .bizum, .atmTransfers]
        case .banksAndInsurance:
            return [.othersBank, .cards, .bankFees, .financingAndLoans, .bankTransfers, .remittance, .carInsurance, .houseInsurance, .lifeInsurance, .healthInsurance]
        case .home:
            return [.rent, .otherHouse, .phonesAndTV, .gas, .electricity, .water, .community, .heating, .security, .garbage, .domesticService]
        case .managements:
            return [.otherMangements, .unions, .management, .notary]
        case .payroll:
            return []
        case .purchasesAndFood:
            return [.otherPurchases, .superMarket, .fashion, .online, .food, .pets, .electronics, .lotteryBets, .vendingMachine, .bookshopAndStationary, .decorationFurnitures]
        case .saving:
            return [.savingPlan, .investments, .pensionPlans, .deposits, .otherSaving, .moneyBox, .savingInsurance, .interestDividend]
        case .taxes:
            return [.otherTaxes, .quotas, .taxes, .fees, .penalties]
        }
    }
}
