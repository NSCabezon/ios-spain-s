import CoreFoundationLib
import Operative

protocol OpinatorLauncher: AnyObject {
    var dependencies: PresentationComponent { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    var baseWebViewNavigatable: BaseWebViewNavigatable { get }
}

extension OpinatorLauncher {
    func openOpinator(info: OpinatorInfoRepresentable, parameters: [PresentationOpinatorParameter: String]? = nil, backAction: WebViewBackAction = .automatic, onCompletion: ((Bool) -> Void)? = nil, onError: @escaping (String?) -> Void) {
        let opinatorManager = OpinatorManager(useCaseProvider: dependencies.useCaseProvider, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler)
        
        opinatorManager.getWebViewConfiguration(info: info, getParameterValue: { parameters?[$0] }, completion: { [weak self] result in
            switch result {
            case .success(let configuration):
                guard let launcher = self else {
                    return
                }
                launcher.baseWebViewNavigatable.goToWebView(with: configuration, linkHandler: nil, dependencies: launcher.dependencies, errorHandler: launcher.genericErrorHandler, backAction: backAction, didCloseClosure: onCompletion)
            case .failure:
                onError(nil)
            }
        })
    }
    
    func openOpinator(forRegularPage page: OpinatorPage, parametrizable: OpinatorParametrizable? = nil, backAction: WebViewBackAction = .automatic, onCompletion: ((Bool) -> Void)? = nil, onError: @escaping (String?) -> Void) {
        openOpinator(infoType: RegularOpinatorInfo.self, page: page, parametrizable: parametrizable, backAction: backAction, onCompletion: onCompletion, onError: onError)
    }
    
    func openOpinator(forGiveUpPage page: OpinatorPage, parametrizable: OpinatorParametrizable? = nil, backAction: WebViewBackAction = .automatic, onCompletion: ((Bool) -> Void)? = nil, onError: @escaping (String?) -> Void) {
        openOpinator(infoType: GiveUpOpinatorInfo.self, page: page, parametrizable: parametrizable, backAction: backAction, onCompletion: onCompletion, onError: onError)
    }
    
    private func openOpinator<T: OpinatorInfo>(infoType: T.Type, page: OpinatorPage, parametrizable: OpinatorParametrizable? = nil, backAction: WebViewBackAction = .automatic, onCompletion: ((Bool) -> Void)? = nil, onError: @escaping (String?) -> Void) {
        let opinatorManager = OpinatorManager(useCaseProvider: dependencies.useCaseProvider, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler)
        let parameters = parametrizable?.parameters
        opinatorManager.getWebViewConfiguration(infoType: infoType, forPage: page, getParameterValue: { parameters?[$0] }, completion: { [weak self] result in
            switch result {
            case .success(let configuration):
                guard let launcher = self else {
                    return
                }
                launcher.baseWebViewNavigatable.goToWebView(with: configuration, linkHandler: nil, dependencies: launcher.dependencies, errorHandler: launcher.genericErrorHandler, backAction: backAction, didCloseClosure: onCompletion)
            case .failure:
                onError(nil)
            }
        })
    }
}
