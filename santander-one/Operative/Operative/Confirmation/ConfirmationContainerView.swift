import CoreFoundationLib
import UI

public final class ConfirmationContainerView: XibView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var actionButton: UIButton!
    @IBOutlet weak private var pointLine: PointLine!
    @IBOutlet weak private var stackView: UIStackView!
    @IBOutlet weak private var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomLayoutConstraint: NSLayoutConstraint!
    private var viewModel: ConfirmationContainerViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public convenience init(_ viewModel: ConfirmationContainerViewModel) {
        self.init(frame: .zero)
        setup(viewModel)
    }
    
    public func setup(_ viewModel: ConfirmationContainerViewModel) {
        self.viewModel = viewModel
        if viewModel.position == .first {
            topLayoutConstraint.constant = 19
        }
        if viewModel.position == .last {
            self.bottomLayoutConstraint.constant = 26
            self.pointLine.isHidden = true
        }
        self.titleLabel.configureText(withLocalizedString: viewModel.title,
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13)))
        if let action = viewModel.action {
            self.actionButton.setTitle(action.title, for: .normal)
        } else {
            self.actionButton.isHidden = true
        }
        self.pointLine.isHidden = viewModel.position == .last
        self.addViews(viewModel.views)
    }
}

private extension ConfirmationContainerView {
    @IBAction func actionButtonSelected(_ sender: UIButton) {
        self.viewModel?.action?.action()
    }
    
    func setupView() {
        self.titleLabel.textColor = .grafite
        self.actionButton.setTitleColor(.darkTorquoise, for: .normal)
        self.actionButton.titleLabel?.font = .santander(family: .text, size: 14)
        self.setupAccessibilityId()
    }
    
    func addViews(_ views: [UIView]) {
        views.forEach(self.stackView.addArrangedSubview)
    }
    
    func setupAccessibilityId() {
        self.titleLabel.accessibilityIdentifier = AccessibilityConfirmationView.titleLabel.rawValue
        self.actionButton.accessibilityIdentifier = AccessibilityConfirmationView.actionButton.rawValue
    }
}
