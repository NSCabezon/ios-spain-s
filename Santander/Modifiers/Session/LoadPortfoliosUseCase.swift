import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadPortfoliosUseCase: UseCase<LoadPortfoliosUseCaseInput, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: LoadPortfoliosUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        if requestValues.userTypePortfolio == .portfolioSelect {
            let bsanResponse = try managersProvider.getBsanPortfoliosPBManager().loadPortfoliosSelect()
            if bsanResponse.isSuccess() {
                return UseCaseResponse.ok()
            }
            return UseCaseResponse.error(StringErrorOutput(try bsanResponse.getErrorMessage()))
        } else {
            let isPB = try checkRepositoryResponse(managersProvider.getBsanSessionManager().isPB()) ?? false
            if isPB {
                let bsanResponse = try managersProvider.getBsanPortfoliosPBManager().loadPortfoliosPb()
                if bsanResponse.isSuccess() {
                    return UseCaseResponse.ok()
                }
                return UseCaseResponse.error(StringErrorOutput(try bsanResponse.getErrorMessage()))
            }
        }
        return UseCaseResponse.ok()
    }
}

extension LoadPortfoliosUseCase: RepositoriesResolvable {}

struct LoadPortfoliosUseCaseInput {
    let userTypePortfolio: UserTypePortfolio
}
