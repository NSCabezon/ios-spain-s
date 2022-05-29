protocol FundOperativeLauncher: class {
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var navigator: OperativesNavigatorProtocol { get }
    
    func launchTransfer(forFund fund: Fund, withProductList productList: [Fund]?, withDelegate delegate: ProductLauncherPresentationDelegate)
}

extension FundOperativeLauncher {
    func launchTransfer(forFund fund: Fund, withProductList productList: [Fund]?, withDelegate delegate: ProductLauncherPresentationDelegate) {
        
        let useCase = dependencies.useCaseProvider.setupFundTransferUseCase(input: SetupFundTransferUseCaseInput(fund: fund, productFundList: productList))
        delegate.startLoading()
        
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] result in
            guard let strongSelf = self else { return }
            
            let operative = FundTransferOperative(dependencies: strongSelf.dependencies)
            var parameters: [OperativeParameter] = [result.operativeConfig, fund, result.fundDetail, result.fundList]
            
            if let account = result.account {
                parameters.append(account)
            }
            
            delegate.endLoading {
                strongSelf.navigator.goToOperative(operative, withParameters: parameters, dependencies: strongSelf.dependencies)
            }
            }, onError: { _ in
                delegate.endLoading(completion: {
                    delegate.showAlertError(keyTitle: nil, keyDesc: "generic_alert_notAvailableTemporarilyOperation", completion: nil)
                })
        })
    }
}

//TODO: Cuando se pase la operativa entre fondos a el nuevo formato (deeplink) se aunaran FundOperativeDeepLinkLauncher y FundOperativeLauncher en un solo launcher (FundOperativeLauncher).
protocol FundOperativeDeepLinkLauncher {
    func showFundSubscription(fund: Fund?, delegate: OperativeLauncherDelegate)
}

extension FundOperativeDeepLinkLauncher {
    func showFundSubscription(fund: Fund?, delegate: OperativeLauncherDelegate) {
        let operative = FundSubscriptionOperative(dependencies: delegate.dependencies)
        let operativeData = FundSubscriptionOperativeData(fund: fund)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: fund == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
