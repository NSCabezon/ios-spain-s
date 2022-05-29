//
//  MockFinancialHealthDataProvider.swift
//  CoreTestData
//
//  Created by Luis Escámez Sánchez on 16/2/22.
//

import Foundation
import CoreDomain
import SANLegacyLibrary
import CoreFoundationLib

public class MockFinancialHealthDataProvider {
    public var summary: [MockFinancialHealthSummaryItem]!
    public var companies: [MockFinancialHealthCompany]!
    public var productsStatus: MockFinancialHealthProductsStatus!
    public var updateProductStatus: MockFinancialHealthProductsStatus!
    public var preferences: MockSetFinancialHealthPreferences!
    public var categoryDetail: [MockGetFinancialHealthSubcategory]!
    public var transactions: [MockGetFinancialHealthTransaction]!
}

// MARK: Summary
public struct MockFinancialHealthSummaryItem: FinancialHealthSummaryItemRepresentable, Codable {
    public var code: String?
    public var transactions: Int?
    public var total: Double?
    public var percentage: Int?
    public var currency: String?
    public var type: Int?
}

// MARK: Products
public struct MockFinancialHealthCompany: FinancialHealthCompanyRepresentable, Decodable {
    public var cardImageUrlPath: String?
    public var bankImageUrlPath: String?
    public var company: String?
    public var companyName: String?
    public var products: [MockFinancialHealthCompanyProduct]?
    public var companyProducts: [FinancialHealthCompanyProductRepresentable]? {
        self.products
    }
}

public struct MockFinancialHealthCompanyProduct: FinancialHealthCompanyProductRepresentable, Decodable {
    public var productTypeData: String?
    public var data: [MockFinancialHealthProductData]?
    public var productData: [FinancialHealthProductDataRepresentable]? {
        self.data
    }
}

public struct MockFinancialHealthProductData: Decodable {
    public var id: String?
    public var contractNumber:String?
    public var iban: String?
    public var contractCode: String?
    public var balance: String?
    public var currency: String?
    public var productName: String?
    public var lastUpdate: String?
    public var selected: Bool?
    public var cardType: String?
    public var cardNumber: String?
}

extension MockFinancialHealthProductData: FinancialHealthProductDataRepresentable {
    public var lastUpdateDate: Date? {
        lastUpdate?.toDate(dateFormat: "YYYYMMDD")
    }
}

// MARK: ProductsStatus
public struct MockFinancialHealthProductsStatus: Decodable {
    public var lastUpdatedRequestStringDate: String?
    public var lastUpdatedStringDate: String?
    public var oldestTransactionStringDate: String?
    public var status: String?
    public var entities: [MockFinancialHealthEntity]?
    
    enum CodingKeys: String, CodingKey {
        case lastUpdatedRequestStringDate = "lastUpdatedRequest"
        case lastUpdatedStringDate = "lastUpdated"
        case oldestTransactionStringDate = "oldestTransactionDate"
        case status = "status"
        case entities = "entities"
    }
}

extension MockFinancialHealthProductsStatus: FinancialHealthProductsStatusRepresentable {
    public var lastUpdatedRequestDate: Date? {
        guard let lastUpdatedRequestStringDate = lastUpdatedRequestStringDate else { return nil }
        return DateFormats.toDate(string: lastUpdatedRequestStringDate, output: .YYYYMMDD_HHmmssSSSSSS)
    }
    
    public var lastUpdatedDate: Date? {
        guard let lastUpdatedStringDate = lastUpdatedStringDate else { return nil }
        return DateFormats.toDate(string: lastUpdatedStringDate, output: .YYYYMMDD_HHmmssSSSSSS)
    }
    
    public var oldestTransactionDate: Date? {
        guard let oldestTransactionStringDate = oldestTransactionStringDate else { return nil }
        return DateFormats.toDate(string: oldestTransactionStringDate, output: .YYYYMMDD)
    }
    
    public var entitiesData: [FinancialHealthEntityRepresentable]? {
        return entities
    }
}

public struct MockFinancialHealthEntity: Decodable {
    public var company: String?
    public var lastUpdateStringDate: String?
    public var status: String?
    public var type: String?
    public var message: String?
}

extension MockFinancialHealthEntity: FinancialHealthEntityRepresentable {
    public var lastUpdateDate: Date? {
        guard let lastUpdateStringDate = lastUpdateStringDate else { return nil }
        return DateFormats.toDate(string: lastUpdateStringDate, output: .YYYYMMDD_HHmmssSSSSSS)
    }
}

