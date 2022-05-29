//
//  GetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 29/3/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public enum CompaniesProductsStatusAndSummaryUseCaseState {
    case idle
    case finishedCompanies([FinancialHealthProductRepresentable], [FinancialHealthCompanyRepresentable], [FinancialHealthCompanyRepresentable], Int, Int)
    case finishedCompaniesWithUnselectedProducts
    case finishedCompaniesWithError
    case finishedProductsStatusOK(FinancialHealthProductsStatusRepresentable)
    case finishedProductsStatusWithError
    case finishedProductsStatusWithOutdatedAlert
    case finishedSummary([FinancialHealthSummaryItemRepresentable])
    case finishedSummaryWithError
}

public protocol GetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase {
    mutating func fetchFinancialCompaniesProductsStatusAndSummaryPublisher(dateFromSummaryInput: Date, dateToSummaryInput: Date) -> AnyPublisher<CompaniesProductsStatusAndSummaryUseCaseState, Error>
}

public final class DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase {
    private let repository: FinancialHealthRepository
    private var anySubscriptions: Set<AnyCancellable> = []
    private var useCaseStateSubject = CurrentValueSubject<CompaniesProductsStatusAndSummaryUseCaseState, Error>(.idle)
    var state: AnyPublisher<CompaniesProductsStatusAndSummaryUseCaseState, Error>
    private let getCompaniesSubject = PassthroughSubject<Void, Never>()
    private let getProductsStatusSubject = PassthroughSubject<Void, Never>()
    private let getSummarySubject = PassthroughSubject<GetFinancialHealthSummaryRepresentable, Never>()
    private var summaryInput: GetFinancialHealthSummaryRepresentable = GetSummary(dateFrom: Date(), dateTo: Date())
    private var companiesWithProductsInfo: [FinancialHealthCompanyRepresentable] = []
    private var companiesWithProductsSelected: [FinancialHealthCompanyRepresentable] = []
    private var selectedProducts: [FinancialHealthProductRepresentable] = []
    private var accountsSelected = 0
    private var cardsSelected = 0
    var productsStatusTimer: Timer?
    var isAlreadySubscribed = true
    var productsAreUpdated = true {
        didSet {
            if isAlreadySubscribed {
                if productsAreUpdated {
                    getCompaniesSubject.send()
                } else {
                    getProductsStatusWithRetard()
                }
            }
        }
    }
    
    init(dependencies: AnalysisAreaCommonExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.state = useCaseStateSubject.eraseToAnyPublisher()
        subscribeCompanies()
        subscribeProductsStatus()
        subscribeSummary()
    }
}

extension DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase: GetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase {
    public func fetchFinancialCompaniesProductsStatusAndSummaryPublisher(dateFromSummaryInput: Date, dateToSummaryInput: Date) -> AnyPublisher<CompaniesProductsStatusAndSummaryUseCaseState, Error> {
        summaryInput = GetSummary(dateFrom: dateFromSummaryInput, dateTo: dateToSummaryInput, products: [])
        getCompaniesSubject.send()
        return state
    }
}

private extension DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase {
    func updateSummaryInput() {
        selectedProducts.removeAll()
        companiesWithProductsSelected = getCompaniesWithProductsSelected(companiesWithProductsInfo)
        accountsSelected = getCompaniesAccountsSelected(companiesWithProductsSelected)
        cardsSelected = getCompaniesCardsSelected(companiesWithProductsSelected)
        summaryInput = GetSummary(dateFrom: summaryInput.dateFrom, dateTo: summaryInput.dateTo, products: selectedProducts)
    }
    
    func getCompaniesWithProductsSelected(_ companies: [FinancialHealthCompanyRepresentable]) -> [FinancialHealthCompanyRepresentable] {
        let companiesFiltered = companies.filter {
            let companyProductsSelected = $0.companyProducts?.filter {
                let productsSelected = $0.productData?.filter {
                    $0.selected == true
                }
                return productsSelected?.isNotEmpty ?? false
            }
            return companyProductsSelected?.isNotEmpty ?? false
        }
        return companiesFiltered
    }
    
