//
//  DoblePhoneStolenCallView.swift
//  PersonalManager
//
//  Created by Juan Carlos López Robles on 3/4/20.
//

import UIKit

public protocol DoublePhoneViewDelegate: AnyObject {
    func didSelectDobleCall(_ phoneNumber: String)
}

public final class DoublePhoneView: XibView {
    public weak var delegate: DoublePhoneViewDelegate?
    
    @IBOutlet private var phoneImageViews: [UIImageView]!
    @IBOutlet private weak var firstPhoneLabel: UILabel!
    @IBOutlet private weak var firstPhoneButton: UIButton!
    @IBOutlet private weak var secondPhoneLabel: UILabel!
    @IBOutlet private weak var secondPhoneButton: UIButton!
    @IBOutlet private var arrowImageViews: [UIImageView]!
    
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
    
    public func setViewModels(_ viewModels: (top: PhoneViewModel, bottom: PhoneViewModel)) {
        firstPhoneLabel.text = viewModels.top.phone
        secondPhoneLabel.text = viewModels.bottom.phone
        setNeedsLayout()
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, topButton: String? = nil, bottomButton: String? = nil) {
        self.accessibilityIdentifier = container
        self.firstPhoneButton.accessibilityIdentifier = topButton
        self.secondPhoneButton.accessibilityIdentifier = bottomButton
    }
    
    private func syncFonts() {
        firstPhoneLabel.refreshFont(force: true, margin: 0.0)
        secondPhoneLabel.refreshFont(force: true, margin: 0.0)
        let minFont = min(firstPhoneLabel.font.pointSize, secondPhoneLabel.font.pointSize)
        firstPhoneLabel.font = firstPhoneLabel.font.withSize(minFont)
        secondPhoneLabel.font = secondPhoneLabel.font.withSize(minFont)
    }
    
    private func setAppearance() {
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
    
    @IBAction func didSelectTopView(_ sender: Any) {
        guard let phone = firstPhoneLabel.text else { return }
        delegate?.didSelectDobleCall(phone.trim())
    }
    
    @IBAction func didSelectBottomView(_ sender: Any) {
        guard let phone = secondPhoneLabel.text else { return }
        delegate?.didSelectDobleCall(phone.trim())
    }
}
