//
//  GetFinancialHealthCategoryDTO.swift
//  CoreDomain
//
//  Created by Miguel Bragado Sánchez on 29/3/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

struct GetFinancialHealthSubcategoryDTO: Codable {
    let name: String
    let amount: String
    let currency: String
    let categories: [GetFinancialHealthSubcategoryPeriodDTO]
}

struct GetFinancialHealthSubcategoryPeriodDTO: Codable {
    let name: String
    let total: Double
    let dateFrom: String
    let dateTo: String
    let expected: String
    let currency: String
}

extension GetFinancialHealthSubcategoryDTO: GetFinancialHealthSubcategoryRepresentable {
    var subcategory: FinancialHealthSubcategoryType? { self.getSubcategories(name) }
    var totalAmount: AmountRepresentable? {
        AmountRepresented(value: amount.stringToDecimal ?? 0.0, currencyRepresentable: CurrencyDTO.create(currency))
    }
    var periods: [GetFinancialHealthSubcategoryPeriodRepresentable]? { categories }
    
    func getSubcategories(_ subcategory: String) -> FinancialHealthSubcategoryType? {
        switch subcategory {
        case "Transporte y automoción (otros)":
            return .otherTransport
        case "Gasolineras":
            return .gasStation
        case "Parking":
            return .parking
        case "Peajes":
            return .tolls
        case "Compra, alquiler, mantenimiento y reparación de vehículo":
            return .buyRentMaintenance
        case "Transporte público":
            return .publicTransport
        case "Taxis, VTCs y vehículos compartidos":
            return .privateTransport
        case "Bancos y seguros (otros)":
            return .othersBank
        case "Tarjetas":
            return .cards
        case "Comisiones":
            return .bankFees
        case "Préstamos y productos financiados":
            return .financingAndLoans
        case "Traspasos":
            return .bankTransfers
        case "Remesas":
            return .remittance
        case "Seguro coche y moto":
            return .carInsurance
        case "Seguro Hogar":
            return .houseInsurance
        case "Seguro de vida y decesos":
            return .lifeInsurance
        case "Seguro de salud":
            return .healthInsurance
        case "Comercio y tiendas (otros)":
            return .otherPurchases
        case "Supermercados y grandes almacenes":
            return .superMarket
        case "Moda, ropa, zapatos, accesorios y deporte":
            return .fashion
        case "Grandes comercios online":
            return .online
        case "Alimentación":
            return .food
        case "Mascotas":
            return .pets
        case "Electrónica":
            return .electronics
        case "Loterías, apuestas y recargas":
            return .lotteryBets
        case "Máquinas de vending":
            return .vendingMachine
        case "Librería, papelería y revistas":
            return .bookshopAndStationary
        case "Decoración, mobiliario y mantenimiento del hogar":
            return .decorationFurnitures
        case "Alquiler":
            return .rent
        case "Casa y hogar (otros)":
            return .otherHouse
        case "Telefonía y televisión":
            return .phonesAndTV
        case "Gas":
            return .gas
        case "Electricidad":
            return .electricity
        case "Agua":
            return .water
        case "Comunidad":
            return .community
        case "Calefacción":
            return .heating
        case "Seguridad y alarmas":
            return .security
        case "Basuras":
            return .garbage
        case "Servicio doméstico limpieza y tintoreria":
            return .domesticService
        case "Prestación por desempleo":
            return .unemploymentBenefit
        case "Servicios sociales, ayudas y pensiones (otros)":
            return .otherHelps
        case "Pensiones y subsidios":
            return .pensions
        case "Entretenimiento, actividades de ocio y tiempo libre":
            return .entertainment
        case "Restaurantes, cafeterías y bares":
            return .restaurants
        case "Hoteles y alojamiento":
            return .hotels
        case "Viajes":
            return .trips
        case "Ocio (otros)":
            return .otherLeisure
        case "Servicios a domicilio":
            return .deliveryService
        case "Farmacia y óptica":
            return .pharmacy
        case "Gimnasio y clubes deportivos":
            return .gym
        case "Clínicas y atención médica":
            return .healthCare
        case "Productos y servicios de belleza":
            return .beautyProducts
        case "Salud, Belleza y Bienestar(otros)":
            return .otherHealths
        case "Impuestos y tasas (otros)":
            return .otherTaxes
        case "Cuotas":
            return .quotas
        case "Impuestos":
            return .taxes
        case "Tasas":
            return .fees
        case "Multas":
            return .penalties
        case "Cajeros y transferencias (otros)":
            return .otherAtms
        case "Cajeros":
            return .atms
        case "Bizum":
            return .bizum
        case "Transferencias":
            return .atmTransfers
        case "Gestiones personales y profesionales (otros)":
            return .otherMangements
        case "Paquetería":
            return .parcel
        case "Sindicatos":
            return .unions
        case "Gestoría":
            return .management
        case "Notaria":
            return .notary
        case "Cursos y certificaciones":
            return .courses
        case "Colegios, universidades y formación superior":
            return .schoolUniversity
        case "Academias":
            return .academies
        case "Asociaciones, donaciones y ONGs":
            return .ong
        case "Plan de Ahorro":
            return .savingPlan
        case "Inversiones":
            return .investments
        case "Planes de pensiones":
            return .pensionPlans
        case "Depósitos, valores y fondos":
            return .deposits
        case "Ahorro e inversión (otros)":
            return .otherSaving
        case "Hucha electrónica":
            return .moneyBox
        case "Seguro de ahorro":
            return .savingInsurance
        case "Intereses, dividendos y rendimientos":
            return .interestDividend
        default:
            return nil
        }
    }
}

extension GetFinancialHealthSubcategoryPeriodDTO: GetFinancialHealthSubcategoryPeriodRepresentable {
    var periodName: String? { name }
    var periodAmount: AmountRepresentable? {
        AmountRepresented(value: Decimal(total), currencyRepresentable: CurrencyDTO.create(currency))
    }
    var periodDateFrom: Date? {
        dateFrom.toDate(dateFormat: TimeFormat.yyyyMMdd.rawValue)
    }
    var periodDateTo: Date? {
        dateTo.toDate(dateFormat: TimeFormat.yyyyMMdd.rawValue)
    }
    var periodAmountExpected: AmountRepresentable? {
        AmountRepresented(value: expected.stringToDecimal ?? 0.0, currencyRepresentable: CurrencyDTO.create(currency))
    }
}