// MARK: Preferences
public struct MockSetFinancialHealthPreferences: SetFinancialHealthPreferencesRepresentable, Decodable {
    public var preferencesProducts: [SetFinancialHealthPreferencesProductRepresentable]? {
        products
    }
    var products: [MockSetFinancialHealthPreferencesProduct]
    
    struct MockSetFinancialHealthPreferencesProduct: SetFinancialHealthPreferencesProductRepresentable, Decodable {
        var preferencesProductType: PreferencesProductType?
        var preferencesData: [SetFinancialHealthPreferencesProductDataRepresentable]? {
            data
        }
        var data: [MockSetFinancialHealthPreferencesProductData]
        
        struct MockSetFinancialHealthPreferencesProductData: SetFinancialHealthPreferencesProductDataRepresentable, Decodable {
            var productId: String? { id }
            var productSelected: Bool? { selected }
            var id: String
            var selected: Bool
        }
    }
}

// MARK: CategoryDetail
public struct MockGetFinancialHealthSubcategory: Codable {
    let name: String
    let amount: String
    let currency: String
    let categories: [MockGetFinancialHealthSubcategoryPeriod]
}

public struct MockGetFinancialHealthSubcategoryPeriod: Codable {
    let name: String
    let total: Double
    let dateFrom: String
    let dateTo: String
    let expected: String
    let currency: String
}

extension MockGetFinancialHealthSubcategory: GetFinancialHealthSubcategoryRepresentable {
    public var subcategory: FinancialHealthSubcategoryType? {
        switch name {
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
        case "Ahorro e inversión(Otros)":
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
    public var totalAmount: AmountRepresentable? {
        AmountRepresented(value: amount.stringToDecimal ?? 0.0, currencyRepresentable: CurrencyDTO.create(currency))
    }
    public var periods: [GetFinancialHealthSubcategoryPeriodRepresentable]? {
        categories
    }
}

extension MockGetFinancialHealthSubcategoryPeriod: GetFinancialHealthSubcategoryPeriodRepresentable {
    public var periodName: String? { name }
    public var periodAmount: AmountRepresentable? {
        AmountRepresented(value: Decimal(total), currencyRepresentable: CurrencyDTO.create(currency))
    }
    public var periodDateFrom: Date? { dateFrom.toDate(dateFormat: "YYYY-MM-DD") }
    public var periodDateTo: Date? { dateTo.toDate(dateFormat: "YYYY-MM-DD") }
    public var periodAmountExpected: AmountRepresentable? {
        AmountRepresented(value: expected.stringToDecimal ?? 0.0, currencyRepresentable: CurrencyDTO.create(currency))
    }
}

public struct MockGetFinancialHealthTransaction: Decodable {
    let type: String
    let productNumber: String?
    let date: String
    let total: String
    let description: String
    let currency: String
    let subCategory: String
    let category: String
    let productType: String
    let parentId: String
}

extension MockGetFinancialHealthTransaction: GetFinancialHealthTransactionRepresentable {
    public var transactionType: AnalysisAreaCategorization? { getTransactionType(type) }
    public var transactionProductNumber: String? { productNumber }
    public var transactionDate: Date? { date.toDate(dateFormat: "YYYY-MM-DD") }
    public var transactionTotal: AmountRepresentable? {
        AmountRepresented(value: total.stringToDecimal ?? 0.0, currencyRepresentable: CurrencyDTO.create(currency))
    }
    public var transactionDescription: String? { description }
    public var transactionSubCategory: FinancialHealthSubcategoryType? { getSubcategories(subCategory) }
    public var transactionCategory: AnalysisAreaCategoryType? { getCategory(category) }
    public var transactionProductType: CategoryProductType? { getProductType(productType) }
    public var transactionParentId: String? { parentId }
    
    func getTransactionType(_ type: String) -> AnalysisAreaCategorization? {
        switch type {
        case "0":
            return .expenses
        case "1":
            return .payments
        case "2":
            return .incomes
        default:
            return nil
        }
    }
    
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
        case "Ahorro e inversión(Otros)":
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
    
    func getCategory(_ category: String) -> AnalysisAreaCategoryType? {
        switch category {
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
            return nil
        }
    }
    
    func getProductType(_ type: String) -> CategoryProductType? {
        switch type {
        case "account":
            return .accounts
        case "creditCards":
            return .creditCards
        default:
            return nil
        }
    }
}
