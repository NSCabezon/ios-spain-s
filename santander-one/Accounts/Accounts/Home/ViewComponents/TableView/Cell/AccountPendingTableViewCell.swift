import UIKit
import UIOneComponents

final class AccountPendingTableViewCell: UITableViewCell {
    @IBOutlet private weak var dashedLineView: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var highlightView: UIView!
    @IBOutlet private weak var amountLabelView: OneLabelHighlightedView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.highlightView.backgroundColor = .white
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.dashedLineView.dotted(with: [1, 1, 1, 1], color: UIColor.mediumSkyGray.cgColor)
    }
    
    private func setupViews() {
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        self.descriptionLabel.textColor = .grafite
        self.dateLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.dateLabel.textColor = .grafite
    }
    
    func setupHighlightBackgroundColor(_ color: UIColor) {
        self.highlightView.backgroundColor = color
    }
}

extension AccountPendingTableViewCell: AccountTransactionTableViewCell {
    func mustHideDiscontinueLine(_ isHidden: Bool) {
        self.dashedLineView.isHidden = isHidden
    }
    
    func configure(withViewModel viewModel: TransactionViewModel) {
        guard let pendingViewModel = viewModel as? AccountPendingTransactionViewModel else {
            return
        }
        self.descriptionLabel.text = pendingViewModel.title
        self.amountLabelView.attributedText = pendingViewModel.amountAttributeString
        self.amountLabelView.style = (pendingViewModel.amountValue ?? 0) > 0 ? .lightGreen : .clear
        self.dateLabel.text = pendingViewModel.formattedDate?.capitalized
    }
}
