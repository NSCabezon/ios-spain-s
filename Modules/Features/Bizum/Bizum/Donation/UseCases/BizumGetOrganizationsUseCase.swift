import Foundation
import CoreFoundationLib
import SANLibraryV3
import SANLegacyLibrary

public final class BizumGetOrganizationsUseCase: UseCase<BizumGetOrganizationsUseCaseInput, BizumGetOrganizationsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: BizumGetOrganizationsUseCaseInput) throws -> UseCaseResponse<BizumGetOrganizationsUseCaseOkOutput, StringErrorOutput> {
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let params = BizumGetOrganizationsInputParams(pageNumber: requestValues.page)
        let response = try provider.getBSANBizumManager().getOrganizations(params)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let message = try response.getErrorMessage()
            return .error(StringErrorOutput(message))
        }
        let isMoreData = data.moreData == 1
        let organizations = data.organizations.map { BizumOrganizationEntity($0) }
        let totalPages = data.pagesTotal ?? BizumConstants.maxTotalPages
        return .ok(BizumGetOrganizationsUseCaseOkOutput(
                    organizations: organizations,
                    isMoreData: isMoreData,
                    totalPages: totalPages)
        )
    }
}

public struct BizumGetOrganizationsUseCaseInput {
    let page: Int
    
    public init(page: Int) {
        self.page = page
    }
}

public struct BizumGetOrganizationsUseCaseOkOutput {
    public let organizations: [BizumOrganizationEntity]
    public let isMoreData: Bool
    public let totalPages: Int
}
