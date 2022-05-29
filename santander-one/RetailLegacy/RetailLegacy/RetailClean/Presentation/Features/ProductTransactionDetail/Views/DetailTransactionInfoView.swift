import UIKit
import UI

protocol DetailTransactionInfoViewDelegate: class {
    func seePdfDidTouched()
}

class DetailTransactionInfoView: UIView {

    @IBOutlet weak var transactionTitleLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var seeLabel: UILabel!
    @IBOutlet weak var seePdf: UIView!
    @IBOutlet weak var infoView: UIStackView!
    @IBOutlet weak var titleLeftLabel: UILabel!
    @IBOutlet weak var infoLeftLabel: UILabel!
    @IBOutlet weak var titleRightLabel: UILabel!
    @IBOutlet weak var infoRightLabel: UILabel!
    @IBOutlet weak var belowAmountButton: RedButton!
    @IBOutlet weak var loadingViewContainer: UIView!
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sideTextTitleLabel: UILabel!
    @IBOutlet weak var sideTextDescriptionLabel: UILabel!
    @IBOutlet weak var pdfImage: UIImageView!
    weak var delegate: DetailTransactionInfoViewDelegate?
    @IBOutlet weak var paperImage: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let view = Bundle.module?.loadNibNamed("DetailTransactionInfoView", owner: self, options: nil)?.first as? UIView {
            view.frame = bounds
            view.embedInto(container: self)
        }
    }
            
    override func awakeFromNib() {
        super.awakeFromNib()
        setLabelStyles()
        setSeePdfView()
        setMainView()
        pdfImage.image = Assets.image(named: "icnPdfButton")
        paperImage.image = Assets.image(named: "bg-detail")
    }
    
    func createInfoLine(info: TransactionLine) {
        let leftStackView = setLeftStackView(info)
        let stackView = setMainStackView()
        stackView.addArrangedSubview(leftStackView)
        if let rightInfo = info.1 {
            let rightStackView = setRightStackView(info)
            stackView.addArrangedSubview(rightStackView)
        }
        infoView.insertArrangedSubview(stackView, at: infoView.arrangedSubviews.count - 2)
    }
    
    @IBAction func seePdfAction(_ sender: UITapGestureRecognizer) {
        delegate?.seePdfDidTouched()
    }
}

private extension DetailTransactionInfoView {
    // MARK: Init view
    func setLabelStyles() {
        let transactionTitleLabelStyle = LabelStylist(
            textColor: .sanGreyDark,
            font: .latoBold(size: 20.0)
        )
        transactionTitleLabel.applyStyle(transactionTitleLabelStyle)
        let aliasLabelStyle = LabelStylist(
            textColor: .sanGreyMedium,
            font: .latoBold(size: 14.0)
        )
        aliasLabel.applyStyle(aliasLabelStyle)
        let amountLabelStyle = LabelStylist(
            textColor: .sanGreyDark,
            font: .latoBold(size: 37.0)
        )
        amountLabel.applyStyle(amountLabelStyle)
        let seeLabelStyle = LabelStylist(
            textColor: .sanRed,
            font: .latoRegular(size: 14.0)
        )
        seeLabel.applyStyle(seeLabelStyle)
        seeLabel.textAlignment = .center
        let belowAmountButtonStyle = LabelStylist(
            textColor: .uiWhite,
            font: .latoBold(size: 14),
            textAlignment: .center
        )
        belowAmountButton.titleLabel?.applyStyle(belowAmountButtonStyle)
    }
    
    func setSeePdfView() {
        seePdf.layer.cornerRadius = seePdf.frame.size.height / 2
        seePdf.layer.borderColor = UIColor.sanRed.cgColor
        seePdf.layer.borderWidth = 1.0
    }
    
    func setMainView() {
        layer.shadowColor = UIColor.uiBlack.cgColor
        layer.shadowOpacity = 0.17
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: -1)
    }
    
    // MARK: Set StackViews
    func setLeftStackView(_ info: TransactionLine) -> UIStackView {
        let titleLeftLabel = setTitleLeftLabel(info)
        let infoLeftLabel = setInfoLeftLabel(info)
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.distribution = .fillEqually
        leftStackView.alignment = .leading
        leftStackView.spacing = 2.0
        leftStackView.addArrangedSubview(titleLeftLabel)
        leftStackView.addArrangedSubview(infoLeftLabel)
        return leftStackView
    }
    
    func setMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }
    
    func setRightStackView(_ info: TransactionLine) -> UIStackView {
        let titleRightLabel = setTitleRightLabel(info)
        let infoRightLabel = setInfoRightLabel(info)
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.distribution = .fillEqually
        rightStackView.alignment = .trailing
        rightStackView.spacing = 2.0
        rightStackView.addArrangedSubview(titleRightLabel)
        rightStackView.addArrangedSubview(infoRightLabel)
        return rightStackView
    }
    
    // MARK: Set Labels
    func setTitleLeftLabel(_ info: TransactionLine) -> UILabel {
        let labelStyle = LabelStylist(
            textColor: .sanGreyMedium,
            font: .latoRegular(size: 14.0)
        )
        let titleLeftLabel = UILabel()
        titleLeftLabel.applyStyle(labelStyle)
        titleLeftLabel.set(localizedStylableText: info.0.title)
        return titleLeftLabel
    }
    
    func setInfoLeftLabel(_ info: TransactionLine) -> UILabel {
        let labelStyle = LabelStylist(
            textColor: .sanGreyDark,
            font: .latoRegular(size: 14.0)
        )
        let infoLeftLabel = UILabel()
        infoLeftLabel.applyStyle(labelStyle)
        infoLeftLabel.text = info.0.info
        return infoLeftLabel
    }
    
    func setTitleRightLabel(_ info: TransactionLine) -> UILabel {
        guard let rightInfo = info.1 else {
            return UILabel()
        }
        let labelStyle = LabelStylist(
            textColor: .sanGreyMedium,
            font: .latoRegular(size: 14.0),
            textAlignment: .right
        )
        let titleRightLabel = UILabel()
        titleRightLabel.applyStyle(labelStyle)
        titleRightLabel.set(localizedStylableText: rightInfo.title)
        return titleRightLabel
    }
    
    func setInfoRightLabel(_ info: TransactionLine) -> UILabel {
        guard let rightInfo = info.1 else {
            return UILabel()
        }
        let labelStyle = LabelStylist(
            textColor: .sanGreyDark,
            font: .latoRegular(size: 14.0),
            textAlignment: .right
        )
        let infoRightLabel = UILabel()
        infoRightLabel.applyStyle(labelStyle)
        infoRightLabel.text = rightInfo.info
        return infoRightLabel
    }
}
