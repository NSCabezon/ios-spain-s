import Foundation

protocol PeriodicalContributionLauncher: class {
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var navigatorOperative: OperativesNavigatorProtocol { get }
}

extension PeriodicalContributionLauncher {
    func launch(forPension pension: Pension, withDelegate delegate: ProductLauncherPresentationDelegate) {
        delegate.startLoading()
        let setupUseCase = dependencies.useCaseProvider.setupPensionPeriodicalContributionUseCase(input: SetupPeriodicalContributionUseCaseInput(pension: pension))
        UseCaseWrapper(with: setupUseCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            
            guard let thisLauncher = self else { return }
            delegate.endLoading(completion: {
                guard result.allowOperative else {
                    delegate.showAlertError(keyTitle: nil, keyDesc: "plans_alert_activePeriodicContribution", completion: nil)
                    return
                }
                let operative = PeriodicalContributionOperative(dependencies: thisLauncher.dependencies)
                let configuration = ContributionConfiguration(periodicity: .monthly, startDate: Date().firstOfNextMonth(), revaluation: .none)
                var parameters: [OperativeParameter] = [pension, result.pensionInfoOperation, result.operativeConfig, configuration]
                if let account = result.account {
                    parameters.append(account)
                }
                
                thisLauncher.navigatorOperative.goToOperative( operative, withParameters: parameters, dependencies: thisLauncher.dependencies)
            })
            }, onError: { (error) in
                delegate.endLoading(completion: {
                    delegate.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                })
        })
    }
}
