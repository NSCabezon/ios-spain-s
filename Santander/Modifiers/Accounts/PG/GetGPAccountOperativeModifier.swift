import CoreFoundationLib

final class GetGPAccountOperativeModifier {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension GetGPAccountOperativeModifier: GetGPAccountOperativeOptionProtocol {
    func getAllAccountOperativeActionType() -> [AccountOperativeActionTypeProtocol] {
        return [AccountOperativeActionType.transfer,
                AccountOperativeActionType.internalTransfer,
                AccountOperativeActionType.favoriteTransfer,
                BizumPGAccountOperativeOption(dependenciesResolver: dependenciesResolver),
                AccountOperativeActionType.donation,
                RequestMoneyPGAccountOperativeOption(dependenciesResolver: dependenciesResolver),
                AccountOperativeActionType.fxPay,
                AccountOperativeActionType.payBill,
                AccountOperativeActionType.payTax,
                AccountOperativeActionType.transferOfContracts,
                AccountOperativeActionType.changeDirectDebit,
                AccountOperativeActionType.cancelDirectDebit,
                AccountOperativeActionType.foreignExchange,
                AccountOperativeActionType.contractAccounts,
                AccountOperativeActionType.changeAlias,
                AccountOperativeActionType.settingsAlerts,
                AccountOperativeActionType.certificateOfOwnership
        ]
    }
    
    func getCountryAccountOperativeActionType(accounts: [AccountEntity]) -> [AccountOperativeActionTypeProtocol] {
        return [BizumPGAccountOperativeOption(dependenciesResolver: dependenciesResolver),
                RequestMoneyPGAccountOperativeOption(dependenciesResolver: dependenciesResolver)
        ]
    }
}
