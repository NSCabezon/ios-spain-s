//
//  ReactiveGlobalPositionRepository.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/10/21.
//

import OpenCombine
import CoreDomain
import SANLegacyLibrary

public class DefaultGlobalPositionDataRepository: GlobalPositionDataRepository {
    private let bsanManagerProvider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol
    
    public init(dependencies: GlobalPositionDependenciesResolver) {
        self.bsanManagerProvider = dependencies.resolve()
        self.appRepository = dependencies.resolve()
    }

    public func getGlobalPosition() -> AnyPublisher<GlobalPositionDataRepresentable, Never> {
       Just(loadGlobalPosition())
            .eraseToAnyPublisher()
    }
    
    public func getMergedGlobalPosition() -> AnyPublisher<GlobalPositionAndUserPrefMergedRepresentable, Never> {
        let globalPosition = loadGlobalPosition()
        let userPreferences = appRepository.getUserPreferences(userId: globalPosition.userId ?? "")
        let globalPositionWithUserPreferece = merge(globalPosition: globalPosition, userPref: userPreferences)
        return Just(globalPositionWithUserPreferece)
            .eraseToAnyPublisher()
    }
}

extension DefaultGlobalPositionDataRepository: GlobalPositionWithUserPrefMergeable {}
private extension DefaultGlobalPositionDataRepository {
    
    func loadGlobalPosition() -> GlobalPositionDataRepresentable {
        let globalPosition = try? bsanManagerProvider
            .getBsanPGManager()
            .getGlobalPosition()
            .getResponseData()
        return globalPosition ?? EmptyGlobalPositionData()
    }
    
    struct EmptyGlobalPositionData: GlobalPositionDataRepresentable {
        let userId: String? = nil
        let loanRepresentables: [LoanRepresentable] = []
        let accountRepresentables: [AccountRepresentable] = []
        let stockAccountRepresentables: [StockAccountRepresentable] = []
        let cardRepresentables: [CardRepresentable] = []
        let depositRepresentables: [DepositRepresentable] = []
        let fundRepresentables: [FundRepresentable] = []
        let managedPortfoliosRepresentables: [PortfolioRepresentable] = []
        let notManagedPortfoliosRepresentables: [PortfolioRepresentable] = []
        let managedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] = []
        let notManagedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] = []
        let pensionRepresentables: [PensionRepresentable] = []
        let savingsInsuranceRepresentables: [InsuranceRepresentable] = []
        let protectionInsuranceRepresentables: [InsuranceRepresentable] = []
        let savingProductRepresentables: [SavingProductRepresentable] = []
        let userDataRepresentable: UserDataRepresentable? = nil
        let isPb: Bool? = nil
        let clientNameWithoutSurname: String? = nil
        let clientName: String? = nil
        let clientFirstSurnameRepresentable: String? = nil
        let clientSecondSurnameRepresentable: String? = nil
    }
}
