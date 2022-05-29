import CoreFoundationLib

protocol BizumGetOrganizationsSuperUseCaseDelegate: class {
    func didFinishSuccessFully(_ operations: [BizumOrganizationEntity])
    func didFinishWithError(_ error: String?)
}

final class BizumGetOrganizationsSuperUseCase: SuperUseCase<BizumGetOrganizationsSuperUseCaseHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handler: BizumGetOrganizationsSuperUseCaseHandler
    weak var delegate: BizumGetOrganizationsSuperUseCaseDelegate? {
        get { return self.handler.delegate }
        set { self.handler.delegate = newValue }
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handler = BizumGetOrganizationsSuperUseCaseHandler(dependenciesResolver: self.dependenciesResolver)
        super.init(useCaseHandler: dependenciesResolver.resolve(), delegate: self.handler)
    }

    override func setupUseCases() {
        self.getOperations(1)
    }
}

private extension BizumGetOrganizationsSuperUseCase {
    func getOperations(_ page: Int) {
        let input = BizumGetOrganizationsUseCaseInput(page: page)
        let useCase = self.dependenciesResolver
            .resolve(for: BizumGetOrganizationsUseCase.self)
            .setRequestValues(requestValues: input)
        self.add(useCase, isMandatory: true, onSuccess: { [weak self] result in
            guard let self = self else { return }
            self.handler.organizations += result.organizations
            let nextPage = page + 1
            guard
                nextPage <= result.totalPages,
                result.isMoreData
            else { return }
            self.getOperations(nextPage)
        })
    }
}
