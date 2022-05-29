import UIKit
import UI
import CoreFoundationLib

public protocol HelpCenterImageLabelViewDelegate: AnyObject {
    func didSelect(_ viewModel: HelpCenterEmergencyItemViewModel)
}

public final class HelpCenterImageLabelView: XibView {
    public weak var delegate: HelpCenterImageLabelViewDelegate?
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet public weak var callView: UIView!
    @IBOutlet weak private var helpCenterImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var phoneImageView: UIImageView!
    private var viewModel: HelpCenterEmergencyItemViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        addGesture()
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didSelectView))
        self.containerView.addGestureRecognizer(tap)
    }
    
    public func setViewModels(_ viewModels: HelpCenterEmergencyItemViewModel) {
        self.viewModel = viewModels
        self.titleLabel.set(localizedStylableText: viewModels.title)
        self.helpCenterImageView.image = Assets.image(named: viewModels.icon)
        self.phoneImageView.image = Assets.image(named: "icnCornerPhone3")
        self.phoneImageView.isHidden = !viewModels.isPhoneView
        setAccesibilityIdentifiers()
        containerView.drawRoundedAndShadowedNew()
        
        phoneImageView.drawShadow(offset: (x: 0, y: 2), opacity: 0.05, color: UIColor.black, radius: 0.0)
        phoneImageView.drawBorder(cornerRadius: 5.0, color: UIColor.clear, width: 1.0)
        phoneImageView.layer.masksToBounds = false
    }
    
    private func setupView() {
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        self.titleLabel.textColor = .lisboaGray
        self.callView.isHidden = true
    }
    
    @objc func didSelectView() {
        guard let viewModel = viewModel else { return }
        if viewModel.isPhoneView {
            self.flipView()
        } else {
            delegate?.didSelect(viewModel)
        }
    }
    
    private func flipView() {
        UIView.flipView(viewToShow: callView, viewToHide: containerView, flipBackIn: 2.0) {
            self.phoneImageView.isHidden = self.containerView.isHidden
        }
        
        Async.after(seconds: 0.3) { [weak self] in
            self?.phoneImageView.isHidden = true
        }
        
        Async.after(seconds: 2.5) { [weak self] in
            self?.phoneImageView.isHidden = false
        }
    }
    
    private func setAccesibilityIdentifiers() {
        containerView.accessibilityIdentifier = viewModel?.action.accesibilityId()
        callView.accessibilityIdentifier = viewModel?.action.accesibilityIdFlipped()
        if let action = viewModel?.action {
            self.accessibilityIdentifier = "helpCenter_moreEmergency_view_\(action)"
            titleLabel.accessibilityIdentifier = "helpCenter_moreEmergency_title_\(action)"
            phoneImageView.isAccessibilityElement = true
            setAccessibility { self.phoneImageView.isAccessibilityElement = false }
            phoneImageView.accessibilityIdentifier = "helpCenter_moreEmergency_phoneImage_\(action)"
        }
    }
}

extension HelpCenterImageLabelView: AccessibilityCapable { }
