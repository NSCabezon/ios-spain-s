import Foundation
import CoreFoundationLib

public class GetBizumSplitExpensesStatusUseCase: UseCase<Void, GetBizumSplitExpensesStatusUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetBizumSplitExpensesStatusUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let appConfigKey = "enableSplitExpenseBizum"
        let isBizumSplitExpensesEnable = appConfigRepository.getBool(appConfigKey) ?? false
        return UseCaseResponse.ok(GetBizumSplitExpensesStatusUseCaseOkOutput(isBizumSplitExpensesEnabled: isBizumSplitExpensesEnable))
    }
}

public struct GetBizumSplitExpensesStatusUseCaseOkOutput {
    public let isBizumSplitExpensesEnabled: Bool
}
