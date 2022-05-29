import Foundation
import CoreFoundationLib

typealias BizumHomeConfigurationUseCaseAlias = UseCase<Void, BizumHomeConfigurationUseCaseOkOutput, StringErrorOutput>

final class BizumHomeConfigurationUseCase: BizumHomeConfigurationUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<BizumHomeConfigurationUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isEnableSendMoneyBizumNative = appConfigRepository.getBool(BizumConstants.isEnableSendMoneyBizumNative) == true
        let isEnableBizumQrOption = appConfigRepository.getBool(BizumConstants.isEnableBizumQrOption) == true
        return UseCaseResponse.ok(BizumHomeConfigurationUseCaseOkOutput(isEnableSendMoneyBizumNative: isEnableSendMoneyBizumNative,
                                                                        isEnableBizumQrOption: isEnableBizumQrOption))
    }
}

struct BizumHomeConfigurationUseCaseOkOutput {
    let isEnableSendMoneyBizumNative: Bool
    let isEnableBizumQrOption: Bool
}
