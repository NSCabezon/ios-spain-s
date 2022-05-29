import CoreFoundationLib

final class BizumGetOrganizationsSuperUseCaseHandler {
    private let dependenciesResolver: DependenciesResolver
    weak var delegate: BizumGetOrganizationsSuperUseCaseDelegate?
    var organizations: [BizumOrganizationEntity]

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.organizations = []
    }
}

extension BizumGetOrganizationsSuperUseCaseHandler: SuperUseCaseDelegate {
    func onSuccess() {
        self.delegate?.didFinishSuccessFully(organizations)
    }

    func onError(error: String?) {
        self.delegate?.didFinishWithError(error)
    }
}
