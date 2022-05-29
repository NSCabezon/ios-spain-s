import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol GetContactDetailUseCaseProtocol: UseCase<GetContactDetailUseCaseInput, GetContactDetailUseCaseOkOutput, StringErrorOutput> { }

final class GetContactDetailUseCase: UseCase<GetContactDetailUseCaseInput, GetContactDetailUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetContactDetailUseCaseInput) throws -> UseCaseResponse<GetContactDetailUseCaseOkOutput, StringErrorOutput> {
        let output: GetContactDetailUseCaseOkOutput = try {
            if requestValues.contact.isNoSepa {
                return try getNoSepaDetail(for: requestValues.contact)
            } else {
                return try getSepaDetail(for: requestValues.contact)
            }
        }()
        return .ok(output)
    }
}

private extension GetContactDetailUseCase {

    func getNoSepaDetail(for contact: PayeeRepresentable) throws -> GetContactDetailUseCaseOkOutput {
        let managersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let response = try managersProvider.getBsanTransfersManager().noSepaPayeeDetail(of: contact.payeeAlias ?? "", recipientType: contact.recipientType ?? "")
        let data = try response.getResponseData()
        let favorite = NoSepaFavoriteAdapter(favorite: contact, noSepaPayeeDetail: data.map(NoSepaPayeeDetailEntity.init))
        return try GetContactDetailUseCaseOkOutput(detail: favorite, sepaList: getSepaInfo())
    }
    
    func getSepaDetail(for contact: PayeeRepresentable) throws -> GetContactDetailUseCaseOkOutput {
        let favorite = SepaFavoriteAdapter(favorite: contact)
        return try GetContactDetailUseCaseOkOutput(detail: favorite, sepaList: getSepaInfo())
    }
    
    func getSepaInfo() throws -> SepaInfoListEntity {
        let sepaInfoRepository = self.dependenciesResolver.resolve(for: SepaInfoRepositoryProtocol.self)
        return SepaInfoListEntity(dto: sepaInfoRepository.getSepaList())
    }
}

public struct GetContactDetailUseCaseInput {
    public let contact: PayeeRepresentable
}

public struct GetContactDetailUseCaseOkOutput {
    let detail: FavoriteType
    let sepaList: SepaInfoListEntity
    
    public init(detail: FavoriteType, sepaList: SepaInfoListEntity) {
        self.detail = detail
        self.sepaList = sepaList
    }
}

extension GetContactDetailUseCase: GetContactDetailUseCaseProtocol { }
