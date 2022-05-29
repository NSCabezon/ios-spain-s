import CoreFoundationLib
import Bizum
import UI
import RetailLegacy

protocol BizumLauncher: AnyObject {
    func goToBizum(delegate: BizumLauncherDelegate)
}

protocol BizumLauncherDelegate: AnyObject {
    var dependencies: DependenciesResolver { get }
    func startLoading()
    func endLoading(completion: (() -> Void)?)
    func showError()
    var baseWebLauncher: BaseWebViewNavigatableLauncher { get }
    var bizumModifier: BizumModifierProtocol { get }
}

extension BizumLauncher {
    
    func goToBizum(delegate: BizumLauncherDelegate) {
        let useCase = BizumTypeUseCase(dependenciesResolver: delegate.dependencies)
        let input = BizumTypeUseCaseInput(type: .home)
        delegate.startLoading()
        Scenario(useCase: useCase, input: input)
            .execute(on: delegate.dependencies.resolve())
            .onSuccess { response in
                delegate.endLoading {
                    switch response {
                    case .native(let checkPayment):
                        let configuration = BizumCheckPaymentConfiguration(bizumCheckPaymentEntity: checkPayment)
                        let navigator = delegate.dependencies.resolve(for: BizumHomeNavigator.self)
                        navigator.gotoBizumHome(configuration)
                    case .web(let configuration):
                        delegate.bizumModifier.checkRegistration(completion: { isBizumRegistration in
                            if isBizumRegistration {
                                delegate.bizumModifier.goToRegistration()
                            } else {
                                //TODO: † ¿quitamos la parte web? ¿se podrá ir a la web aunque no estés registrado?
                                delegate.baseWebLauncher.goToWebView(configuration: configuration, type: .bizum, didCloseClosure: nil)
                            }
                        })
                    }
                }
            }
            .onError { _ in
                delegate.endLoading {
                    delegate.showError()
                }
            }
    }
}
