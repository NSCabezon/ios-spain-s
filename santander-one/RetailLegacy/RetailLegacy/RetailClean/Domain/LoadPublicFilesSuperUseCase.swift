//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class LoadPublicFilesSuperUseCaseErrorHandler: CustomUseCaseErrorHandler {
    
    private weak var delegate: SuperUseCaseDelegate?
    
    init(_ delegate: SuperUseCaseDelegate?) {
        self.delegate = delegate
    }
    
    func unauthorized() {
        delegate?.onError(error: nil)
    }
    
    func showNetworkUnavailable() {
        delegate?.onError(error: nil)
    }
    
    func showGenericError() {
        delegate?.onError(error: nil)
    }
}

class LoadPublicFilesSuperUseCase<Delegate: SuperUseCaseDelegate>: SuperUseCase<Delegate, LoadPublicFilesSuperUseCaseErrorHandler> {
    
    override func setupUseCases() {
        add(useCaseProvider.getSetupPublicFilesUseCase()) { [weak self, useCaseProvider] in
            self?.add(useCaseProvider.getLoadAppConfigDomainCase(), isMandatory: false)
            self?.add(useCaseProvider.getUserSegmentsCase(), isMandatory: false)
            self?.add(useCaseProvider.getLoadPullOfferRules(), isMandatory: false)
            self?.add(useCaseProvider.getLoadPullOfferOffers(), isMandatory: false)
            self?.add(useCaseProvider.getLoadPullOffersConfigUseCase(), isMandatory: false)
            self?.add(useCaseProvider.getLoadAccountDescriptorDomainCase(), isMandatory: false)
            self?.add(useCaseProvider.getLoadSepaInfoUseCase(), isMandatory: false)
            self?.add(useCaseProvider.getFaqsUseCase(), isMandatory: false)
            self?.add(useCaseProvider.getLoadServicesForYouCase(), isMandatory: false)
            self?.add(useCaseProvider.getLoadLoadingTipsUseCase(), isMandatory: false)
            self?.addAdditionalPublicFilesUseCases()
        }
    }
    
    func addAdditionalPublicFilesUseCases() {
        guard let useCases = useCaseProvider.getAdditionalPublicFilesUseCasesIfPresent() else { return }
        useCases.forEach { self.add($0.useCase, isMandatory: $0.isMandatory) }
    }
}
