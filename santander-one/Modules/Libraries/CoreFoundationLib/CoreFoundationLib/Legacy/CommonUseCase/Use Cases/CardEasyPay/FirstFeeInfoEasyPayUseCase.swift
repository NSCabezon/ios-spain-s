import SANLegacyLibrary

public final class FirstFeeInfoEasyPayUseCase: UseCase<EasyPayFirstFeeInfoUseCaseInput, FirstFeeInfoEasyPayUseCaseOkOutput, StringErrorOutput> {
    
    private let resolver: DependenciesResolver
    
    private var localeManager: TimeManager {
        return resolver.resolve(for: TimeManager.self)
    }
    
    private var provider: BSANManagersProvider {
        return resolver.resolve(for: BSANManagersProvider.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.resolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: EasyPayFirstFeeInfoUseCaseInput) throws -> UseCaseResponse<FirstFeeInfoEasyPayUseCaseOkOutput, StringErrorOutput> {
        let manager = provider.getBsanCardsManager()
        guard let cardDTO = requestValues.cardDTO,
              let parameters = createParameters(with: requestValues) else {
            return UseCaseResponse.error(StringErrorOutput("No parameters"))
        }
        let response = try manager.getEasyPayFees(input: parameters,
                                                  card: cardDTO)
        guard response.isSuccess(),
              let dataResponse = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let output = self.createOkOutput(with: dataResponse, totalFees: requestValues.numberOfFees)
        return UseCaseResponse.ok(output)
    }
}

// MARK: - Private Methods

private extension FirstFeeInfoEasyPayUseCase {
    
    func createParameters(with input: EasyPayFirstFeeInfoUseCaseInput) -> BuyFeesParameters? {
        guard let balanceCode = input.transactionBalanceCode, let transactionDay = input.transactionDay else { return nil }
        return BuyFeesParameters(numFees: input.numberOfFees,
                                 balanceCode: balanceCode,
                                 transactionDay: transactionDay)
    }
    
    func createOkOutput(with dto: FeesInfoDTO, totalFees: Int) -> FirstFeeInfoEasyPayUseCaseOkOutput {
        let entity = EasyPayCurrentFeeDataEntity(dto,
                                                 settlementDate: localeManager
                                                    .fromString(input: dto.settlementDate,
                                                                inputFormat: .yyyyMMdd),
                                                 totalMonths: totalFees)
        return FirstFeeInfoEasyPayUseCaseOkOutput(currentFeeData: entity)
    }
}

public struct EasyPayFirstFeeInfoUseCaseInput {
    public let numberOfFees: Int
    public let cardDTO: CardDTO?
    public let transactionBalanceCode: String?
    public let transactionDay: String?
    
    public init(numberOfFees: Int,
                cardDTO: CardDTO?,
                transactionBalanceCode: String?,
                transactionDay: String?) {
        self.numberOfFees = numberOfFees
        self.cardDTO = cardDTO
        self.transactionBalanceCode = transactionBalanceCode
        self.transactionDay = transactionDay
    }
}

public struct FirstFeeInfoEasyPayUseCaseOkOutput {
    public let currentFeeData: EasyPayCurrentFeeDataEntity
}
