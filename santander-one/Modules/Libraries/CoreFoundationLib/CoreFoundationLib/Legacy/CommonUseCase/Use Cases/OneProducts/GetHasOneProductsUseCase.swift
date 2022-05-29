import Foundation
import SANLegacyLibrary

final public class GetHasOneProductsUseCase: UseCase<GetHasOneProductsUseCaseInput, GetHasOneProductsUseCaseOkOutput, StringErrorOutput> {
    private let accountDescriptorRepository: AccountDescriptorRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.accountDescriptorRepository = dependenciesResolver.resolve()
        self.bsanManagersProvider = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: GetHasOneProductsUseCaseInput) throws -> UseCaseResponse<GetHasOneProductsUseCaseOkOutput, StringErrorOutput> {
        return .ok(
            GetHasOneProductsUseCaseOkOutput(
                hasOneProduct: hasOneProducts(
                    accountDescriptorRepository: accountDescriptorRepository,
                    bsanManagersProvider: bsanManagersProvider,
                    for: requestValues.product
                )
            )
        )
    }
}

extension GetHasOneProductsUseCase: OneProductsEvaluator {}

public struct GetHasOneProductsUseCaseInput {
    public let product: KeyPath<AccountDescriptorArrayDTO, [ProductRangeDescriptorDTO]>
    
    public init(product: KeyPath<AccountDescriptorArrayDTO, [ProductRangeDescriptorDTO]>) {
        self.product = product
    }
}

public struct GetHasOneProductsUseCaseOkOutput {
    public let hasOneProduct: Bool
}
