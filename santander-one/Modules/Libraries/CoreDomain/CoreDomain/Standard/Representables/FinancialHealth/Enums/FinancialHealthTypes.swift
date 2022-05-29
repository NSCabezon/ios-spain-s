//
//  FinancialHealthTypes.swift
//  CoreDomain
//
//  Created by Miguel Bragado Sánchez on 30/3/22.
//

import Foundation

public enum AnalysisAreaCategorization: Int {
    case expenses = 0
    case payments = 1
    case incomes = 2
}

public enum AnalysisAreaCategoryType: String, CaseIterable, Codable {
    case education
    case transport
    case leisure
    case health
    case otherExpenses
    case helps
    case atms
    case banksAndInsurance
    case home
    case managements
    case payroll
    case purchasesAndFood
    case saving
    case taxes
}

public enum FinancialHealthSubcategoryType: CaseIterable {
    // Transport
    case otherTransport
    case gasStation
    case parking
    case tolls
    case buyRentMaintenance
    case publicTransport
    case privateTransport
    // Bank
    case othersBank
    case cards
    case bankFees
    case financingAndLoans
    case bankTransfers
    case remittance
    case carInsurance
    case houseInsurance
    case lifeInsurance
    case healthInsurance
    // purchasesAndFood
    case otherPurchases
    case superMarket
    case fashion
    case online
    case food
    case pets
    case electronics
    case lotteryBets
    case vendingMachine
    case bookshopAndStationary
    case decorationFurnitures
    // House
    case rent
    case otherHouse
    case phonesAndTV
    case gas
    case electricity
    case water
    case community
    case heating
    case security
    case garbage
    case domesticService
    // Helps
    case unemploymentBenefit
    case otherHelps
    case pensions
    // leisure
    case entertainment
    case restaurants
    case hotels
    case trips
    case otherLeisure
    case deliveryService
    // Health
    case pharmacy
    case gym
    case healthCare
    case beautyProducts
    case otherHealths
    // Taxes
    case otherTaxes
    case quotas
    case taxes
    case fees
    case penalties
    // Atm
    case otherAtms
    case atms
    case bizum
    case atmTransfers
    // Managements
    case otherMangements
    case unions
    case management
    case notary
    case parcel
    // Education
    case courses
    case schoolUniversity
    case academies
    case ong
    // Saves
    case savingPlan
    case investments
    case pensionPlans
    case deposits
    case otherSaving
    case moneyBox
    case savingInsurance
    case interestDividend
    
    var category: AnalysisAreaCategoryType {
        switch self {
        case .otherTransport, .gasStation, .parking, .tolls, .buyRentMaintenance, .publicTransport, .privateTransport:
            return .transport
        case .othersBank, .cards, .bankFees, .financingAndLoans, .bankTransfers, .remittance, .carInsurance, .houseInsurance, .lifeInsurance, .healthInsurance:
            return .banksAndInsurance
        case .otherPurchases, .superMarket, .fashion, .online, .food, .pets, .electronics, .lotteryBets, .vendingMachine, .bookshopAndStationary, .decorationFurnitures:
            return .purchasesAndFood
        case .rent, .otherHouse, .phonesAndTV, .gas, .electricity, .water, .community, .heating, .security, .garbage, .domesticService:
            return .home
        case .unemploymentBenefit, .otherHelps, .pensions:
            return .helps
        case .entertainment, .restaurants, .hotels, .trips, .otherLeisure, .deliveryService:
            return .leisure
        case .pharmacy, .gym, .healthCare, .beautyProducts, .otherHealths:
            return .health
        case .otherTaxes, .quotas, .taxes, .fees, .penalties:
            return .taxes
        case .otherAtms, .atms, .bizum, .atmTransfers:
            return .atms
        case .otherMangements, .unions, .management, .notary, .parcel:
            return .managements
        case .courses, .schoolUniversity, .academies, .ong:
            return .education
        case .savingPlan, .investments, .pensionPlans, .deposits, .otherSaving, .moneyBox, .savingInsurance, .interestDividend:
            return .saving
        }
    }
    
