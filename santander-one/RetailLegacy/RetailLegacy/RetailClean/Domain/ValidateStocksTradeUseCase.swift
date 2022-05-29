import CoreFoundationLib
import SANLegacyLibrary

class ValidateStocksTradeUseCase: BaseValidateStocksTradeUseCase<ValidateStocksTradeUseCaseOkOutput, ValidateStocksTradeUseCaseErrorOutput> {
    
    override func error(with errorString: String?) -> ValidateStocksTradeUseCaseErrorOutput {
        return ValidateStocksTradeUseCaseErrorOutput(errorString)
    }
}

struct ValidateStocksTradeUseCaseOkOutput {
    let signature: Signature?
}

extension ValidateStocksTradeUseCaseOkOutput: ValidateStocksTradeUseCaseOkOutputProtocol {
    init(data: StockDataBuySellDTO, account: Account?) {
        let signatureDTO = data.signature ?? SignatureDTO(length: 0, positions: [])
        self.init(signature: Signature(dto: signatureDTO))
    }
}

class ValidateStocksTradeUseCaseErrorOutput: StringErrorOutput {
}
