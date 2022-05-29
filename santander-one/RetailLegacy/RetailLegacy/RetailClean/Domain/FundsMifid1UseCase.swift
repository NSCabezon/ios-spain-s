import CoreFoundationLib
import SANLegacyLibrary

extension FundMifidClauseDTO: MifidClauseProtocol {
    var primaryCode: String? {
        return clauseType?.alphanumericCode
    }
    var secondaryCode: String? {
        return prodClause?.alphanumericCode
    }
    var text: String? {
        return clauseDesc
    }
}

extension FundSubscriptionDTO: Mifid1ResponseProtocol {
    var clauses: [MifidClauseProtocol]? {
        return fundMifidClauseDataList
    }
}

extension FundTransferDTO: Mifid1ResponseProtocol {
    var clauses: [MifidClauseProtocol]? {
        return fundMifidClauseDataList
    }
}

class FundsSubscriptionMifid1UseCase<Input: Mifid1UseCaseInputProtocol>: Mifid1UseCase<Input, FundSubscriptionDTO> {
}

class FundsTransferMifid1UseCase<Input: Mifid1UseCaseInputProtocol>: Mifid1UseCase<Input, FundTransferDTO> {
}
