import UIKit
import UI
import CoreFoundationLib

protocol OperativeSelectorLauncher: AnyObject {
    func launch()
    func isEnabledMoreOptions() -> Bool
}

final class SmartGPOptionsBar: DesignableView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var plusButtonContainer: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    weak var delegate: OperativeSelectorLauncher?
    
    override func commonInit() {
        super.commonInit()
        configureView()
        self.setAccessibility()
    }
    
    private func configureView() {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        plusButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        plusButton.layer.cornerRadius = plusButton.frame.height/2
        plusButton.layer.masksToBounds = true
        let sidesConstant = containerView.frame.width * 0.065
        leftConstraint.constant = sidesConstant
        rightConstraint.constant = sidesConstant
    }
    
    func setOptions(_ options: [GpOperativesViewModel]?) {
        leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let options = options, options.count > 3 else { return }
        let leftButtons = options[0...1]
        let rightButtons = options[2...3]
        leftButtons.forEach {
            let button = createButtonWithOption($0)
            button.setExtraLabelContent($0.highlightedInfo)
            button.isAccessibilityElement = true
            leftStackView.addArrangedSubview(button)
        }
        plusButton.addTarget(self, action: #selector(launchOperativeSelector), for: .touchUpInside)
        rightButtons.forEach {
            let button = createButtonWithOption($0)
            button.setExtraLabelContent($0.highlightedInfo)
            button.isAccessibilityElement = true
            rightStackView.addArrangedSubview(button)
        }
        containerView.layer.cornerRadius = containerView.frame.height/2
        plusButton.setImage(Assets.image(named: "icnPlusWhite"), for: .normal)
        self.setAccessibility()
    }
    
    private func createButtonWithOption(_ option: GpOperativesViewModel) -> ActionButton {
        let button = ActionButton()
        button.setAppearance(withStyle: ActionButtonStyle.smartBarStyle)
        button.setViewModel(option)
        button.addSelectorAction(target: self, #selector(executeAssociatedAction(_:)))
        return button
    }
    
    func setPlusButtonHidden(_ isHidden: Bool, animated: Bool) {
        guard animated else { return self.plusButtonIsHidden(isHidden) }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.plusButtonIsHidden(isHidden)
            self.containerStackView.layoutIfNeeded()
        })
    }
    
    private func plusButtonIsHidden(_ isHidden: Bool) {
        self.plusButtonContainer.alpha = isHidden ? 0 : 1
        self.plusButtonContainer.isHidden = isHidden
    }
    
    private func setAccessibility() {
        self.plusButton.isAccessibilityElement = true
        self.plusButton.accessibilityIdentifier = AccessibilityGlobalPosition.obtionBarPlusButton
        self.plusButton.accessibilityLabel = localized("voiceover_moreShortcuts")
    }
    
    @objc private func launchOperativeSelector() {
        if delegate?.isEnabledMoreOptions() == true {
            delegate?.launch()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    @objc func executeAssociatedAction(_ sender: UITapGestureRecognizer) {
        guard
            let button = sender.view as? ActionButton,
            let viewModel = button.getViewModel() as? GpOperativesViewModel
            else { return }
        viewModel.action?(viewModel.actionType, viewModel.entity)
    }
}
