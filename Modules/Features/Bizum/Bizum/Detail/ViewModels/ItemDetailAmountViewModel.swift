import CoreFoundationLib
import UI

protocol ItemDetailAmountViewProtocol: class {
    func update(with viewModel: ItemDetailAmountViewModel)
}

final class ItemDetailAmountViewModel {
    private(set) var title: TextWithAccessibility
    private(set) var amount: AmountEntity
    private(set) var info: TextWithAccessibility?
    private(set) var stateLabel: TextWithAccessibility?
    private(set) var stateViewModel: BizumHomeOperationTypeStateViewModel?
    private(set) var amountWithAttributed: NSAttributedString?
    private(set) var amountAccessibility: String?

    public init(title: TextWithAccessibility,
                amount: AmountEntity,
                info: TextWithAccessibility?,
                stateLabel: TextWithAccessibility? = nil,
                stateViewModel: BizumHomeOperationTypeStateViewModel? = nil) {
        self.title = title
        self.amount = amount
        self.info = info
        self.stateLabel = stateLabel
        self.stateViewModel = stateViewModel
    }
    
    func setup(_ view: ItemDetailAmountViewProtocol) {
        view.update(with: self)
    }

    func setTitle(_ title: TextWithAccessibility) {
        self.title = title
    }
    func setAmountStyle(_ amount: NSAttributedString) {
        self.amountWithAttributed = amount
    }

    func setAmountAccessibility(_ value: String) {
        amountAccessibility = value
    }
    
    func setInfoStyle(_ style: LocalizedStylableTextConfiguration) {
        self.info?.setStyle(style)
    }

    func setInfoAccessibility(_ value: String) {
        self.info?.setAccessibility(value)
    }
}
