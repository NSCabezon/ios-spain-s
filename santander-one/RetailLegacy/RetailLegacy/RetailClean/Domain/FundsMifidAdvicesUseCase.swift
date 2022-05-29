import CoreFoundationLib
import SANLegacyLibrary

extension FundSubscriptionDTO: MifidAdvicesResponsePrototocol {
    var advice: MifidAdviceProtocol? {
        return mifidAdviceDTO
    }
}

extension FundTransferDTO: MifidAdvicesResponsePrototocol {
    var advice: MifidAdviceProtocol? {
        return mifidAdviceModel
    }
}

class FundsSubscriptionMifidAdvicesUseCase<Input: MifidAdvicesUseCaseInputProtocol>: MifidAdvicesUseCase<Input, FundSubscriptionDTO> {
}

class FundsTransferMifidAdvicesUseCase<Input: MifidAdvicesUseCaseInputProtocol>: MifidAdvicesUseCase<Input, FundTransferDTO> {
}
