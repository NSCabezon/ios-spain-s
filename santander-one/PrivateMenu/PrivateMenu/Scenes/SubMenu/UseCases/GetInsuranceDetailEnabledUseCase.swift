import OpenCombine
import CoreFoundationLib

public protocol GetInsuranceDetailEnabledUseCase {
    func fetchInsuranceDetailEnabled() -> AnyPublisher<Bool, Never>
}

struct DefaultGetInsuranceDetailEnabledUseCase { }

extension DefaultGetInsuranceDetailEnabledUseCase: GetInsuranceDetailEnabledUseCase {
    func fetchInsuranceDetailEnabled() -> AnyPublisher<Bool, Never> {
        return Just(true).eraseToAnyPublisher()
    }
}
