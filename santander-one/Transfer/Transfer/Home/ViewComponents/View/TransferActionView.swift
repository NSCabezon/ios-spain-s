//
//  TransferActionView.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/18/19.
//

import UIKit
import UI
import CoreFoundationLib

final class TransferActionView: UIView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    private var viewModel: TransferActionViewModel?
    private var view: UIView?
    private var groupedAccessibilityElements: [Any]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.setAppearance()
        self.addGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
        self.setAppearance()
        self.addGestures()
    }
    
    func updateViewModel(_ viewModel: TransferActionViewModel) {
        self.viewModel = viewModel
        self.titleLabel.configureText(withKey: viewModel.title)
        self.descriptionLabel.configureText(withKey: viewModel.description)
        self.iconImageView.image = Assets.image(named: viewModel.imageName)
        self.iconImageView.contentMode = .scaleAspectFill
        self.setAccessibilityIds()
        self.setNeedsDisplay()
    }
}

private extension TransferActionView {
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setAppearance() {
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.containerView.layer.shadowRadius = 0.0
        self.containerView?.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
        self.arrowImageView.image = Assets.image(named: "icnArrowRightGray")
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
        self.arrowImageView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewIcnArrowImage
    }
}

extension TransferActionView {
    public override var accessibilityElements: [Any]? {
        get {
            if let groupedAccessibilityElements = groupedAccessibilityElements {
                return groupedAccessibilityElements
            }
            
            let elements = self.groupElements(
                [
                    self.titleLabel,
                    self.descriptionLabel
                ],
                traits: .button
            )
            self.groupedAccessibilityElements = elements
            return groupedAccessibilityElements
        }
        set {
            self.groupedAccessibilityElements = newValue
        }
    }
}