    func getCompaniesAccountsSelected(_ companies: [FinancialHealthCompanyRepresentable]) -> Int {
        var products: [Product] = []
        var accounts: [FinancialHealthProductDataRepresentable] = []
        let productType = ProductType(rawValue: ProductType.account.rawValue)
        companies.forEach {
            $0.companyProducts?.forEach {
                if $0.productTypeData == productType?.rawValue {
                    $0.productData?.forEach {
                        if $0.selected == true {
                            accounts.append($0)
                            products.append(Product(productType: productType?.rawValue, productId: $0.id))
                        }
                    }
                }
            }
        }
        self.selectedProducts.append(contentsOf: products)
        return accounts.count
    }
    
    func getCompaniesCardsSelected(_ companies: [FinancialHealthCompanyRepresentable]) -> Int {
        var products: [Product] = []
        var cards: [FinancialHealthProductDataRepresentable] = []
        let productType = ProductType(rawValue: ProductType.creditCard.rawValue)
        companies.forEach {
            $0.companyProducts?.forEach {
                if $0.productTypeData == productType?.rawValue {
                    $0.productData?.forEach {
                        if $0.selected == true {
                            cards.append($0)
                            products.append(Product(productType: productType?.rawValue, productId: $0.id))
                        }
                    }
                }
            }
        }
        self.selectedProducts.append(contentsOf: products)
        return cards.count
    }
    
    func getProductsStatusWithRetard() {
        productsStatusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { [weak self] timer in
            timer.invalidate()
            self?.getProductsStatusSubject.send()
        })
    }
}

// MARK: - Subscribers
private extension DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase {
    func subscribeCompanies() {
        companiesPublisher()
            .sink { [unowned self] completion in
                guard case .failure = completion else { return }
                useCaseStateSubject.send(.finishedCompaniesWithError)
            } receiveValue: { [unowned self] companies in
                companiesWithProductsInfo = companies
                updateSummaryInput()
                useCaseStateSubject.send(.finishedCompanies(selectedProducts,
                                                            companies,
                                                            companiesWithProductsSelected,
                                                            accountsSelected,
                                                            cardsSelected))
                getProductsStatusSubject.send()
                if companiesWithProductsInfo.isNotEmpty && selectedProducts.isNotEmpty {
                    getSummarySubject.send(summaryInput)
                } else {
                    useCaseStateSubject.send(.finishedCompaniesWithUnselectedProducts)
                }
            }.store(in: &anySubscriptions)
    }
    
    func subscribeProductsStatus() {
        self.productsStatusPublisher()
            .sink { [unowned self] completion in
                guard case .failure = completion else { return }
                productsStatusTimer?.invalidate()
                useCaseStateSubject.send(.finishedProductsStatusWithError)
            } receiveValue: { [unowned self] productsStatus in
                if productsStatus.status == "OK" || productsStatus.status == "KO" {
                    productsStatusTimer?.invalidate()
                    useCaseStateSubject.send(.finishedProductsStatusOK(productsStatus))
                    if companiesWithProductsInfo.isEmpty {
                        getCompaniesSubject.send()
                    } else if !productsAreUpdated {
                        useCaseStateSubject.send(.finishedProductsStatusWithOutdatedAlert)
                    }
                } else if productsStatus.status == "" {
                    isAlreadySubscribed = true
                    productsAreUpdated = false
                } else {
                    productsStatusTimer?.invalidate()
                    useCaseStateSubject.send(.finishedProductsStatusWithError)
                }
            }.store(in: &anySubscriptions)
    }
    
    func subscribeSummary() {
        self.summaryPuslisher()
            .sink { [unowned self] completion in
                guard case .failure = completion else { return }
                useCaseStateSubject.send(.finishedSummaryWithError)
            } receiveValue: { [unowned self] summary in
                useCaseStateSubject.send(.finishedSummary(summary))
            }.store(in: &anySubscriptions)
    }
}

// MARK: - Publishers
private extension DefaultGetAnalysisAreaCompaniesProductsStatusAndSummaryUseCase {
    func companiesPublisher() -> AnyPublisher<[FinancialHealthCompanyRepresentable], Error> {
        return getCompaniesSubject
            .map { [unowned self] _ in
                repository.getFinancialCompaniesWithProducts()
            }.switchToLatest()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func productsStatusPublisher() -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error> {
        return getProductsStatusSubject
            .map { [unowned self] _ in
                repository.getFinancialProductsStatus()
            }.switchToLatest()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func summaryPuslisher() -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error> {
        return getSummarySubject
            .map { [unowned self] summaryInput in
                repository.getFinancialSummary(products: summaryInput)
            }.switchToLatest()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}
