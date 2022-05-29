//
//  GetFinancialHealthUseCase.swift
//  Menu
//
//  Created by David Gálvez Alonso on 21/04/2020.
//

import CoreFoundationLib

final class GetFinancialHealthUseCase: UseCase<Void, GetFinancialHealthUseCaseOkOutput, StringErrorOutput> {

    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFinancialHealthUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)

        let isInsuranceBalanceEnabled = appConfigRepository.getBool("enableSavingInsuranceBalance") ?? false
        let isCounterValueEnabled = appConfigRepository.getBool("enabledCounterValue") ?? false
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let accountDescriptorRepository: AccountDescriptorRepositoryProtocol = dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
        let accountDescriptors: [AccountDescriptorEntity] = accountDescriptorRepository.getAccountDescriptor()?.accountsArray.map({ AccountDescriptorEntity(type: $0.type ?? "", subType: $0.subType ?? "") }) ?? []
        let totalFinancialCushionAmount = getTotalFinanceAmount(globalPosition, isCounterValueEnabled: isCounterValueEnabled, accountDescriptors: accountDescriptors)
        let totalInvestmentsAmount = getTotalInvestmentsAmount(globalPosition, isCounterValueEnabled: isCounterValueEnabled, isInsuranceBalanceEnabled: isInsuranceBalanceEnabled)
        return UseCaseResponse.ok(GetFinancialHealthUseCaseOkOutput(financialCushionAmount: totalFinancialCushionAmount,
                                                                    investmentsAmount: totalInvestmentsAmount))
    }
}

private extension GetFinancialHealthUseCase {
    func getTotalFinanceAmount(_ globalPosition: GlobalPositionWithUserPrefsRepresentable, isCounterValueEnabled: Bool, accountDescriptors: [AccountDescriptorEntity]) -> Decimal? {
        var total: Decimal = 0
        if isCounterValueEnabled {
            total += globalPosition.accounts.totalOfVisibles(value: { $0.getCounterValueAmountValue()}, where: {$0.isAccountHolder()})
            total += globalPosition.cards.totalOfVisibles(value: { $0.dataDTO?.availableAmount?.value ?? $0.dataDTO?.currentBalance?.value }, where: { $0.isPrepaidCard && $0.isCardContractHolder})
        } else {
            total += globalPosition.accounts.totalOfVisibles(value: { $0.availableAmount?.value }, where: {$0.dto.currency?.currencyType == CoreCurrencyDefault.default })
            total += globalPosition.cards.totalOfVisibles(value: { $0.dataDTO?.availableAmount?.value ?? $0.dataDTO?.currentBalance?.value }, where: { $0.isPrepaidCard && $0.isCardContractHolder && $0.dataDTO?.currency?.currencyType == CoreCurrencyDefault.default })
        }
        total = total > 0 ? total : Decimal(0)
        return total
    }

    func getTotalInvestmentsAmount(_ globalPosition: GlobalPositionWithUserPrefsRepresentable, isCounterValueEnabled: Bool, isInsuranceBalanceEnabled: Bool) -> Decimal? {
        var total: Decimal = 0
        if isCounterValueEnabled {
            total += globalPosition.deposits.totalOfVisibles(with: \.dto.countervalueCurrentBalance)
            total += globalPosition.funds.totalOfVisibles(with: \.dto.countervalueAmount)
            total += globalPosition.pensions.totalOfVisibles(with: \.dto.counterValueAmount)
            total += globalPosition.stockAccounts.totalOfVisibles(with: \.dto.countervalueAmount)
        } else {
            total += globalPosition.deposits.totalOfVisibles(with: \.dto.balance)
            total += globalPosition.funds.totalOfVisibles(with: \.dto.valueAmount)
            total += globalPosition.pensions.totalOfVisibles(with: \.dto.valueAmount)
            total += globalPosition.stockAccounts.totalOfVisibles(with: \.dto.valueAmount)
        }
        if isInsuranceBalanceEnabled {
            let insurancesValue = globalPosition.insuranceSavings.totalOfVisibles(with: \.dto.importeSaldoActual)
            total += insurancesValue
        }
        total += globalPosition.managedPortfolios.totalOfVisibles(with: \.dto.consolidatedBalance)
        total += globalPosition.notManagedPortfolios.totalOfVisibles(with: \.dto.consolidatedBalance)

        return total
    }
}

struct GetFinancialHealthUseCaseOkOutput {
    let financialCushionAmount: Decimal?
    let investmentsAmount: Decimal?
}
