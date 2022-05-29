import UIKit
import UI
import OpenCombine
import CoreFoundationLib

final class DoublePhoneSelectView: XibView {
    
    @IBOutlet private var phoneImageViews: [UIImageView]!
    @IBOutlet private weak var firstPhoneLabel: UILabel!
    @IBOutlet private weak var firstPhoneButton: UIButton!
    @IBOutlet private weak var secondPhoneLabel: UILabel!
    @IBOutlet private weak var secondPhoneButton: UIButton!
    @IBOutlet private var arrowImageViews: [UIImageView]!
    
    let onTouchButtonSubject = PassthroughSubject<String, Never>()
    private var menuOptionRepresentable: PublicMenuOptionRepresentable?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        view?.layoutSubviews()
        view?.subviews.forEach({ $0.layoutSubviews() })
        syncFonts()
    }
    
    func configure(withModel model: PublicMenuOptionRepresentable, topPhone: String, bottomPhone: String) {
        self.menuOptionRepresentable = model
        firstPhoneLabel.text = topPhone
        secondPhoneLabel.text = bottomPhone
        setNeedsLayout()
        self.setIdentifiers()
    }
    
    @IBAction func didSelectTopView(_ sender: Any) {
        guard let phone = firstPhoneLabel.text else { return }
        self.onTouchButtonSubject.send(phone.trim())
    }
    
    @IBAction func didSelectBottomView(_ sender: Any) {
        guard let phone = secondPhoneLabel.text else { return }
        self.onTouchButtonSubject.send(phone.trim())
    }
}

private extension DoublePhoneSelectView {
    func syncFonts() {
        firstPhoneLabel.refreshFont(force: true, margin: 0.0)
        secondPhoneLabel.refreshFont(force: true, margin: 0.0)
        let minFont = min(firstPhoneLabel.font.pointSize, secondPhoneLabel.font.pointSize)
        firstPhoneLabel.font = firstPhoneLabel.font.withSize(minFont)
        secondPhoneLabel.font = secondPhoneLabel.font.withSize(minFont)
    }
    
    func setAppearance() {
        view?.drawRoundedAndShadowedNew(radius: 4,
                                        borderColor: .mediumSkyGray,
                                        widthOffSet: 1,
                                        heightOffSet: 2)
        firstPhoneLabel.baselineAdjustment = .alignCenters
        firstPhoneLabel.lineBreakMode = .byClipping
        secondPhoneLabel.baselineAdjustment = .alignCenters
        secondPhoneLabel.lineBreakMode = .byClipping
        arrowImageViews.forEach {
            $0.image = Assets.image(named: "icnArrowWhite")}
        phoneImageViews.forEach {
            $0.image = Assets.image(named: "icnPhoneWhite2")}
    }
    
    func setIdentifiers() {
        guard let identifier = self.menuOptionRepresentable?.accessibilityIdentifier else { return }
        self.accessibilityIdentifier = "\(identifier)TwoView"
        self.phoneImageViews[0].accessibilityIdentifier = "\(identifier)TwoTopIcon"
        self.firstPhoneLabel.accessibilityIdentifier = "\(identifier)TwoTopTitle"
        self.arrowImageViews[0].accessibilityIdentifier = "\(identifier)TwoTopRightIcon"
        self.phoneImageViews[1].accessibilityIdentifier = "\(identifier)TwoBottomIcon"
        self.secondPhoneLabel.accessibilityIdentifier = "\(identifier)TwoBottomTitle"
        self.arrowImageViews[1].accessibilityIdentifier = "\(identifier)TwoBottomRightIcon"
    }
}
