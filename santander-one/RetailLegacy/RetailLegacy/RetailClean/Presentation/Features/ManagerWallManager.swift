import CoreFoundationLib

class ManagerWallManager {
    
    private let useCaseHandler: UseCaseHandler
    private let useCaseProvider: UseCaseProvider
    
    var errorHandler: UseCaseErrorHandler?
    
    init(useCaseHandler: UseCaseHandler, useCaseProvider: UseCaseProvider) {
        self.useCaseHandler = useCaseHandler
        self.useCaseProvider = useCaseProvider
    }
    
    func getManagerWallConfigurationWebView(withManager manager: Manager, completion: @escaping (WebViewConfiguration?, StringErrorOutput?) -> Void) {
        let input = GetManagerWallDataUseCaseInput(manager: manager)
        UseCaseWrapper(
            with: useCaseProvider.getManagerWallDataUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { response in
                completion(response.configuration, nil)
            },
            onError: { error in
                completion(nil, error)
            }
        )
    }
}
