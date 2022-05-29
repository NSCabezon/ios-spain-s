import CoreFoundationLib

protocol PublicProductsLauncher: class {
    func goToPublicProducts(delegate: PublicProductsLauncherDelegate, location: PullOfferLocation?)
}

protocol PublicProductsLauncherDelegate: class {
    var dependencies: PresentationComponent { get }
    var offerPresenter: PullOfferActionsPresenter { get }
}

extension PublicProductsLauncher {
    func goToPublicProducts(delegate: PublicProductsLauncherDelegate, location: PullOfferLocation?) {
        let useCase = delegate.dependencies.useCaseProvider.getSanflixContractInfoUseCase(input: SanflixContractInfoUseCaseInput(location: location))
        UseCaseWrapper(with: useCase, useCaseHandler: delegate.dependencies.useCaseHandler, onSuccess: { [weak self] response in
            self?.performNavigation(response.info, delegate: delegate)
        })
    }
    
    private func performNavigation(_ sanflixInfo: SanflixContractInfo, delegate: PublicProductsLauncherDelegate) {
        guard sanflixInfo.isEnabled, let sanflixOffer = sanflixInfo.offer else {
            delegate.dependencies.navigatorProvider.privateHomeNavigator.goToContractView()
            return
        }
        delegate.offerPresenter.executeOffer(action: sanflixOffer.action, offerId: sanflixOffer.id, location: sanflixInfo.location)
    }
}
