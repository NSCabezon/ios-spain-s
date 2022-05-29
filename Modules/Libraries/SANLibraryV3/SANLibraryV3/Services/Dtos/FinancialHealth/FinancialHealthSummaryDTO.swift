//
//  FinancialHealthSummaryDTO.swift
//  SANLibraryV3
//
//  Created by Luis Escámez Sánchez on 15/2/22.
//

import Foundation
import CoreDomain

struct FinancialHealthSummaryItemDTO: Decodable {
    var code: String?
    var transactions: Int?
    var total: Double?
    var percentage: Int?
    var currency: String?
    var type: Int?
    
    private var fiancialHealthcategoryType: AnalysisAreaCategoryType {
        var string = code ?? "Otros gastos"
        switch string {
        case "Educación":
            return .education
        case "Transporte y automoción":
            return .transport
        case "Ocio":
            return .leisure
        case "Salud, Belleza y Bienestar":
            return .health
        case "Otros gastos":
            return .otherExpenses
        case "Ayudas":
            return .helps
        case "Cajeros y transferencias":
            return .atms
        case "Bancos y seguros":
            return .banksAndInsurance
        case "Casa y Hogar":
            return .home
        case "Gestiones personales y profesionales":
            return .managements
        case "Nóminas":
            return .payroll
        case "Comercio y Tiendas":
            return .purchasesAndFood
        case "Ahorro":
            return .saving
        case "Impuestos y tasas":
            return .taxes
        default:
            return .otherExpenses
        }
    }
}

extension FinancialHealthSummaryItemDTO: FinancialHealthSummaryItemRepresentable {
    var categoryType: AnalysisAreaCategoryType? {
        self.fiancialHealthcategoryType
    }
}
