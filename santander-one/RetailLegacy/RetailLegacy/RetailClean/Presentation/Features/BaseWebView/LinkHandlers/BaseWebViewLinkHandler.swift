import CoreFoundationLib
import Foundation
import WebKit
import WebViews

class BaseWebViewLinkHandler {
    enum BaseConstants {
        static let serializedTag = "[SERIALIZED]"
    }
    
    let configuration: WebViewConfiguration
    let useCaseHandler: UseCaseHandler
    let useCaseProvider: UseCaseProvider
    let errorHandler: UseCaseErrorHandler
    let stringLoader: StringLoader
    let dependencies: PresentationComponent
    weak var delegate: WebViewLinkHandlerDelegate?
    
    required init(configuration: WebViewConfiguration, useCaseHandler: UseCaseHandler, useCaseProvider: UseCaseProvider, useCaseErrorHandler: UseCaseErrorHandler, stringLoader: StringLoader, dependencies: PresentationComponent) {
        self.configuration = configuration
        self.useCaseHandler = useCaseHandler
        self.useCaseProvider = useCaseProvider
        self.errorHandler = useCaseErrorHandler
        self.stringLoader = stringLoader
        self.dependencies = dependencies
    }
    
    func downloadPdfWithUrl(_ url: URL?, method: HTTPMethodType, displayLoading: @escaping ((Bool) -> Void)) {
        guard let url = url else {
            return
        }
        self.cookies(for: url.host) { [weak self] cookies in
            let requestComponents = OrdinaryRequestComponents(url: url.absoluteString, params: [:], method: method, fields: nil, cookies: cookies, headers: self?.configuration.headers)
            self?.downloadPdf(with: requestComponents, displayLoading: displayLoading)
        }
    }
    
    func exitWebViewWhenBack() -> Bool {
        return delegate?.exitWebViewWhenBack() ?? true
    }
    
    func downloadPdfWithRequest(_ urlRequest: URLRequest?, displayLoading: @escaping ((Bool) -> Void)) {
        guard let urlRequest = urlRequest else {
            return
        }
        
        let requestComponents = NativeRequestComponents(nativeRequest: urlRequest)
        downloadPdf(with: requestComponents, displayLoading: displayLoading)
    }
    
    private func downloadPdf(with requestComponents: RequestComponents, displayLoading: @escaping ((Bool) -> Void)) {
        displayLoading(true)
        let input = GetPdfUseCaseInput(requestComponents: requestComponents, cache: self.configuration.isCachePdfEnabled)
        UseCaseWrapper(with: useCaseProvider.getPdfUseCase(input: input), useCaseHandler: useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (response) in
            displayLoading(false)
            self?.delegate?.displayPDF(with: response.pdfDocument)
        })
    }
    
    func selectPhoto(andPlaceInto javascriptFunction: String) {
        self.delegate?.openImageSelection(selected: { [weak self] imageData in
            PickerImageProcessing(imageData: imageData).processImage { serializedImage in
                self?.injectImage(javascriptFunction: javascriptFunction, serializedImage: serializedImage)
            }
        })
    }
    
    func selectCamera(andPlaceInto javascriptFunction: String) {
        self.delegate?.openCamera(selected: { [weak self] imageData in
            PickerImageProcessing(imageData: imageData).processImage { serializedImage in
                self?.injectImage(javascriptFunction: javascriptFunction, serializedImage: serializedImage)
            }
        })
    }
    
    func selectGallery(andPlaceInto javascriptFunction: String) {
        self.delegate?.openGallery(selected: { [weak self] imageData in
            PickerImageProcessing(imageData: imageData).processImage { [weak self] serializedImage in
                self?.injectImage(javascriptFunction: javascriptFunction, serializedImage: serializedImage)
            }
        })
    }
}

extension BaseWebViewLinkHandler {
    
    private var httpCookieStore: HTTPCookieStorage {
        return HTTPCookieStorage.shared
    }
    
    func cookies(for domain: String? = nil, completion: @escaping ([String: [HTTPCookiePropertyKey: Any]]) -> Void) {
        var cookieDict = [String: [HTTPCookiePropertyKey: Any]]()
        self.httpCookieStore.cookies?.forEach { cookie in
            if let domain = domain {
                if cookie.domain.contains(domain) {
                    cookieDict[cookie.name] = cookie.properties
                }
            } else {
                cookieDict[cookie.name] = cookie.properties
            }
        }
        completion(cookieDict)
    }
    
    private func injectImage(javascriptFunction:String, serializedImage: String?) {
        guard let serializedImage = serializedImage,
              let javascript = self.replace(inJavascriptFunction: javascriptFunction, serializedImage: serializedImage) else {
            return
        }
        self.delegate?.inject(javascript: javascript)
    }
    
    private func replace(inJavascriptFunction javascriptFunction: String, serializedImage: String) -> String? {
        return javascriptFunction.replace(BaseConstants.serializedTag, serializedImage)
    }
}
