import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class GetLastBillUseCase: UseCase<GetLastBillUseCaseInput, GetLastBillUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let provider: BSANManagersProvider
    var billEntities: [LastBillEntity] = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetLastBillUseCaseInput)
        throws -> UseCaseResponse<GetLastBillUseCaseOkOutput, StringErrorOutput> {
            let billTaxesManager = self.provider.getBsanBillTaxesManager()
            let filter = requestValues.filter
            let startDate = filter.dateRange.startDate?.startOfDay().getUtcDate() ?? Date().startOfDay().addMonth(months: -2)
            let endDate =  filter.dateRange.endDate?.startOfDay().getUtcDate() ?? Date().startOfDay()
            let fromDate = DateModel(date: startDate)
            let toDate = DateModel(date: endDate)
            let status = self.billStatusList(for: filter.billStatus)
            
            guard let account = filter.account else {
                return .error(StringErrorOutput(nil))
            }
            
            let response = try billTaxesManager.loadBills(
                of: account.dto,
                pagination: requestValues.pagination?.dto,
                from: fromDate,
                to: toDate,
                status: status
            )
            
            guard response.isSuccess(), let data = try response.getResponseData() else {
                return .ok(GetLastBillUseCaseOkOutput(
                    bills: billEntities,
                    fromDate: fromDate.date.addDay(days: -1)))
            }
            
            self.billEntities = data.bills.map(LastBillEntity.init)
            
            guard let pagination = data.pagination else {
                return .ok(GetLastBillUseCaseOkOutput(
                    bills: billEntities,
                    fromDate: fromDate.date.addDay(days: -1)))
            }
            
            guard pagination.endList else {
                let nextPageInput = GetLastBillUseCaseInput(
                    pagination: PaginationEntity(pagination),
                    filter: requestValues.filter)
                return try self.executeUseCase(requestValues: nextPageInput)
            }
            
            return .ok(GetLastBillUseCaseOkOutput(
                bills: billEntities,
                fromDate: fromDate.date.addDay(days: -1)))
    }
    
    private func billStatusList(for status: LastBillStatus) -> BillListStatus {
        switch status {
        case .canceled:
            return .canceled
        case .applied:
            return .applied
        case .returned:
            return .returned
        case .pendingToApply:
            return .pendingToApply
        case .pendingOfDate:
            return .pendingOfDate
        case .pendingToResolve:
            return .pendingToResolve
        case .unknown:
            return .all
        }
    }
}

struct GetLastBillUseCaseInput {
    let pagination: PaginationEntity?
    let filter: BillFilter
}

struct GetLastBillUseCaseOkOutput {
    let bills: [LastBillEntity]
    let fromDate: Date
}
