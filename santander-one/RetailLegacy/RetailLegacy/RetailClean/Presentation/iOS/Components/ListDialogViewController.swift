import UIKit

protocol ListDialogPresenterProtocol: Presenter {
    func didSelectClose()
}

final class ListDialogViewController: BaseViewController<ListDialogPresenterProtocol> {
    
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var dialogContainerView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var bottomButton: RedButton!
    @IBOutlet private weak var bottomButtonContainer: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    override static var storyboardName: String {
        return "ListDialog"
    }
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        gradientView.backgroundColor = .sanGreyDark
        gradientView.alpha = 0.5
        dialogContainerView.layer.cornerRadius = 5
        dialogContainerView.layer.masksToBounds = true
        topSeparatorView.backgroundColor = .sanRed
        bottomSeparatorView.backgroundColor = UIColor.sanGrey.withAlphaComponent(0.25)
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        setupDialogShadow()
    }
    
    func setCloseButtonHidden(_ isHidden: Bool) {
        closeButton.isHidden = isHidden
    }
    
    func setBottomButtonHidden(_ isHidden: Bool) {
        bottomButtonContainer.isHidden = isHidden
    }
    
    func setBottomButtonTitle(_ title: LocalizedStylableText) {
        bottomButton.set(localizedStylableText: title, state: .normal)
    }
    
    func show(title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 18), textAlignment: .left))
    }
    
    func show(items: [ListDialogItemViewModel]) {
        items.forEach {
            switch $0.localizedItem {
            case .text(let text): addText(text)
            case .styledText(let text, let style): addText(text, style: style)
            case .listItem(let text, let margin): addListItem(text, margin: margin)
            }
        }
    }
    
    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        presenter.didSelectClose()
    }
}

private extension ListDialogViewController {
    
    func addText(_ text: LocalizedStylableText, style: LabelStylist? = nil) {
        let label = UILabel()
        label.font = .latoRegular(size: 14)
        if let style = style {
            label.applyStyle(style)
        }
        label.set(localizedStylableText: text)
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
    }
    
    func addListItem(_ text: LocalizedStylableText, margin: ListDialogItem.Margin) {
        let itemStackView = UIStackView()
        itemStackView.axis = .horizontal
        itemStackView.distribution = .fill
        let roundedViewContainerView = UIView()
        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.layer.cornerRadius = 3
        roundedView.backgroundColor = .sanRed
        roundedViewContainerView.addSubview(roundedView)
        let builder = NSLayoutConstraint.Builder()
        builder += roundedView.topAnchor.constraint(equalTo: roundedViewContainerView.topAnchor, constant: 5 + CGFloat(margin.top))
        builder += roundedView.leftAnchor.constraint(equalTo: roundedViewContainerView.leftAnchor, constant: CGFloat(margin.left))
        builder += roundedView.rightAnchor.constraint(equalTo: roundedViewContainerView.rightAnchor, constant: -10 - CGFloat(margin.right))
        builder += roundedView.heightAnchor.constraint(equalToConstant: 6)
        builder += roundedView.widthAnchor.constraint(equalToConstant: 6)
        let label = UILabel()
        label.font = .latoRegular(size: 14)
        label.textColor = .sanGreyDark
        label.set(localizedStylableText: text)
        label.numberOfLines = 0
        itemStackView.addArrangedSubview(roundedViewContainerView)
        itemStackView.addArrangedSubview(label)
        stackView.addArrangedSubview(itemStackView)
        builder.activate()
    }
    
    // MARK: - Private methods
    
    private func setupDialogShadow() {
        guard let superview = dialogContainerView.superview else {
            return
        }
        
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = dialogContainerView.backgroundColor
        background.layer.cornerRadius = 5
        background.layer.shadowOpacity = 0.5
        background.layer.shadowColor = UIColor.uiBlack.cgColor
        background.layer.shadowRadius = 14.0
        
        let builder = NSLayoutConstraint.Builder()
            .add(background.topAnchor.constraint(equalTo: dialogContainerView.topAnchor))
            .add(background.leadingAnchor.constraint(equalTo: dialogContainerView.leadingAnchor))
            .add(background.widthAnchor.constraint(equalTo: dialogContainerView.widthAnchor))
            .add(background.heightAnchor.constraint(equalTo: dialogContainerView.heightAnchor))
        
        superview.insertSubview(background, belowSubview: dialogContainerView)
        
        builder.activate()
    }
}
