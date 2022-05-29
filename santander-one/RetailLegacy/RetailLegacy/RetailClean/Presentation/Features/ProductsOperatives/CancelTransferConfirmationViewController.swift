import UIKit

protocol CancelTransferConfirmationPresenterProtocol: Presenter {
    func cancelButtonTouched()
    func confirmButtonTouched()
}

class CancelTransferConfirmationViewController: BaseViewController<CancelTransferConfirmationPresenterProtocol> {
    
    // MARK: - Outlets
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var summaryStackView: UIStackView!
    
    @IBOutlet weak var cancelButton: WhiteButton!
    @IBOutlet weak var confirmButton: RedButton!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "CancelTransferConfirmationDialog"
    }
    
    var alertTitle: LocalizedStylableText? {
        didSet {
            if let text = alertTitle {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var summaryInfo: [SummaryItem]? {
        didSet {
            updateSummaryInfo()
        }
    }
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        
        gradientView.backgroundColor = .sanGreyDark
        gradientView.alpha = 0.5
        
        containerView.drawRoundedAndShadowed()
        containerView.layer.cornerRadius = 5
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 18), textAlignment: .left))
    }
    
    func configure(cancelWithTitle cancelButtonTitle: LocalizedStylableText) {
        cancelButton.set(localizedStylableText: cancelButtonTitle, state: .normal)
        cancelButton.onTouchAction = { [weak self] _ in
            self?.presenter.cancelButtonTouched()
        }
    }
    
    func configure(confirmWithTitle confirmButtonTitle: LocalizedStylableText) {
        confirmButton.set(localizedStylableText: confirmButtonTitle, state: .normal)
        confirmButton.onTouchAction = { [weak self] _ in
            self?.presenter.confirmButtonTouched()
        }
    }
    
    // MARK: - Private methods
    
    private func updateSummaryInfo() {
        summaryInfo?.forEach({ item in
            guard let itemView = UINib(nibName: item.nibName, bundle: .module).instantiate(withOwner: nil, options: nil).first as? UIView else {
                return
            }
            item.configure(view: itemView)
            summaryStackView.addArrangedSubview(itemView)
            summaryStackView.addArrangedSubview(createSeparator())
        })
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .lisboaGray
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        return separator
    }
}
