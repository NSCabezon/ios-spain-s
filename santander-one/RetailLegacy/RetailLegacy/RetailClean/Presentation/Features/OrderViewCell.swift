//

import UIKit

class OrderViewCell: BaseViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var sideTitleLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rightSpaceSeparatorConstraint: NSLayoutConstraint!
    @IBOutlet weak var separator: UIView!
    
    var status: LocalizedStylableText? {
        get {
            return nil
        }
        set {
            guard let newValue = newValue else { return }
            statusLabel.set(localizedStylableText: newValue)
        }
    }
    
    var ticker: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var sideTitle: LocalizedStylableText? {
        get {
            return nil
        }
        set {
            guard let newValue = newValue else { return }
            sideTitleLabel.set(localizedStylableText: newValue)
        }
    }
    
    var isFirstCell: Bool {
        get {
            return false
        }
        set {
            dayLabel.isHidden = !newValue
            monthLabel.isHidden = !newValue
            separator.isHidden = newValue
        }
    }
    
    var shouldDisplayDate: Bool {
        get {
            return dayLabel.isHidden
        }
        set {
            dayLabel.isHidden = !newValue
            monthLabel.isHidden = !newValue
            rightSpaceSeparatorConstraint.constant = newValue ? 12 : 54
        }
    }
    
    func orderStatus(status: OrderStatus) {
        statusView.isHidden = status == .undefined
        
        let color: UIColor
        switch status {
        case .cancelled:
            color = .sanRed
        case .pending:
            color = .orange
        case .executed:
            color = .green
        case .negotiated:
            color = .topaz
        case .rejected:
            color = .purple
        case .undefined:
            color = .uiWhite
        }
        statusView.layer.borderColor = color.cgColor
        statusLabel.textColor = color
    }
    
    func cellStatus(_ status: CellState) {
        loadingImageView.isHidden = status == .done
        subtitleLabel.isHidden = status == .waitingData
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusView.layer.borderWidth = 1.0
        statusView.layer.borderColor = UIColor.sanRed.cgColor
        
        loadingImageView.setSecondaryLoader(scale: 2.0)
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingImageView.setSecondaryLoader(scale: 2.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.layer.cornerRadius = 5
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    
    override func setSelected(_ selected: Bool, animated: Bool) { }
}

extension OrderViewCell {
    
    enum CellState {
        case done
        case waitingData
    }
    
}
