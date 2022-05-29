import Foundation
import CoreFoundationLib

class CardPendingTransactionDetailProfile: BaseTransactionDetailProfile<GetCreditCardForPANUseCaseInput, GetCreditCardForPANUseCaseOkOutput, StringErrorOutput>, TransactionDetailProfile {
    var screenId: String? {
        return nil
    }
    
    var navigatorLauncher: OperativesNavigatorProtocol {
        return dependencies.navigatorProvider.cardTransactionDetailNavigator
    }
    
    private var cardTransactionDetail: CardTransactionDetail?
    private var topProductOptions: [ProductOption]?
    private var newAlias: String?
    
    var cardTransaction: CardPendingTransaction? {
        guard let transaction = transaction as? CardMovement else { return nil }
        if case let .pending(cardTransaction) = transaction.transaction {
            return cardTransaction
        }
        return nil
    }
        
    var title: String? {
        return cardTransaction?.description?.camelCasedString
    }
    
    var alias: String? {        
        guard let product = newAlias else { return nil }
        return product
    }
    
    var amount: String? {
        return cardTransaction?.amount.getFormattedAmountUI()
    }
    
    var showSeePdf: Bool? {
        return false
    }
    
    var titleLeft: LocalizedStylableText? {
        return dependencies.stringLoader.getString("cardDetail_label_annotationDate")
    }
    
    var infoLeft: String? {
        guard let annotationDate = cardTransaction?.annotationDate else { return nil }
        guard let dateString = dependencies.timeManager.toString(date: annotationDate, outputFormat: .d_MMM_yyyy) else {
            return nil
        }
        return dateString
    }
    
    var titleRight: LocalizedStylableText? {
        return dependencies.stringLoader.getString("cardDetail_label_hour")
    }
    
    var infoRight: String? {
        guard let dateString = dependencies.timeManager.toString(input: cardTransaction?.transactionTime, inputFormat: TimeFormat.HHmmssZ, outputFormat: TimeFormat.HHmm) else {
            return nil
        }
        return dateString
    }
    
    var singleInfoTitle: LocalizedStylableText? {
        return nil
    }
    
    var balance: String? {
        return nil
    }
    
    var showLoading: Bool? {
        return true
    }
    
    var showActions: Bool? {
        return true
    }
    
    var showShare: Bool? {
        return true
    }
    
    override var sideTitleText: LocalizedStylableText? {
        guard let transaction = cardTransactionDetail else { return nil }
        if transaction.isPaidOff == true {
            return dependencies.stringLoader.getString("cardDetail_text_liquidated")
        } else {
            return dependencies.stringLoader.getString("cardDetail_text_notLiquidated")
        }
    }
    
    override var sideDescriptionText: LocalizedStylableText? {
        guard let transaction = cardTransactionDetail,
            let paidOffDate = transaction.paidOffDate,
            let dateDescription = dependencies.timeManager.toString(date: paidOffDate, outputFormat: .d_MMM_yyyy) else {
                return nil
        }
        return LocalizedStylableText(text: "(\(dateDescription))", styles: nil)
    }
    
    override func useCaseForTransactionDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        guard let pan = cardTransaction?.cardNumber else { return nil }
        UseCaseWrapper(with: dependencies.useCaseProvider.getCreditCardForPANUseCase(input: GetCreditCardForPANUseCaseInput(pan: pan)), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { (response) in
            guard let card = response.card else { return }
            self.newAlias = card.getAliasUpperCase()
            self.delegate?.reloadAlias()
        })
        return nil
    }
    
    func stringToShare() -> String? {
        var stringToShare = ""
        if let title = title {
            stringToShare.append("\(title)\n")
        }
        if let amount = amount {
            let titleAmount = dependencies.stringLoader.getString("summary_item_quantity").text
            stringToShare.append("\(titleAmount) \(amount)\n")
        }
        if let titleLeft = titleLeft, let infoLeft = infoLeft {
            stringToShare.append("\(titleLeft.text) \(infoLeft)\n")
        }
        
        if let titleRight = titleRight, let infoRight = infoRight {
            stringToShare.append("\(titleRight.text) \(infoRight)\n")
        }
        
        for line in shareableInfo {
            stringToShare.append("\(line.0.title.text) \(line.0.info)\n")
            if let second = line.1 {
                stringToShare.append("\(second.title.text) \(second.info)\n")
            }
        }
        return stringToShare
    }
    
    override func actions(withProductConfig productConfig: ProductConfig) {
        guard let options = optionsDelegate?.generatedOptions else { return }
        let maximumOptions = min(2, options.count)
        let topProductOptions = Array(options[0...maximumOptions])
        self.topProductOptions = topProductOptions
        let actionList = Array(topProductOptions.enumerated().map({ (title: $0.element.title, index: $0.offset) }))
        var actions = [TransactionDetailActionType]()
        for action in actionList {
            let option = TransactionDetailAction(title: action.title) { [weak self] in
                guard let card = self?.product as? Card, let productOptions = self?.topProductOptions else { return }
                self?.optionDidSelected(at: productOptions[action.index].index, product: card, presenterOffers: nil, delegate: self?.transactionDetailManager)
            }
            actions.append(option)
        }
        completionActions?(actions)
    }
    
    override func getInfoFromTransactionDetail(transactionDetail: GenericTransactionProtocol) -> [TransactionLine]? {
        guard let cardTransactionDetail = transactionDetail as? CardTransactionDetail, let time = cardTransactionDetail.time, let formattedTime = dependencies.timeManager.toString(input: time, inputFormat: .HHmmssZ, outputFormat: .HHmmss), let cardFee = cardTransactionDetail.fee else { return nil }
        self.cardTransactionDetail = cardTransactionDetail
        let hour = (dependencies.stringLoader.getString("summary_item_hour"), formattedTime)
        let fee = (dependencies.stringLoader.getString("cardDetail_label_commissions"), cardFee.getFormattedAmountUI())
        shareableInfo = [(hour, fee)]
        
        return shareableInfo
    }
}

extension CardPendingTransactionDetailProfile: CardOperativeHandler {
    var operativePresentationDelegate: OperativeLauncherPresentationDelegate? {
        return transactionDetailManager?.operativeDelegate
    }
    
    var origin: OperativeLaunchedFrom {
        return .home
    }
}
