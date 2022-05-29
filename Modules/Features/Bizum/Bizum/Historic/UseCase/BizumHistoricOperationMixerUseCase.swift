import CoreFoundationLib

// MARK: - BizumHistoricOperationMixerUseCase

final class BizumHistoricOperationMixerUseCase: UseCase<BizumHistoricOperationMixerUseCaseInput, BizumHistoricOperationMixerUseCaseOkOutput, StringErrorOutput> {
    
    override public func executeUseCase(requestValues: BizumHistoricOperationMixerUseCaseInput) throws -> UseCaseResponse<BizumHistoricOperationMixerUseCaseOkOutput, StringErrorOutput> {
        let operations: [BizumHistoricOperationEntity] = requestValues.operations.map { .simple(operation: $0) }
        let operationsMultiple: [BizumHistoricOperationEntity] = requestValues.operationsDetail.map { .multiple(operation: $0) }
        let historic: [BizumHistoricOperationEntity] = operations + operationsMultiple
        let historicSorted: [BizumHistoricOperationEntity] = historic.sorted {
            guard let date1 = $0.date else {
                return false
            }
            guard let date2 = $1.date else {
                return true
            }
            return date1 > date2
        }
        return .ok(BizumHistoricOperationMixerUseCaseOkOutput(operations: historicSorted))
    }
}

// MARK: - BizumHistoricOperationMixerUseCaseInput

struct BizumHistoricOperationMixerUseCaseInput {
    let operations: [BizumOperationEntity]
    let operationsDetail: [BizumOperationMultiDetailEntity]
}

// MARK: - BizumHistoricOperationMixerUseCaseOkOutput

struct BizumHistoricOperationMixerUseCaseOkOutput {
    let operations: [BizumHistoricOperationEntity]
}
