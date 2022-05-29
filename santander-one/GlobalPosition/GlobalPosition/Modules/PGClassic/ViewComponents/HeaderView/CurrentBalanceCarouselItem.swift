import UI
import CoreFoundationLib

class CurrentBalanceCarouselItem: CarouselClassicItemViewModelType {
    private let selectedYourBalanceTextStyle: [NSAttributedString.Key: Any]
        = [.foregroundColor: UIColor.darkTorquoise, .font: UIFont.santander(family: .text, type: .bold, size: 12.0)]
    private let selectedFinanceTextStyle: [NSAttributedString.Key: Any]
        = [.foregroundColor: UIColor.lisboaPurple, .font: UIFont.santander(family: .text, type: .bold, size: 12.0)]
    private let unselectedTextStyle: [NSAttributedString.Key: Any]
        = [.foregroundColor: UIColor.grafite, .font: UIFont.santander(family: .text, type: .regular, size: 12.0)]
    private let subtitleSelectedStyle: [NSAttributedString.Key: Any]
        = [.foregroundColor: UIColor.lisboaGray, .font: UIFont.santander(family: .text, type: .bold, size: 20.0)]
    private let subtitleUnselectedStyle: [NSAttributedString.Key: Any]
        = [.foregroundColor: UIColor.grafite, .font: UIFont.santander(family: .text, type: .bold, size: 16.0)]
    
    private lazy var infoView = FinantialStatusView()
    private lazy var comingView = ClassicComingView()
    private lazy var fakeImage = UIImageView(image: Assets.image(named: "imgGraphicYourMoney"))
    private lazy var fakeView: UIView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(comingView)
        stackView.addArrangedSubview(fakeImage)
        stackView.bringSubviewToFront(comingView)
        stackView.spacing = -7
        return stackView
    }()
    private var isGraphHidden: Bool {
        return fakeImage.isHidden
    }
    var requiredHeight: CGFloat {
        return isGraphHidden ? 75 : Screen.isIphone4or5 ? 160 : 185
    }
    lazy var view: UIView = {
        buildView()
    }()

    var action: ((PGActionType) -> Void)?
    
    @objc func executeAction() {
        action?(.none)
    }
    
    private func buildView() -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        fakeImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(executeAction))
        fakeImage.addGestureRecognizer(tapGesture)
        stack.addArrangedSubview(infoView)
        stack.addArrangedSubview(fakeView)
        return stack
    }
    
    func setGraphHidden(_ isHidden: Bool) {
        fakeImage.isHidden = isHidden
    }
    
    func setFinantialStatusInfo(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        infoView.isHidden = false
        
        setYourBalanceSelected(totalBalance: totalBalance, financingTotal: financingTotal, tooltipText: tooltipText)
        
        infoView.setLeftAction({ [weak self] in
            self?.setYourBalanceSelected(totalBalance: totalBalance, financingTotal: financingTotal, tooltipText: tooltipText)
        })
        
        infoView.setRightAction({ [weak self] in
            self?.setFinantialTotalSelected(totalBalance: totalBalance, financingTotal: financingTotal, tooltipText: tooltipText)
        })
    }
    
    func setDiscreteMode(_ enabled: Bool) { infoView.setDiscreteMode(enabled) }
    
    private func setYourBalanceSelected(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        let totalBalanceData: FinantialStatusData
        let financingTotalData: FinantialStatusData
        
        if let totalBalance = totalBalance {
            totalBalanceData = FinantialStatusAmount(amount: totalBalance,
                                                     integerFont: UIFont.santander(type: .bold, size: 26.0),
                                                     decimalSize: 20.0,
                                                     color: .lisboaGray)
        } else {
            totalBalanceData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleSelectedStyle))
        }
        
        if let financingTotal = financingTotal {
            financingTotalData = FinantialStatusAmount(amount: financingTotal,
                                                       integerFont: UIFont.santander(type: .bold, size: 22.0),
                                                       decimalSize: 16.0,
                                                       color: .grafite)
        } else {
            financingTotalData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleUnselectedStyle))
        }
        
        let totalBalanceTitle = NSAttributedString(string: localized("pg_label_totMoney"), attributes: selectedYourBalanceTextStyle)
        let financingTitle = NSAttributedString(string: localized("pg_label_totFinancing"), attributes: unselectedTextStyle)
        
        infoView.setLeftData(title: totalBalanceTitle, subtitle: totalBalanceData.getFormattedString(), tooltipStyle: .red, tooltipText: tooltipText)
        infoView.setRightData(title: financingTitle, subtitle: financingTotalData.getFormattedString())
        infoView.setLeftSelected()
        fakeImage.image = Assets.image(named: "imgGraphicYourMoney")
    }
    
    private func setFinantialTotalSelected(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        let totalBalanceData: FinantialStatusData
        let financingTotalData: FinantialStatusData
        
        if let totalBalance = totalBalance {
            totalBalanceData = FinantialStatusAmount(amount: totalBalance,
                                                     integerFont: UIFont.santander(type: .bold, size: 22.0),
                                                     decimalSize: 16.0,
                                                     color: .grafite)
        } else {
            totalBalanceData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleUnselectedStyle))
        }
        
        if let financingTotal = financingTotal {
            financingTotalData = FinantialStatusAmount(amount: financingTotal,
                                                       integerFont: UIFont.santander(type: .bold, size: 26.0),
                                                       decimalSize: 20.0,
                                                       color: .lisboaGray)
        } else {
            financingTotalData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text,
                                                                              attributes: subtitleSelectedStyle))
        }
        
        let totalBalanceTitle = NSAttributedString(string: localized("pg_label_totMoney"), attributes: unselectedTextStyle)
        let financingTitle = NSAttributedString(string: localized("pg_label_totFinancing"), attributes: selectedFinanceTextStyle)
        
        infoView.setLeftData(title: totalBalanceTitle, subtitle: totalBalanceData.getFormattedString(), tooltipStyle: .red, tooltipText: tooltipText)
        infoView.setRightData(title: financingTitle, subtitle: financingTotalData.getFormattedString())
        infoView.setRightSelected()
        fakeImage.image = Assets.image(named: "imgGraphicYourFinancing")
    }
}

protocol FinantialStatusData {
    func getFormattedString() -> NSAttributedString
}

struct FinantialStatusAmount: FinantialStatusData {
    let amount: AmountEntity
    let integerFont: UIFont
    let decimalSize: CGFloat
    let color: UIColor
    
    func getFormattedString() -> NSAttributedString {
        let money = NSMutableAttributedString(attributedString: MoneyDecorator(amount, font: integerFont, decimalFontSize: decimalSize).getFormatedCurrency() ?? NSAttributedString(string: amount.getFormattedAmountAsMillions()))
        
        money.addAttributes([.foregroundColor: color], range: NSRange(location: 0, length: money.string.count))
        
        return money
    }
}

struct FinantialStatusText: FinantialStatusData {
    private let text: NSAttributedString
    
    init(text: NSAttributedString) {
        self.text = text
    }
    
    func getFormattedString() -> NSAttributedString {
        return text
    }
}
