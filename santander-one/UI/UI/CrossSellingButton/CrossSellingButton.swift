//
//  CrossSellingButton.swift
//  UI-UI
//
//  Created by Margaret López Calderón on 11/8/21.
//

import UIKit
import CoreFoundationLib

public struct CrossSellingButtonViewModel {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

public protocol CrossSellingPressableButtonDelegate: AnyObject {
    func didTapCrossSellingButton()
}

public final class CrossSellingButton: XibView {

    @IBOutlet private weak var containerButton: UIView! {
        didSet {
            self.containerButton.layer.cornerRadius = 4.0
            self.containerButton.layer.borderWidth = 1.0
            self.containerButton.layer.borderColor = UIColor.mediumSkyGray.cgColor
            self.containerButton.backgroundColor = .clear
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.textColor = .darkTorquoise
            self.titleLabel.font = UIFont.santander(size: 16.0)
        }
    }
    @IBOutlet private weak var arrowView: UIImageView! {
        didSet {
            self.arrowView.image = Assets.image(named: "icnArrowRightG")
        }
    }
    
    @IBOutlet private weak var pressableCrossSellingButton: PressableButton! {
        didSet {
            let crossSellingTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCrossSellingButton))
            self.pressableCrossSellingButton.addGestureRecognizer(crossSellingTapGesture)
            self.pressableCrossSellingButton.backgroundColor = .clear
            self.pressableCrossSellingButton.setup(style: pressableButtonStyle)
        }
    }
    
    private var pressableButtonStyle: PressableButtonStyle {
        return PressableButtonStyle(
            pressedColor: .skyGray,
            cornerRadius: 4.0
        )
    }
    public weak var delegate: CrossSellingPressableButtonDelegate?
    
    // MARK: Initializer
    
    public init(viewModel: CrossSellingButtonViewModel) {
        super.init(frame: .zero)
        self.configureView(viewModel)
    }
    
    public func configureView(_ viewModel: CrossSellingButtonViewModel) {
        self.titleLabel.configureText(withKey: viewModel.title)
        self.setAccessiblityIdentifiers()
    }
    
    public func clearTitle() {
        self.titleLabel.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @objc
    func didTapCrossSellingButton() {
        self.delegate?.didTapCrossSellingButton()
    }
}

private extension CrossSellingButton {
    
    func setupView() {
        self.backgroundColor = .clear
    }
    
    func setAccessiblityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityOthers.crossSellingView.rawValue
        self.pressableCrossSellingButton.accessibilityIdentifier = AccessibilityOthers.crossSellingButton.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityOthers.crossSellingTitle.rawValue
        self.arrowView.accessibilityIdentifier = AccessibilityOthers.crossSellingImage.rawValue
    }

}
