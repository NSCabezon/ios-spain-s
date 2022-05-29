//
//  InboxActionView.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/15/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol InboxActionViewDelegate: class {
    func didSelectAction(type: InboxActionType)
}

class InboxActionView: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    private var viewModel: InboxActionViewModel!
    private var view: UIView?
    weak var delegate: InboxActionViewDelegate?
    
    convenience init(_ viewModel: InboxActionViewModel) {
        self.init(frame: .zero)
        self.viewModel = viewModel
        self.xibSetup()
        self.setAppearance()
        self.addGestures()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
    }
    
    private func setAppearance() {
        self.iconImageView.image = Assets.image(named: viewModel.imageName)
        self.arrowImageView.image = Assets.image(named: "icnArrowRightGray")
        self.titleLabel.text = viewModel.title
        self.subTitleLabel.text = viewModel.description
        self.addNotificationAlert()
        self.addPendingSolicitude()
        self.topLineView.backgroundColor = UIColor.mediumSkyGray
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 18)
        self.titleLabel.set(lineHeightMultiple: 0.85)
        self.subTitleLabel.font = UIFont.santander(family: .text, type: .light, size: 16)
        self.subTitleLabel.set(lineHeightMultiple: 0.85)
        self.accessibilityIdentifier = viewModel.accessibilityIdentifier
    }
    
    func addNotificationAlert() {
        guard let notificationAlert = viewModel.notificationAlert else { return }
        let alertButton = UIButton()
        let title = NSAttributedString(string: notificationAlert)
        alertButton.setAttributedTitle(title, for: .normal)
        alertButton.titleLabel?.numberOfLines = 0
        alertButton.titleLabel?.textColor = .darkTorquoise
        alertButton.titleLabel?.textAlignment = .left
        alertButton.titleLabel?.fullFit()
        alertButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        alertButton.addTarget(self, action: #selector(didSelectSetupNotificationAlerts), for: .touchUpInside)
        self.stackView.addArrangedSubview(alertButton)
        self.stackViewTopConstraint.constant = 0
    }
    
    func addPendingSolicitude() {
        guard let pendingSolicitud = viewModel.extras?.pendingSolicitude else { return }
        let inboxAlertView = InboxAlertView()
        inboxAlertView.setViewModel(pendingSolicitud)
        self.stackView.addArrangedSubview(inboxAlertView)
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.white
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    @objc func didSelectSetupNotificationAlerts() {
        if viewModel?.extras?.offer != nil {
            self.executeOffer()
        } else if let action = viewModel.action {
            action(viewModel?.extras)
        }
    }
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectAction))
        self.containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didSelectAction() {
        if let action = viewModel.action {
            action(viewModel?.extras)
        } else if let actionType = viewModel.actionType {
            self.delegate?.didSelectAction(type: actionType)
        } else {
            self.executeOffer()
        }
    }
    
    private func executeOffer() {
        guard let offer = viewModel?.extras?.offer else { return }
        self.viewModel?.offerAction?(offer)
    }
}
