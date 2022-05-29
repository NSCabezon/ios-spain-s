import PrivateMenu
import OpenCombine
import CoreFoundationLib

struct ESGetInsuranceDetailEnabledUseCase: GetInsuranceDetailEnabledUseCase {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        self.appConfigRepository = dependencies.resolve()
    }
    
    func fetchInsuranceDetailEnabled() -> AnyPublisher<Bool, Never> {
        return insuranceDetailEnabled
    }
}

private extension ESGetInsuranceDetailEnabledUseCase {
    var insuranceDetailEnabled: AnyPublisher<Bool, Never> {
        return appConfigRepository
            .value(for: "enabledInsuranceDetail", defaultValue: false)
            .eraseToAnyPublisher()
    }
}
