import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadCardsDataUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let bsanResponse = try managersProvider.getBsanCardsManager().loadAllCardsData()
        if bsanResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(StringErrorOutput(try bsanResponse.getErrorMessage()))
    }
}

extension LoadCardsDataUseCase: RepositoriesResolvable {}
