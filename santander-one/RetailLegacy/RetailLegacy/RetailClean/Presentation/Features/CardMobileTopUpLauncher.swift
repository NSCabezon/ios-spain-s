import Foundation

protocol CardMobileTopUpLauncher: class, CardOptionLauncherType {
}

extension CardMobileTopUpLauncher {
    
    func mobileTopUp(card: Card, delegate: ProductLauncherPresentationDelegate?) {
        let useCase = dependencies.useCaseProvider.setupMobileTopUp(input: SetupMobileTopUpUseCaseInput(card: card))
        delegate?.startLoading()
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { (result) in
            let operative = MobileTopUpOperative(dependencies: self.dependencies)
            let parameters: [OperativeParameter] = [card, result.mobileOperatorList, result.operativeConfig]
            delegate?.endLoading(completion: {
                self.navigatorLauncher.goToOperative(operative, withParameters: parameters, dependencies: self.dependencies)
            })
            
        }, onError: { (error) in
            delegate?.endLoading(completion: {
                delegate?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            })
        })
    }
    
}