    public var literalKey: String {
        switch self {
        case .otherTransport:
            return "subcategory_label_other"
        case .gasStation:
            return "subcategory_label_gasStations"
        case .parking:
            return "subcategory_label_parking"
        case .tolls:
            return "subcategory_label_tolls"
        case .buyRentMaintenance:
            return "subcategory_label_vehicles"
        case .publicTransport:
            return "subcategory_label_publicTransport"
        case .privateTransport:
            return "subcategory_label_taxis"
        case .othersBank:
            return "subcategory_label_other"
        case .cards:
            return "subcategory_label_cards"
        case .bankFees:
            return "subcategory_label_commissions"
        case .financingAndLoans:
            return "subcategory_label_financing"
        case .bankTransfers:
            return "subcategory_label_switches"
        case .remittance:
            return "subcategory_label_remittance"
        case .carInsurance:
            return "subcategory_label_carAndMotorcycle"
        case .houseInsurance:
            return "subcategory_label_home"
        case .lifeInsurance:
            return "subcategory_label_lifeAndDeath"
        case .healthInsurance:
            return "subcategory_label_health"
        case .otherPurchases:
            return "subcategory_label_other"
        case .superMarket:
            return "subcategory_label_supermarkets"
        case .fashion:
            return "subcategory_label_fashion"
        case .online:
            return "subcategory_label_eCommerce"
        case .food:
            return "subcategory_label_feeding"
        case .pets:
            return "subcategory_label_pets"
        case .electronics:
            return "subcategory_label_electronics"
        case .lotteryBets:
            return "subcategory_label_lotteries"
        case .vendingMachine:
            return "subcategory_label_vendingMachines"
        case .bookshopAndStationary:
            return "subcategory_label_bookstore"
        case .decorationFurnitures:
            return "subcategory_label_furniture"
        case .rent:
            return "subcategory_label_rent"
        case .otherHouse:
            return "subcategory_label_other"
        case .phonesAndTV:
            return "subcategory_label_telephonyAndTv"
        case .gas:
            return "subcategory_label_gass"
        case .electricity:
            return "subcategory_label_electricity"
        case .water:
            return "subcategory_label_water"
        case .community:
            return "subcategory_label_community"
        case .heating:
            return "subcategory_label_heating"
        case .security:
            return "subcategory_label_security"
        case .garbage:
            return "subcategory_label_waste"
        case .domesticService:
            return "subcategory_label_services"
        case .unemploymentBenefit:
            return "subcategory_label_unemployment"
        case .otherHelps:
            return "subcategory_label_other"
        case .pensions:
            return "subcategory_label_allowances"
        case .entertainment:
            return "subcategory_label_leisureAndFreeTime"
        case .restaurants:
            return "subcategory_label_restaurants"
        case .hotels:
            return "subcategory_label_accommodation"
        case .trips:
            return "subcategory_label_travel"
        case .otherLeisure:
            return "subcategory_label_other"
        case .deliveryService:
            return "subcategory_label_homeServices"
        case .pharmacy:
            return "subcategory_label_pharmacyAndOptics"
        case .gym:
            return "subcategory_label_sports"
        case .healthCare:
            return "subcategory_label_medicalCare"
        case .beautyProducts:
            return "subcategory_label_beauty"
        case .otherHealths:
            return "subcategory_label_other"
        case .otherTaxes:
            return "subcategory_label_other"
        case .quotas:
            return "subcategory_label_quotas"
        case .taxes:
            return "subcategory_label_taxation"
        case .fees:
            return "subcategory_label_rates"
        case .penalties:
            return "subcategory_label_fines"
        case .otherAtms:
            return "subcategory_label_other"
        case .atms:
            return "subcategory_label_atm"
        case .bizum:
            return "subcategory_label_bizum"
        case .atmTransfers:
            return "subcategory_label_transfers"
        case .otherMangements:
            return "subcategory_label_other"
        case .unions:
            return "subcategory_label_tradeUnions"
        case .management:
            return "subcategory_label_agency"
        case .notary:
            return "subcategory_label_notary"
        case .courses:
            return "subcategory_label_courses"
        case .schoolUniversity:
            return "subcategory_label_education"
        case .academies:
            return "subcategory_label_academies"
        case .ong:
            return ""
        case .savingPlan:
            return "subcategory_label_savingsPlan"
        case .investments:
            return "subcategory_label_investments"
        case .pensionPlans:
            return "subcategory_label_pensionPlans"
        case .deposits:
            return "subcategory_label_equities"
        case .otherSaving:
            return "subcategory_label_other"
        case .moneyBox:
            return "subcategory_label_piggyBanks"
        case .savingInsurance:
            return "subcategory_label_savings"
        case .interestDividend:
            return "subcategory_label_profitability"
        case .parcel:
            return "subcategory_label_parcel"
        }
    }
}
