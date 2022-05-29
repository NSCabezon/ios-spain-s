import CoreFoundationLib
import UI

public class HelpCenterEmergencyView: XibView {
    @IBOutlet public weak var stackView: UIStackView!
    @IBOutlet public weak var stolenCardView: UIView?
    @IBOutlet public weak var flipView: ContactsFlipView?
    @IBOutlet public weak var flipCallView: UIView?
    @IBOutlet public weak var phoneNumbersStackView: UIStackView?
    private var isStolenViewEnabled = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func disableStolenCardView() {
        self.stolenCardView?.removeFromSuperview()
        self.stolenCardView = nil
    }
    
    private func setupView() {
        stolenCardView?.drawShadow(offset: (x: 0, y: 3), opacity: 0.05, color: UIColor.black, radius: 0.0)
        stolenCardView?.drawBorder(cornerRadius: 5.0, color: UIColor.clear, width: 1.0)
        stolenCardView?.layer.masksToBounds = false
        flipView?.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnStolenCard.rawValue
        flipCallView?.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterBtnStolenCardFlipped.rawValue
    }
}
