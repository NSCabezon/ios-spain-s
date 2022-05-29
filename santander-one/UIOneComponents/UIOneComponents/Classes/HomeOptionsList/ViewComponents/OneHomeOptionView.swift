//
//  OneHomeOptionView.swift
//  UIOneComponents
//
//  Created by Carlos Monfort Gómez on 24/11/21.
//

import UI
import UIKit
import CoreFoundationLib

public class OneHomeOptionView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var iconImageView: UIImageView!
    private var viewModel: SendMoneyHomeOption?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModel(_ viewModel: SendMoneyHomeOption) {
        self.viewModel = viewModel
        self.titleLabel.configureText(withKey: viewModel.title)
        self.descriptionLabel.configureText(withKey: viewModel.description)
        self.iconImageView.image = Assets.image(named: viewModel.imageName)
        self.iconImageView.contentMode = .scaleAspectFill
        self.setAccessibilityIds()
        self.setNeedsDisplay()
    }
}

private extension OneHomeOptionView {
    func setupView() {
        self.arrowImageView.image = Assets.image(named: "icnArrowRightGray")
        self.setLabelStyle(to: self.titleLabel, font: .oneB300Bold)
        self.setLabelStyle(to: self.descriptionLabel, font: .oneB200Regular)
        self.addGestures()
    }
    
    func setLabelStyle(to label: UILabel, font: FontName) {
        label.font = .typography(fontName: font)
        label.textColor = .oneLisboaGray
        label.numberOfLines = 0
    }
    
    func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didSelectAction))
        tapGesture.numberOfTouchesRequired = 1
        self.containerView.addGestureRecognizer(tapGesture)
        self.containerView.isExclusiveTouch = true
    }
    
    @objc func didSelectAction() {
        guard let actionType = self.viewModel?.actionType else { return }
        self.viewModel?.action?(actionType)
    }
    
    func setAccessibilityIds() {
        guard let viewModel = self.viewModel else { return }
        self.containerView.accessibilityIdentifier = viewModel.accessibilityIdentifier
        self.titleLabel.accessibilityIdentifier = viewModel.title
        self.descriptionLabel.accessibilityIdentifier = viewModel.description
        self.iconImageView.accessibilityIdentifier = viewModel.imageName
        self.arrowImageView.accessibilityIdentifier = AccessibilityOneComponent.sendMoneyHomeViewIcnArrowImage
    }
}
