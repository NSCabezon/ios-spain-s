import CoreFoundationLib
import UI

public protocol HelpCenterEmergencyFootViewDelegate: AnyObject {
    func didTap()
}

public class HelpCenterEmergencyFootView: XibView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var arrowImageView: UIImageView!
    @IBOutlet weak private var containerView: UIView!
    public weak var delegate: HelpCenterEmergencyFootViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addGesture()
    }
    
    private func setupView() {
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        self.titleLabel.textColor = .darkTorquoise
        self.arrowImageView.image = Assets.image(named: "icnArrowBlueDown")
        self.setAccessibilityIdentifiers()
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.containerView.addGestureRecognizer(tap)
    }
    
    public func setViewModel(_ viewModel: HelpCenterEmergencyFootViewModel) {
        self.titleLabel.set(localizedStylableText: viewModel.title)
        UIView.animate(withDuration: 0.3, delay: 0, options: .showHideTransitionViews, animations: {
            self.arrowImageView.transform = viewModel.isExpanded ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
        })
    }

    @objc private func didTap() {
        delegate?.didTap()
    }
    
    private func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = "helpCenter_label_moreOptions"
    }
}
