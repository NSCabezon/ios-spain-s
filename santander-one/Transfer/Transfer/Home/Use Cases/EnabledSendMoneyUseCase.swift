import Foundation
import CoreFoundationLib

final class EnabledSendMoneyUseCase: UseCase<Void, EnabledSendMoneyUseCaseOkOutput, StringErrorOutput> {

    private let appConfig: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appConfig = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<EnabledSendMoneyUseCaseOkOutput, StringErrorOutput> {
        let output = EnabledSendMoneyUseCaseOkOutput(testFloatingButtonVisible: appConfig.getBool("enabledNewSendMoney") ?? false)
        return .ok(output)
    }
}

struct EnabledSendMoneyUseCaseOkOutput {
    public let testFloatingButtonVisible: Bool
}
