//
import CoreDomain
import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class LoadImpositionLiquidationsUseCase: UseCase<LoadImpositionLiquidationsUseCaseInput, LoadImpositionLiquidationsUseCaseOKOutput, LoadImpositionLiquidationsUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: LoadImpositionLiquidationsUseCaseInput) throws -> UseCaseResponse<LoadImpositionLiquidationsUseCaseOKOutput, LoadImpositionLiquidationsUseCaseErrorOutput> {
        
        guard let imposition = requestValues.imposition else {
            return UseCaseResponse.error(LoadImpositionLiquidationsUseCaseErrorOutput(""))
        }
        
        let dateFilter = requestValues.dateFilter
        
        if dateFilter.toDateModel == nil {
            dateFilter.toDateModel = DateModel(date: Date())
        }
        
        let bsanDepositManager = provider.getBsanDepositsManager()
        let response = try bsanDepositManager.getImpositionLiquidations(impositionDTO: imposition, pagination: requestValues.pagination?.dto, dateFilter: requestValues.dateFilter)
        guard response.isSuccess(), let data = try response.getResponseData(), let liquidationList = LiquidationList(data) else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(LoadImpositionLiquidationsUseCaseErrorOutput(errorDescription))
        }
        
        return UseCaseResponse.ok(LoadImpositionLiquidationsUseCaseOKOutput(liquidationList: liquidationList))
        
    }
}

struct LoadImpositionLiquidationsUseCaseInput {
    
    let imposition: ImpositionDTO?
    let dateFilter: DateFilter
    let pagination: PaginationDO?
    
    init(imposition: Imposition, dateFilter: DateFilter? = nil, pagination: PaginationDO?) {
        self.imposition = imposition.dto
        self.dateFilter = dateFilter ?? DateFilter.getDateFilterFor(numberOfYears: -1)
        self.pagination = pagination
    }
    
}

struct LoadImpositionLiquidationsUseCaseOKOutput {
    let liquidationList: LiquidationList
}

class LoadImpositionLiquidationsUseCaseErrorOutput: StringErrorOutput {
    
}
