import CoreFoundationLib
import SANLegacyLibrary

import Foundation

extension MifidClauseDTO: MifidClauseProtocol {
    var primaryCode: String? {
        return code
    }
    var secondaryCode: String? {
        return code
    }
    var text: String? {
        return clauseText
    }
}

extension MifidDTO: Mifid1ResponseProtocol {
    var clauses: [MifidClauseProtocol]? {
        return clauseModelList
    }
}

struct StocksMifid1UseCaseInput: Mifid1UseCaseInputProtocol {
    let data: StockMifidClausesParamenters
}

class StocksMifid1UseCase: Mifid1UseCase<StocksMifid1UseCaseInput, MifidDTO> {
    
    override func executeUseCase(requestValues: StocksMifid1UseCaseInput) throws -> UseCaseResponse<Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        let superResponse = try super.executeUseCase(requestValues: requestValues)
        guard superResponse.isOkResult, let mifid1Data = try superResponse.getOkResult().mifid1Data else {
            return superResponse
        }
        if case .none = mifid1Data.mifid1Status {
            let newData = Mifid1Data(userIsPb: mifid1Data.userIsPb, mifid1Status: .simple(simpleVariableText: nil))
            return UseCaseResponse.ok(Mifid1UseCaseOkOutput(mifid1Data: newData))
        }
        return superResponse
    }
    
    override func getMifidResponse(requestValues: StocksMifid1UseCaseInput) throws -> BSANResponse<MifidDTO> {
        return try getClauses(withParameters: requestValues.data)
    }
    
    override func clausuleHasSimpleType(_ simple: String?, isPB: Bool) -> Bool {
        return !(simple?.isEmpty ?? true)
    }
}

extension StocksMifid1UseCase: StocksMifidClausesGetter {}
