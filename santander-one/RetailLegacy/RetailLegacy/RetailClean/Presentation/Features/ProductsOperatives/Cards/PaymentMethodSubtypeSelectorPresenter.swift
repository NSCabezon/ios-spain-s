import Foundation
import CoreFoundationLib

struct PaymentMethodSubtypeInfo {
    let status: PaymentMethodStatus
    let previousValue: Int
    let subtypes: [Int]
    let amountPercentage: Int?
    let title: LocalizedStylableText
    let paymentMethodDescriptionKey: String
}

class PaymentMethodSubtypeSelectorPresenter: PrivatePresenter<PaymentMethodSubtypeSelectorViewController, ChangePaymentMethodNavigatorProtocol, PaymentMethodSubtypeSelectorPresenterProtocol> {
    
    private weak var delegate: SelectCardModifyPaymentFormDelegate?
    private let previousValue: Int
    private let subtypes: [Int]
    private let amountPercentage: Int?
    private let title: LocalizedStylableText
    private let paymentMethodDescriptionKey: String
    private let status: PaymentMethodStatus
    
    init(delegate: SelectCardModifyPaymentFormDelegate, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: ChangePaymentMethodNavigatorProtocol, info: PaymentMethodSubtypeInfo) {
        self.delegate = delegate
        self.previousValue = info.previousValue
        self.subtypes = info.subtypes
        self.title = info.title
        self.status = info.status
        self.amountPercentage = info.amountPercentage
        self.paymentMethodDescriptionKey = info.paymentMethodDescriptionKey
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        view.show(barButton: .close)
        view.styledTitle = title
        view.titleIdentifier = "\(status)SubtypeTitle"
        let descriptionSection = TableModelViewSection()
        let descriptionModel = ClearLabelTableModelView(title: dependencies.stringLoader.getString(paymentMethodDescriptionKey), inputIndentifier: "\(status.rawValue)_titleInfo", style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 15), textAlignment: .left), insets: Insets(left: 16, right: 12, top: 16, bottom: 16), privateComponent: dependencies)
        descriptionSection.add(item: descriptionModel)
        let subtypesSection = TableModelViewSection()
        let subtypeViewModels = subtypes.map({ PaymentMethodSubtypeViewModel($0, subtitle: amountPercentage, status: status, isSelected: previousValue == $0, dependencies: dependencies) })
        subtypesSection.addAll(items: subtypeViewModels)
        self.view.sections = [descriptionSection, subtypesSection]
    }
}

extension PaymentMethodSubtypeSelectorPresenter: PaymentMethodSubtypeSelectorPresenterProtocol {
    func selected(_ index: Int) {
        delegate?.selectedQuantity(quantity: subtypes[index], status: status)
    }
}

extension PaymentMethodSubtypeSelectorPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        delegate?.closeButton()
    }
}
