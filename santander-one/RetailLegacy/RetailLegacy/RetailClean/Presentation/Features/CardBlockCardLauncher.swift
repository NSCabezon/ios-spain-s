protocol CardBlockCardLauncher: AnyObject, CardOptionLauncherType {
    
}

extension CardBlockCardLauncher {
    
    func blockCard(_ product: Card, delegate: ProductLauncherPresentationDelegate?) {
        delegate?.startLoading()
        UseCaseWrapper(with: dependencies.useCaseProvider.setupBlockCardUseCase(input: SetupBlockCardUseCaseInput(card: product)), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            let operative = BlockCardOperative(dependencies: strongSelf.dependencies)
            let parameters: [OperativeParameter] = [result.operativeConfig, result.blockCard]
            
            delegate?.endLoading(completion: {
                strongSelf.navigatorLauncher.goToOperative(operative, withParameters: parameters, dependencies: strongSelf.dependencies)
            })
            }, onError: { (error) in
                delegate?.endLoading(completion: {
                    delegate?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                })
        })
    }
    
}
