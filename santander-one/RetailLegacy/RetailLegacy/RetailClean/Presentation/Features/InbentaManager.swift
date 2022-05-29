import CoreFoundationLib
import WebViews

class InbentaManager {
    let useCaseHandler: UseCaseHandler
    let useCaseProvider: UseCaseProvider
    let stringLoader: StringLoader
    
    var errorHandler: UseCaseErrorHandler?
    
    weak var delegate: WebViewLinkHandlerDelegate?
    
    init(useCaseHandler: UseCaseHandler, useCaseProvider: UseCaseProvider, stringLoader: StringLoader) {
        self.useCaseHandler = useCaseHandler
        self.useCaseProvider = useCaseProvider
        self.stringLoader = stringLoader
    }
    
    func getChatInbentaWebViewConfiguration(completion: @escaping (WebViewConfiguration?, StringErrorOutput?) -> Void) {
        UseCaseWrapper(with: useCaseProvider.getChatInbentaDataUseCase(), useCaseHandler: useCaseHandler, errorHandler: errorHandler, onSuccess: { response in
            let url = response.url
            let closingUrl = response.closeUrl
            let parameters = response.parameters
            completion(InbentaWebViewConfiguration(initialURL: url, bodyParameters: parameters, closingURLs: [closingUrl], webToolbarTitleKey: "toolbar_title_agentChat", pdfToolbarTitleKey: "toolbar_title_agentChat", pdfSource: .chatInbenta), nil)
        }, onError: { error in
            completion(nil, error)
        })
    }
    
    func getVirtualAssistantConfigurationWebView(completion: @escaping (WebViewConfiguration?, StringErrorOutput?) -> Void) {
        UseCaseWrapper(with: useCaseProvider.getVirtualAssitantDataUseCase(), useCaseHandler: useCaseHandler, errorHandler: errorHandler, onSuccess: { response in
            let url = response.url
            let closingUrl = response.closeUrl
            completion(VirtualAssistantWebViewConfiguration(initialURL: url, closingURLs: [closingUrl], webToolbarTitleKey: "toolbar_title_virtualAssistant", pdfToolbarTitleKey: nil), nil)
        }, onError: { error in
            completion(nil, error)
        })
    }
}
