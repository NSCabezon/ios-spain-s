import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadVariableIncomePortfoliosUseCase: UseCase<LoadVariableIncomePortfoliosUseCaseInput, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: LoadVariableIncomePortfoliosUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        if requestValues.userTypePortfolio == .portfolioSelect {
            let bsanResponse = try managersProvider.getBsanPortfoliosPBManager().loadVariableIncomePortfolioSelect()
            if bsanResponse.isSuccess() {
                return UseCaseResponse.ok()
            }
            return UseCaseResponse.error(StringErrorOutput(try bsanResponse.getErrorMessage()))
        } else {
            let isPB = try checkRepositoryResponse(managersProvider.getBsanSessionManager().isPB()) ?? false
            if isPB {
                let bsanResponse = try managersProvider.getBsanPortfoliosPBManager().loadVariableIncomePortfolioPb()
                if bsanResponse.isSuccess() {
                    return UseCaseResponse.ok()
                }
                return UseCaseResponse.error(StringErrorOutput(try bsanResponse.getErrorMessage()))
            }
        }
        return UseCaseResponse.ok()
    }
}

extension LoadVariableIncomePortfoliosUseCase: RepositoriesResolvable {}

struct LoadVariableIncomePortfoliosUseCaseInput {
    let userTypePortfolio: UserTypePortfolio
}
