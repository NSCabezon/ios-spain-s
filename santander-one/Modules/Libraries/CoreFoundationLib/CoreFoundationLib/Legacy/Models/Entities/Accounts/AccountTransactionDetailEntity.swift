import Foundation
import SANLegacyLibrary

public struct AccountTransactionDetailEntity: DTOInstantiable {
    public let dto: AccountTransactionDetailDTO
    
    public init(_ dto: DTO) {
        self.dto = dto
    }
    
    public var literals: [(title: String, destiption: String)] {
        return dto.literalDTOs?.reduce(into: [], literalsToDictionary) ?? []
    }
    
    public var title: String? {
        return dto.title
    }
    
    private func literalsToDictionary(in array: inout [(String, String)], literal: LiteralDTO) {
        guard let concept = literal.concept, let literal = literal.literal else { return }
        array.append((literal, concept))
    }
}
