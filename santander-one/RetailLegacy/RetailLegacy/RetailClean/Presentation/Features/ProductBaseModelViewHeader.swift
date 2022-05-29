import UIKit
import CoreFoundationLib

class ProductBaseModelViewHeader <T> : TableModelViewHeader <T> where T: ProductGenericViewHeader {

    var filter: OwnershipProfile?
    var userPref: UserPref?
    var globalPosition: GlobalPositionWrapper
    var stringLoader: StringLoader
    var useCaseProvider: UseCaseProvider
    var userCaseHandler: UseCaseHandler
    var thereIsOnlyOffer: Bool

    init(_ globalPosition: GlobalPositionWrapper, _ filter: OwnershipProfile?, _ userPref: UserPref?, _ stringLoader: StringLoader, _ useCaseProvider: UseCaseProvider, _ useCaseHandler: UseCaseHandler, _ thereIsOnlyOffer: Bool) {
        self.filter = filter
        self.globalPosition = globalPosition
        self.userPref = userPref
        self.stringLoader = stringLoader
        self.useCaseProvider = useCaseProvider
        self.userCaseHandler = useCaseHandler
        self.thereIsOnlyOffer = thereIsOnlyOffer
        super.init()
    }
    
    override var height: CGFloat {
        return 76.0
    }
    
    func getProductNumber() -> LocalizedStylableText {
        fatalError()
    }
    
    func getTotalAmount() -> String? {
        fatalError()
    }
    
    func isSectionOpen() -> Bool? {
        fatalError()
    }

    func getSubLabel() -> LocalizedStylableText {
        return LocalizedStylableText(text: "", styles: nil)
    }
    
    func getTotalTransfers() -> String {
        return ""
    }
    
    func getTransfersLabel() -> LocalizedStylableText? {
        return nil
    }
    
    func getBackgroundColor() -> UIColor {
        return .white
    }
    
    private func updateTransferLabels(viewHeader: T) {
        viewHeader.setTotalTransfers(totalTransfers: getTotalTransfers())
        viewHeader.setTransfersLabel(transfersLabel: getTransfersLabel())
    }
    
    override func bind(viewHeader: T) {
        super.bind(viewHeader: viewHeader)
        viewHeader.setLabel(label: getProductNumber())
        
        guard !thereIsOnlyOffer else {
            viewHeader.hideAllExceptTitle()
            return
        }
        
        if let totalAmount = getTotalAmount() {
            viewHeader.setTotalAmount(totalAmount: totalAmount)
        } else {
            viewHeader.setMultipleCurrency(totalAmount: stringLoader.getString("pgBasket_label_differentCurrency"))
        }
        viewHeader.setBackgroundColorCell(color: getBackgroundColor())
        viewHeader.setSubLabel(subLabel: getSubLabel())
        configure(viewHeader: viewHeader)
        if let open = isSectionOpen() {
            viewHeader.setCollapsed(collapsed: !open)
        }
        viewHeader.showAll()
    }
    
    override func configure(viewHeader: T) {
        updateTransferLabels(viewHeader: viewHeader)
    }
    
    func updatePref(userPref: UserPref) {
        UseCaseWrapper(with: useCaseProvider.getUpdatePGUserPrefUseCase(input: UpdatePGUserPrefUseCaseInput(userPref: userPref)), useCaseHandler: userCaseHandler, errorHandler: nil)
    }
    
}
