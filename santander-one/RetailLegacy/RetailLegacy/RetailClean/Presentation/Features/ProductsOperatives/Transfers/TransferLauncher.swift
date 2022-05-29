protocol TransferLauncher {
    func showTransfer(_ account: Account?, delegate: OperativeLauncherDelegate)
    func showUsualTransfer(_ account: Account?, favourite: Favourite, delegate: OperativeLauncherDelegate)
    func showReuseTransferFromAccount(_ account: Account?, iban: IBAN, beneficiary: String, delegate: OperativeLauncherDelegate)
    func didSelectTransferForFavorite(_ favourite: Favourite, account: Account?, enabledFavouritesCarrusel: Bool, delegate: OperativeLauncherDelegate)
}

extension TransferLauncher {
    func showTransfer(_ account: Account?, delegate: OperativeLauncherDelegate) {
        let operative = OnePayTransferOperative(dependencies: delegate.dependencies)
        let operativeData = OnePayTransferOperativeData(account: account)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
    
    func showUsualTransfer(_ account: Account?, favourite: Favourite, delegate: OperativeLauncherDelegate) {
        let operative = UsualTransferOperative(dependencies: delegate.dependencies)
        let operativeData = UsualTransferOperativeData(account: account, originTransfer: favourite)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
    
    func showReuseTransferFromAccount(_ account: Account?, iban: IBAN, beneficiary: String, delegate: OperativeLauncherDelegate) {
        let operative = OnePayTransferOperative(dependencies: delegate.dependencies)
        let operativeData = OnePayTransferOperativeData(account: account)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        operativeData.iban = iban
        operativeData.countryCode = iban.countryCode
        operativeData.name = beneficiary
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
    
    func didSelectTransferForFavorite(_ favourite: Favourite, account: Account?, enabledFavouritesCarrusel: Bool, delegate: OperativeLauncherDelegate) {
        let operative = OnePayTransferOperative(dependencies: delegate.dependencies)
        let operativeData = OnePayTransferOperativeData(account: account)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        var beneficiaryName = favourite.baoName
        if (beneficiaryName ?? "").isEmpty {
            beneficiaryName = favourite.alias
        }
        
        operativeData.iban = favourite.iban
        operativeData.countryCode = favourite.favouriteCountryCode
        operativeData.name = beneficiaryName
        operativeData.enabledFavouritesCarrusel = enabledFavouritesCarrusel
        operativeData.isEnableCountrySelection = false
        operativeData.isEnableCurrencySelection = false
        operativeData.isEnableEditingDestination = false
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
