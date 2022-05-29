import CoreFoundationLib

public protocol SendMoneyTransferTypeUseCaseProtocol: UseCase<SendMoneyTransferTypeUseCaseInputProtocol, SendMoneyTransferTypeUseCaseOkOutputProtocol, StringErrorOutput> {}

public protocol SendMoneyTransferTypeUseCaseInputProtocol {}
public protocol SendMoneyTransferTypeUseCaseOkOutputProtocol {
    var shouldShowSpecialPrices: Bool { get }
    var fees: [SendMoneyTransferTypeFee] { get }
    var transactionTypeString: String? { get }
}

public protocol SendMoneyTransferTypeUseCaseInputAdapterProtocol {
    func toUseCaseInput(operativeData: SendMoneyOperativeData) -> SendMoneyTransferTypeUseCaseInputProtocol?
}
