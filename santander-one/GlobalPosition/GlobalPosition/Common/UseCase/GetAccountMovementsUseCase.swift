import CoreFoundationLib

final class GetAccountMovementsUseCase: UseCase<GetAccountMovementsUseCaseInput, GetAccountMovementsUseCaseOkOutput, StringErrorOutput> {
    override func executeUseCase(requestValues: GetAccountMovementsUseCaseInput) throws -> UseCaseResponse<GetAccountMovementsUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let userId = globalPosition.userCodeType else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let pfm: PfmHelperProtocol = requestValues.dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        let date = Date().getDateByAdding(days: -89, ignoreHours: true)
        var movements = pfm.getMovementsFor(userId: userId, date: date, account: requestValues.account)
        if movements.count > 3 {
            movements = Array(movements[..<3])
        }
        return UseCaseResponse.ok(GetAccountMovementsUseCaseOkOutput(movements: movements))
    }
}

struct GetAccountMovementsUseCaseOkOutput {
    let movements: [AccountTransactionEntity]
}

struct GetAccountMovementsUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let account: AccountEntity
}
