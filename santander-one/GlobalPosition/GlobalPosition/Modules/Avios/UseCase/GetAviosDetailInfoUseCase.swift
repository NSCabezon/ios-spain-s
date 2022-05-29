import CoreFoundationLib
import SANLegacyLibrary

typealias GetAviosDetailInfoUseCaseAlias = UseCase<Void, GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>

final class GetAviosDetailInfoUseCase: GetAviosDetailInfoUseCaseAlias {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput> {
        let response = try bsanManagersProvider.getBsanAviosManager().getAviosDetail()
        guard response.isSuccess(), let responseData = try response.getResponseData() else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }
        return .ok(GetAviosDetailInfoUseCaseOkOutput(detail: AviosDetail(responseData)))
    }
}

struct GetAviosDetailInfoUseCaseOkOutput {
    let detail: AviosDetail
}
