import SANLegacyLibrary
import CoreFoundationLib

extension PensionMifidClauseDTO: MifidClauseProtocol {
    var text: String? {
        return clauseDesc
    }
    var primaryCode: String? {
        return clauseType?.alphanumericCode
    }
    var secondaryCode: String? {
        return prodClause?.alphanumericCode
    }
}

extension PensionMifidDTO: Mifid1ResponseProtocol {
    var clauses: [MifidClauseProtocol]? {
        return pensionMifidClauseDTOS
    }
    
}

struct PensionsMifid1UseCaseInput: Mifid1UseCaseInputProtocol {
    let data: PensionMifidClausesParamenters
}

class PensionsMifid1UseCase: Mifid1UseCase<PensionsMifid1UseCaseInput, PensionMifidDTO> {
    override func getMifidResponse(requestValues: PensionsMifid1UseCaseInput) throws -> BSANResponse<PensionMifidDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
}

extension PensionsMifid1UseCase: PensionMifidClausesGetter {}
