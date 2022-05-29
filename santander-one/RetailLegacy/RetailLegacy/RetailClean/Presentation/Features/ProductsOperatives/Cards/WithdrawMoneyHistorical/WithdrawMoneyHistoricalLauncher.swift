import SANLegacyLibrary

protocol WithdrawMoneyHistoricalLauncher: class {
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var operativesNavigator: OperativesNavigatorProtocol { get }
    
    func launchWithDrawMoney(card: Card, cardDetail: CardDetail?, delegate: ProductLauncherPresentationDelegate)
}

extension WithdrawMoneyHistoricalLauncher {
    func launchWithDrawMoney(card: Card, cardDetail: CardDetail?, delegate: ProductLauncherPresentationDelegate) {
        delegate.startLoading()
        let useCase = dependencies.useCaseProvider.setupWithdrawMoneyHistoricalUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            delegate.endLoading(completion: {
                guard let thisLauncher = self else {
                    return
                }
                let operative = WithdrawMoneyHistoricalOperative(dependencies: thisLauncher.dependencies)
                let data = WithdrawMoneyHistoricalOperativeData(card: card, cardDetail: cardDetail)
                thisLauncher.operativesNavigator.goToOperative(operative, withParameters: [response.operativeConfig, data, response.signatureWithToken], dependencies: thisLauncher.dependencies)
            })
        }, onError: { error in
            delegate.endLoading(completion: {
                delegate.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            })
        })
    }
}
