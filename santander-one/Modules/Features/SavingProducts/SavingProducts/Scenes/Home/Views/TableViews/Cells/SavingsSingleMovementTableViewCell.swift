import UIKit
import CoreFoundationLib
import UI

class SavingsSingleMovementTableViewCell: UITableViewCell {
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var transactionDetailLabel: UILabel!
    @IBOutlet weak var transactionDetailLabelTop: NSLayoutConstraint!
    @IBOutlet weak var positiveAmountBackgroundView: UIView!
    @IBOutlet weak var highlightView: UIView!
    private var bottomLineSeparator: UIView?
    private var dottedLineSeparator: DottedLineView?
    private enum Constants {
        static let topSpaceFirstRow: CGFloat = 0
        static let topSpace: CGFloat = 14
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bottomLineSeparator?.removeFromSuperview()
        dottedLineSeparator?.removeFromSuperview()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    func configure(withViewModel viewModel: SavingTransaction) {
        transactionDescriptionLabel.scaledFont = UIFont.santander(family: .text, type: .regular, size: 16)
        transactionDescriptionLabel.text = viewModel.description
        transactionDescriptionLabel.textColor = viewModel.isActive ? UIColor.lisboaGray : UIColor.grafite
        transactionAmountLabel.scaledFont = UIFont.santander(family: .text, type: .bold, size: 20)
        transactionAmountLabel.attributedText = viewModel.amountAttributeString
        transactionAmountLabel.accessibilityLabel = viewModel.amountAccessibilityString
        transactionAmountLabel.textColor = viewModel.isActive ? UIColor.lisboaGray : UIColor.grafite
        transactionDetailLabel.scaledFont = UIFont.santander(family: .text, type: .regular, size: 14)
        transactionDetailLabel.text = viewModel.detail
        transactionDetailLabel.textColor = viewModel.isActive ? UIColor.lisboaGray : UIColor.grafite
        transactionDetailLabelTop.constant = !viewModel.isFirstRow ? Constants.topSpace : Constants.topSpaceFirstRow
        positiveAmountBackgroundView.isHidden = !viewModel.mustShowPositiveAmount
        if viewModel.mustShowBottomLineForSingleCell {
            self.addBottomLineSeparator()
        }
        if !viewModel.mustHideSeparationLine {
            self.addDottedLineSeparator()
        }
    }
    
    func setIdentifiers(descriptionIdentifier: String,
                        amountIdentifier: String,
                        detailIdentifier: String) {
        transactionDescriptionLabel.accessibilityIdentifier = descriptionIdentifier
        transactionAmountLabel.accessibilityIdentifier = amountIdentifier
        transactionDetailLabel.accessibilityIdentifier = detailIdentifier
        accessibilityTraits = .button
    }
}

private extension SavingsSingleMovementTableViewCell {
    func setupViews() {
        highlightView.layer.cornerRadius = 2
        positiveAmountBackgroundView.layer.cornerRadius = 4.0
        positiveAmountBackgroundView.backgroundColor = UIColor.greenIce
    }
    
    func addBottomLineSeparator() {
        bottomLineSeparator = UIView()
        bottomLineSeparator?.translatesAutoresizingMaskIntoConstraints = false
        bottomLineSeparator?.backgroundColor = .mediumSkyGray
        contentView.addSubview(bottomLineSeparator!)
        setBottomViewConstraints(bottomLineSeparator)
    }
    
    func addDottedLineSeparator() {
        dottedLineSeparator = DottedLineView()
        dottedLineSeparator?.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dottedLineSeparator!)
        setBottomViewConstraints(dottedLineSeparator, leadingSpace: 15)
    }
    
    func setBottomViewConstraints(_ view: UIView?, leadingSpace: CGFloat = 0) {
        view?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        view?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: leadingSpace).isActive = true
        view?.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        view?.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
