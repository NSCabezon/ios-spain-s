//
//  FinancialHealthView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 21/04/2020.
//

import UI
import CoreFoundationLib

protocol FinancialHealthViewDelegate: AnyObject {
    func didExpandFinancialHealthView()
}

final class FinancialHealthView: UIDesignableView {
    
    @IBOutlet private weak var financialCushionTitleLabel: UILabel!
    @IBOutlet private weak var financialCushionTimeLabel: UILabel!
    @IBOutlet private weak var financialCushionLabel: UILabel!
    @IBOutlet private weak var investmentsLabel: UILabel!
    @IBOutlet private weak var investmentTimeLabel: UILabel!
    @IBOutlet private weak var averageExpensesLabel: UILabel!
    @IBOutlet private weak var pigImageView: UIImageView!
    @IBOutlet private weak var calculateMattresLabel: UILabel!
    @IBOutlet private weak var accountsTitleLabel: UILabel!
    @IBOutlet private weak var investmentsTitleLabel: UILabel!
    @IBOutlet private weak var averageExpensesTitleLabel: UILabel!
    @IBOutlet private weak var adviceImageView: UIImageView!
    @IBOutlet private weak var adviceLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var financialHealthStackView: UIStackView!
    @IBOutlet private weak var investmentsView: UIView!
    @IBOutlet private weak var adviceView: UIView!
    @IBOutlet private weak var stackViewShadowView: UIView!
    @IBOutlet private weak var stackViewRadiusView: UIView!
    @IBOutlet var separationViews: [DottedLineView]!
    @IBOutlet private weak var tipStackView: UIStackView!
    
    private var cushionLevel: Int = 0
    weak var delegate: FinancialHealthViewDelegate?
    
    override func getBundleName() -> String { return "Menu" }

    override func commonInit() {
        super.commonInit()
        
        configureViews()
        configureLabels()
        configureImageViews()
    }
    
    func setFinancialHealth(_ financialHealthViewModel: FinancialHealthViewModel) {
        setAmounts(financialHealthViewModel)
        setCushionTime(financialHealthViewModel)
        setCushionLevel(financialHealthViewModel)
        setInvestmentTime(financialHealthViewModel)
        loadAnimation()
    }
    
    func setTipStackView(_ offer: OfferCustomTipViewModel, action : (() -> Void)?) {
        let view = OfferCustomTipView(frame: .zero)
        view.configView(offer, action: action)
        tipStackView.removeAllArrangedSubviews()
        tipStackView.addArrangedSubview(view)
    }
    
    func hideTipsView() {
        tipStackView.removeAllArrangedSubviews()
    }
}

// MARK: - Private methods

private extension FinancialHealthView {

    func configureViews() {
        self.backgroundColor = .skyGray
        financialHealthStackView.backgroundColor = .clear
        stackViewRadiusView.backgroundColor = .mediumSkyGray
        stackViewRadiusView.layer.cornerRadius = 5
        stackViewRadiusView.layer.borderWidth = 1
        stackViewRadiusView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        stackViewRadiusView.layer.masksToBounds = true
        stackViewShadowView.backgroundColor = .clear
        stackViewShadowView.drawShadow(offset: (x: 1, y: 2), opacity: 0.3, color: .lightSanGray, radius: 2)
        stackViewShadowView.layer.masksToBounds = false
        adviceView.backgroundColor = .paleYellow
        investmentsView.isHidden = true
        adviceView.isHidden = true
        separationViews.forEach {$0.strokeColor = .mediumSkyGray}
    }
    
    func configureLabels() {
        configureTitleLabels()
        configureInfoLabels()
        configureTimeLabels()
        configureAmountsLabels()
    }
    
