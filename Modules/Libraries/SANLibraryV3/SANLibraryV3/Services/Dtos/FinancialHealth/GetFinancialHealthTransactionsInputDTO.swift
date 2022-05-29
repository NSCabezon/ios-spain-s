//
//  GetFinancialHealthTransactionsInputDTO.swift
//  SANLibraryV3
//
//  Created by Miguel Bragado Sánchez on 5/4/22.
//

import Foundation
import CoreDomain

struct GetFinancialHealthTransactionsInputDTO: Encodable {
    let dateFrom: String
    let dateTo: String
    let page: String
    let pageSize: String
    var scale: String?
    var category: String?
    var subCategory: [String]?
    var type: String?
    let rangeFrom: Int?
    let rangeTo: Int?
    let text: String?
    let products: [GetFinancialHealthCategoryProductInputDTO]
    
    init?(_ representable: GetFinancialHealthTransactionsInputRepresentable) {
        self.dateFrom = (representable.dateFrom ?? Date()).toString(format: Date.TimeFormat.YYYYMMDD.rawValue)
        self.dateTo = (representable.dateTo ?? Date()).toString(format: Date.TimeFormat.YYYYMMDD.rawValue)
        self.page = representable.page
        self.pageSize = "30"
        self.products = representable.products.map { GetFinancialHealthCategoryProductInputDTO($0) }
        self.rangeFrom = representable.rangeFrom
        self.rangeTo = representable.rangeTo
        self.text = representable.text
        self.scale = getScale(representable.scale)
        self.category = getCategory(representable.category)
        self.subCategory = getSubcategories(representable.subCategory)
        self.type = "\(representable.type.rawValue)"
    }
    
    func getScale(_ type: TimeViewOptions) -> String {
        switch type {
        case .mounthly:
            return "mm"
        case .quarterly:
            return "qq"
        case .yearly:
            return "yy"
        case .customized:
            return "cc"
        }
    }
    
    func getCategory(_ type: AnalysisAreaCategoryType) -> String {
        switch type {
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
    
    func getSubcategories(_ subcategories: [FinancialHealthSubcategoryType]) -> [String] {
        return subcategories.map { subcategory in
            switch subcategory {
            case .otherTransport:
                return "Transporte y automoción (otros)"
            case .gasStation:
                return "Gasolineras"
            case .parking:
                return "Parking"
            case .tolls:
                return "Peajes"
            case .buyRentMaintenance:
                return "Compra, alquiler, mantenimiento y reparación de vehículo"
            case .publicTransport:
                return "Transporte público"
            case .privateTransport:
                return "Taxis, VTCs y vehículos compartidos"
            case .othersBank:
                return "Bancos y seguros (otros)"
            case .cards:
                return "Tarjetas"
            case .bankFees:
                return "Comisiones"
            case .financingAndLoans:
                return "Préstamos y productos financiados"
            case .bankTransfers:
                return "Traspasos"
            case .remittance:
                return "Remesas"
            case .carInsurance:
                return "Seguro coche y moto"
            case .houseInsurance:
                return "Seguro Hogar"
            case .lifeInsurance:
                return "Seguro de vida y decesos"
            case .healthInsurance:
                return "Seguro de salud"
            case .otherPurchases:
                return "Comercio y tiendas (otros)"
            case .superMarket:
                return "Supermercados y grandes almacenes"
            case .fashion:
                return "Moda, ropa, zapatos, accesorios y deporte"
            case .online:
                return "Grandes comercios online"
            case .food:
                return "Alimentación"
            case .pets:
                return "Mascotas"
            case .electronics:
                return "Electrónica"
            case .lotteryBets:
                return "Loterías, apuestas y recargas"
            case .vendingMachine:
                return "Máquinas de vending"
            case .bookshopAndStationary:
                return "Librería, papelería y revistas"
            case .decorationFurnitures:
                return "Decoración, mobiliario y mantenimiento del hogar"
            case .rent:
                return "Alquiler"
            case .otherHouse:
                return "Casa y hogar (otros)"
            case .phonesAndTV:
                return "Telefonía y televisión"
            case .gas:
                return "Gas"
            case .electricity:
                return "Electricidad"
            case .water:
                return "Agua"
            case .community:
                return "Comunidad"
            case .heating:
                return "Calefacción"
            case .security:
                return "Seguridad y alarmas"
            case .garbage:
                return "Basuras"
            case .domesticService:
                return "Servicio doméstico limpieza y tintoreria"
            case .unemploymentBenefit:
                return "Prestación por desempleo"
            case .otherHelps:
                return "Servicios sociales, ayudas y pensiones (otros)"
            case .pensions:
                return "Pensiones y subsidios"
            case .entertainment:
                return "Entretenimiento, actividades de ocio y tiempo libre"
            case .restaurants:
                return "Restaurantes, cafeterías y bares"
            case .hotels:
                return "Hoteles y alojamiento"
            case .trips:
                return "Viajes"
            case .otherLeisure:
                return "Ocio (otros)"
            case .deliveryService:
                return "Servicios a domicilio"
            case .pharmacy:
                return "Farmacia y óptica"
            case .gym:
                return "Gimnasio y clubes deportivos"
            case .healthCare:
                return "Clínicas y atención médica"
            case .beautyProducts:
                return "Productos y servicios de belleza"
            case .otherHealths:
                return "Salud, Belleza y Bienestar (otros)"
            case .otherTaxes:
                return "Impuestos y tasas (otros)"
            case .quotas:
                return "Cuotas"
            case .taxes:
                return "Impuestos"
            case .fees:
                return "Tasas"
            case .penalties:
                return "Multas"
            case .otherAtms:
                return "Cajeros y transferencias (otros)"
            case .atms:
                return "Cajeros"
            case .bizum:
                return "Bizum"
            case .atmTransfers:
                return "Transferencias"
            case .otherMangements:
                return "Gestiones personales y profesionales (otros)"
            case .parcel:
                return "Paquetería"
            case .unions:
                return "Sindicatos"
            case .management:
                return "Gestoría"
            case .notary:
                return "Notaria"
            case .courses:
                return "Cursos y certificaciones"
            case .schoolUniversity:
                return "Colegios, universidades y formación superior"
            case .academies:
                return "Academias"
            case .ong:
                return "Asociaciones, donaciones y ONGs"
            case .savingPlan:
                return "Plan de Ahorro"
            case .investments:
                return "Inversiones"
            case .pensionPlans:
                return "Planes de pensiones"
            case .deposits:
                return "Depósitos, valores y fondos"
            case .otherSaving:
                return "Ahorro e inversión (otros)"
            case .moneyBox:
                return "Hucha electrónica"
            case .savingInsurance:
                return "Seguro de ahorro"
            case .interestDividend:
                return "Intereses, dividendos y rendimientos"
            }
        }
    }
}
