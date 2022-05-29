import Operative
import CoreFoundationLib
import UI

final class ShareEasyPaySummaryViewModel {
    private let amount: AmountEntity?
    private let operativeNumberOfFees: Int?
    private let operativeConcept: String?
    private var userName: String? = ""
    private let operativeStartDate: Date?
    private let operativeEndDate: Date?
    
    init(amount: AmountEntity?,
         operativeNumberOfFees: Int?,
         operativeConcept: String?,
         operativeStartDate: Date?,
         operativeEndDate: Date?) {
        self.amount = amount
        self.operativeNumberOfFees = operativeNumberOfFees
        self.operativeConcept = operativeConcept
        self.operativeStartDate = operativeStartDate
        self.operativeEndDate = operativeEndDate
    }
    
    var title: LocalizedStylableText? {
        return localized("share_label_easyPay",
                         [StringPlaceholder(.name, self.userName?.camelCasedString ?? "")])
    }
    
    var amountText: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 28.8)
        guard let amount = amount else { return nil }
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16.2)
        return decorator.getFormatedCurrency()
    }
    
    var concept: String {
        guard let conceptText = operativeConcept, conceptText != "" else {
            return localized("bizum_label_notConcept").text
        }
        return conceptText.camelCasedString
    }
    
    var numberOfFees: String {
        String(operativeNumberOfFees ?? 0) 
    }
    
    var feeAmount: NSAttributedString? {
        guard let totalAmount = amount?.value,
              let currency = amount?.dto.currency,
              let numberOfFees = operativeNumberOfFees,
              numberOfFees > 0
        else { return nil }
        let feeValue = abs(totalAmount / Decimal(numberOfFees))
        
        let fee = AmountEntity(value: feeValue,
                               currency: currency.currencyType)
        guard let moneyDecorator = MoneyDecorator(fee,
                                                  font: .santander(family: .text, type: .regular, size: 14.0),
                                                  decimalFontSize: 14.0)
                .getFormatedCurrency()
        else { return nil }
        return moneyDecorator
    }
    
    var startDate: String {
        guard let startDate = operativeStartDate else { return "" }
        return dateToString(date: startDate, outputFormat: .dd_MMM_yyyy) ?? ""
    }
    
    var endDate: String {
        guard let endDate = operativeEndDate else { return "" }
        return dateToString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
    }
    
    func setUserName(_ userName: String?) {
        self.userName = userName
    }
}

final class ShareEasyPayView: UIShareView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var santanderImage: UIImageView!
    @IBOutlet private weak var nameTitle: UILabel!
    @IBOutlet private weak var brokenTicketImage: UIImageView!
    @IBOutlet private weak var amountTitle: UILabel!
    @IBOutlet private weak var amountText: UILabel!
    @IBOutlet private weak var conceptTitle: UILabel!
    @IBOutlet private weak var conceptText: UILabel!
    @IBOutlet private weak var numberOfFeesTitle: UILabel!
    @IBOutlet private weak var numberOfFeesText: UILabel!
    @IBOutlet private weak var feeAmountTitle: UILabel!
    @IBOutlet private weak var feeAmountText: UILabel!
    @IBOutlet private weak var startDateTitle: UILabel!
    @IBOutlet private weak var startDateText: UILabel!
    @IBOutlet private weak var endDateTitle: UILabel!
    @IBOutlet private weak var endDateText: UILabel!
    
    init() {
        super.init(nibName: "ShareEasyPayView", bundleName: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setAccessibilityIdentifiers()
    }

    func setInfoFromSummary(_ viewModel: ShareEasyPaySummaryViewModel) {
        nameTitle.configureText(withLocalizedString: viewModel.title ?? .empty)
        amountText.attributedText = viewModel.amountText
        conceptText.text = viewModel.concept
        numberOfFeesText.text = viewModel.numberOfFees
        feeAmountText.attributedText = viewModel.feeAmount
        startDateText.text = viewModel.startDate
        endDateText.text = viewModel.endDate
        containerView.layoutIfNeeded()
    }
}

private extension ShareEasyPayView {
    func setupView() {
        santanderImage.image = Assets.image(named: "icnSantander")
        brokenTicketImage.image = Assets.image(named: "imgTornBig")
        nameTitle.setSantanderTextFont(type: .regular, size: 16.0, color: .lisboaGray)
        amountTitle.configureText(withKey: "summary_item_postponeAmount")
        amountTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        amountText.setSantanderTextFont(type: .bold, size: 32.0, color: .lisboaGray)
        conceptTitle.configureText(withKey: "summary_item_concept")
        conceptTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        conceptText.setSantanderTextFont(type: .italic, size: 14.0, color: .lisboaGray)
        numberOfFeesTitle.configureText(withKey: "summary_item_fee")
        numberOfFeesTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        numberOfFeesText.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        feeAmountTitle.configureText(withKey: "summary_item_feeAmount")
        feeAmountTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        feeAmountText.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        startDateTitle.configureText(withKey: "summary_item_startDate")
        startDateTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        startDateText.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        endDateTitle.configureText(withKey: "summary_item_endDate")
        endDateTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        endDateText.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
    }
    
    func setAccessibilityIdentifiers() {
        santanderImage.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.santanderImage
        brokenTicketImage.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.brokenTicketImage
        amountTitle.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.amountTitle
        amountText.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.amountText
        conceptTitle.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.conceptTitle
        startDateTitle.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.startDateTitle
        nameTitle.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.nameTitle
        conceptText.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.conceptText
        endDateText.accessibilityIdentifier = AccessibilityCardsEasyPay.SummaryShareView.endDateText
    }
}