    func configureTitleLabels() {
        financialCushionTitleLabel.textColor = .darkTorquoise
        financialCushionTitleLabel.configureText(withKey: "analysis_title_mattress",
                                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14.0)))
        
        accountsTitleLabel.textColor = .lisboaGray
        accountsTitleLabel.configureText(withKey: "analysis_label_inYourAccounts",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14.0)))
        
        investmentsTitleLabel.textColor = .lisboaGray
        investmentsTitleLabel.configureText(withKey: "analysis_label_invested",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14.0)))

        averageExpensesTitleLabel.textColor = .lisboaGray
        averageExpensesTitleLabel.configureText(withKey: "analysis_label_averageMonthlyExpense",
                                                andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14.0)))
    }
    
    func configureInfoLabels() {
        calculateMattresLabel.textColor = .lisboaGray
        calculateMattresLabel.configureText(withKey: "analysis_label_calculateMattress",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12.0),
                                                                                                 lineHeightMultiple: 0.92))
        
        adviceLabel.textColor = .lisboaGray
        adviceLabel.configureText(withKey: "analysis_label_advice",
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0),
                                                                                       lineHeightMultiple: 0.88))
    }
    
    func configureTimeLabels() {
        investmentTimeLabel.textColor = .grafite
        investmentTimeLabel.font = UIFont.santander(family: .text, type: .italic, size: 12.0)
        
        financialCushionTimeLabel.textColor = .lisboaGray
    }
    
    func configureAmountsLabels() {
        financialCushionLabel.textColor = .lisboaGray
        financialCushionLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        
        investmentsLabel.textColor = .lisboaGray
        investmentsLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        
        averageExpensesLabel.textColor = .lisboaGray
        averageExpensesLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
    }
    
    func configureImageViews() {
        pigImageView.image = Assets.image(named: "imgPig")
        adviceImageView.image = Assets.image(named: "icnAdvice")

        arrowImageView.image = Assets.image(named: "icnOvalButtonDown")        
        arrowImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedAdviceImageView)))
        arrowImageView.isUserInteractionEnabled = true
    }
    
    func setAmounts(_ financialHealthViewModel: FinancialHealthViewModel) {
        let averageExpenseAttributedText =
            formattedCurrencyFromAmount(Decimal(financialHealthViewModel.averageMonthlyExpenses),
                                        labelFont: averageExpensesLabel.font,
                                        decimalFontSize: 11.0)
        let investmentAttributedText =
            formattedCurrencyFromAmount(financialHealthViewModel.investments,
                                        labelFont: investmentsLabel.font,
                                        decimalFontSize: 11.0)
        let financialCushionAttributedText =
            formattedCurrencyFromAmount(financialHealthViewModel.financialCushion,
                                        labelFont: investmentsLabel.font,
                                        decimalFontSize: 11.0)
        averageExpensesLabel.attributedText = averageExpenseAttributedText
        investmentsLabel.attributedText = investmentAttributedText
        financialCushionLabel.attributedText = financialCushionAttributedText
    }
    
    func setCushionLevel(_ financialHealthViewModel: FinancialHealthViewModel) {
        switch Int(financialHealthViewModel.timeFinancialCushion) {
        case 0..<1:
            cushionLevel = 1
        case 1..<3:
            cushionLevel = 2
        case 3...6:
            cushionLevel = 3
        case 7...12:
            cushionLevel = 4
        default:
            cushionLevel = 5
        }
    }
    
    func setCushionTime(_ financialHealthViewModel: FinancialHealthViewModel) {
        let cushionTime = Int(financialHealthViewModel.timeFinancialCushion)
        guard cushionTime <= 24 else {
            financialCushionTimeLabel.configureText(withKey: "analysis_text_moreYears",
                                                    andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 20.0),
                                                                                                         lineHeightMultiple: 0.82))
            return
        }
        
        if cushionTime == 12 || cushionTime == 24 {
            let cushionText = cushionTime == 12 ? "analysis_text_yearsAccumulated_one" : "analysis_text_yearsAccumulated_other"
            setFinancialCushionText(number: cushionTime/12, text: cushionText)
        } else {
            let cushionText = cushionTime == 1 ? "analysis_text_monthsAccumulated_one" : "analysis_text_monthsAccumulated_other"
            setFinancialCushionText(number: cushionTime, text: cushionText)
        }
    }
    
    func setFinancialCushionText(number: Int, text: String) {
        financialCushionTimeLabel.configureText(withLocalizedString: localized(text, [StringPlaceholder(.number, String(number))]),
                                                andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 20.0),
                                                                                                     lineHeightMultiple: 0.82))
    }
    
    func setInvestmentTime(_ financialHealthViewModel: FinancialHealthViewModel) {
        let investmentTime = financialHealthViewModel.timeInvestment
        guard investmentTime <= 24 else {
            investmentTimeLabel.configureText(withKey: "analysis_text_investedMore")
            return
        }
        
        if investmentTime == 12 || investmentTime == 24 {
            let investmentText = investmentTime == 12 ? "analysis_text_yearExpediture_one" : "analysis_text_yearExpediture_other"
            setInvestmentText(number: investmentTime/12, text: investmentText)
        } else {
            guard investmentTime < 12 && investmentTime > 0 else {
                investmentTimeLabel.configureText(withLocalizedString: localized("analysis_text_monthExpenditure_other", [StringPlaceholder(.number, String(format: "%.0f", investmentTime))]))
                return
            }
            
            let investmentText = investmentTime == 1 ? "analysis_text_monthExpenditure_one" : "analysis_text_monthExpenditure_other"
            setInvestmentText(number: investmentTime, text: investmentText)
        }
    }
    
    func setInvestmentText(number: Double, text: String) {
        investmentTimeLabel.configureText(withLocalizedString: localized(text, [StringPlaceholder(.number, String(number).replace(".", ","))]))
    }
    
    // MARK: - Actions
    
    @objc private func didPressedAdviceImageView() {
        if investmentsView.isHidden {
            delegate?.didExpandFinancialHealthView()
        }
        investmentsView.isHidden = !investmentsView.isHidden
        adviceView.isHidden = !adviceView.isHidden

        let arrowImage = investmentsView.isHidden ? "icnOvalButtonDown" : "icnOvalButtonUp"
        arrowImageView.image = Assets.image(named: arrowImage)
    }
    
    // MARK: - Animation
    
    func loadAnimation() {
        let pigImages = ["imgPig", "imgPig1", "imgPig2", "imgPig3", "imgPig4"]
        animateImage(images: pigImages, index: 0)
    }

    func animateImage(images: [String], index: Int) {
        guard images.count > index else { return }
        guard cushionLevel - 1 >= index else { return }
        
        UIView.transition(with: pigImageView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.pigImageView.image = Assets.image(named: images[index])
        }, completion: { _ in
            self.animateImage(images: images, index: index + 1)
        })
    }
}

extension FinancialHealthView {
    func formattedCurrencyFromAmount(_ amount: Decimal, labelFont: UIFont, decimalFontSize: CGFloat) -> NSAttributedString? {
        let averageAmount = AmountEntity(value: amount, currency: .eur)
        let average = MoneyDecorator(averageAmount, font: labelFont, decimalFontSize: decimalFontSize)
        return average.getFormatedCurrency()
    }
}
