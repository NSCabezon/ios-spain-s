import CoreFoundationLib
protocol ManagerImageURLFetcher {}

extension ManagerImageURLFetcher {
    
    func requestManagerImageURL(using dependencies: PresentationComponent, completion: @escaping (String?) -> Void) {
        UseCaseWrapper(with: dependencies.useCaseProvider.getGetPersonalManagersUseCase(),
                       useCaseHandler: dependencies.useCaseHandler,
                       onSuccess: { (personalManager) in
                        
                        guard let firstManager = personalManager.managerList.managers.first,
                              let managerCode = firstManager.dto.codGest else {
                            completion(nil)
                            return
                        }
                        let stringURL = dependencies.imageLoader.buildImageAbsoluteURL(relativeUrl: "apps/SAN/imgGP/\(managerCode).jpg")?.absoluteString
                        completion(stringURL)
                       })
    }
    
}
