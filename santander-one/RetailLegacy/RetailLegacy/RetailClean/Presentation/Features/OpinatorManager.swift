import CoreFoundationLib
import Operative

public protocol OpinatorManagerModifier {
    func modifyOpinatorConfiguration(with configuration: OpinatorWebViewConfiguration) -> OpinatorWebViewConfiguration
}

enum OpinatorManagerResult {
    case success(WebViewConfiguration)
    case failure(OpinatorManagerError)
}

class OpinatorManager {
    struct Constants {
        static var closingUrls: [String] {
            return ["www.bancosantander.es"]
        }
    }
    
    let useCaseProvider: UseCaseProvider
    let useCaseHandler: UseCaseHandler
    let errorHandler: UseCaseErrorHandler
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler, errorHandler: UseCaseErrorHandler) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.errorHandler = errorHandler
    }
    
    func getWebViewConfiguration(info: OpinatorInfoRepresentable, getParameterValue: (PresentationOpinatorParameter) -> String?, completion: @escaping (OpinatorManagerResult) -> Void) {
        getParametersValues(parameters: info.params, presentationParameterClosure: getParameterValue) { parameters, _  in
            guard let parameters = parameters else {
                completion(.failure(.couldNotObtainParameters))
                return
            }
            self.getPath(info.endPoint) { path in
                completion(.success(OpinatorWebViewConfiguration(initialURL: path,
                                                                 queryParameters: parameters,
                                                                 closingURLs: Constants.closingUrls,
                                                                 webToolbarTitleKey: info.titleKey,
                                                                 pdfToolbarTitleKey: nil)))
            }
        }
    }
    
    func getWebViewConfiguration<T: OpinatorInfo>(infoType: T.Type, forPage page: OpinatorPage, getParameterValue: (PresentationOpinatorParameter) -> String?, completion: @escaping (OpinatorManagerResult) -> Void) {
        var factory = OpinatorInfoFactory<T>()
        guard let info = factory.info(ofPage: page) else {
            completion(.failure(.pageNotFound))
            return
        }
        
        getParametersValues(parameters: info.params, presentationParameterClosure: getParameterValue) { parameters, _  in
            guard let parameters = parameters else {
                completion(.failure(.couldNotObtainParameters))
                return
            }
            self.getPath(info.endPoint) { path in
                let configuration = OpinatorWebViewConfiguration(initialURL: path,
                                                                 queryParameters: parameters,
                                                                 closingURLs: Constants.closingUrls,
                                                                 webToolbarTitleKey: info.titleKey,
                                                                 pdfToolbarTitleKey: nil)
                let modifier = self.useCaseProvider.dependenciesResolver.resolve(forOptionalType: OpinatorManagerModifier.self)
                completion(.success(modifier?.modifyOpinatorConfiguration(with: configuration) ?? configuration))
            }
        }
    }
    
    private func getParametersValues(parameters: [OpinatorParameter], presentationParameterClosure: (PresentationOpinatorParameter) -> String?, completion: @escaping (_ values: [String: String]?, _ webViewTimer: Int?) -> Void) {
        var values: [String: String] = [:]
        var domainParamaters: [DomainOpinatorParameter] = []
        for parameter in parameters {
            if let domainParameter = parameter as? DomainOpinatorParameter {
                domainParamaters.append(domainParameter)
            } else if let presentationParameter = parameter as? PresentationOpinatorParameter {
                values[parameter.key] = presentationParameterClosure(presentationParameter)
            }
        }
        
        valuesFor(domainParameters: domainParamaters) { domainValues, webViewTimer  in
            if domainParamaters.isEmpty {
                completion(values, webViewTimer)
            } else {
                guard let domainValues = domainValues else {
                    completion(nil, nil)
                    return
                }
                for (key, value) in domainValues {
                    values[key] = value
                }
                completion(values, webViewTimer)
                
            }
        }
    }
    
    private func valuesFor(domainParameters: [DomainOpinatorParameter], completion: @escaping (_ values: [String: String]?, _ webViewTimer: Int?) -> Void) {
        let useCase = useCaseProvider.getOpinatorParametersValuesUseCase(requestValues: GetOpinatorParametersValuesUseCaseInput(parameters: domainParameters))
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: errorHandler, onSuccess: { result in
            completion(result.values, result.webViewTimer)
        }, onError: { _ in
            completion(nil, nil)
        })
    }
}

private extension OpinatorManager {
    func getPath(_ path: String, completion: @escaping (String) -> Void) {
        let useCase = self.useCaseProvider.getOpinatorUrlBaseUseCase()
        Scenario(useCase: useCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { result in
                completion(result.urlBase + path)
            }
    }
}

enum OpinatorManagerError: Error {
    case pageNotFound
    case couldNotObtainParameters
}
