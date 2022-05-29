//
//  BankerManagerView.swift
//  PersonalManager
//
//  Created by alvola on 10/02/2020.
//

import UIKit
import CoreFoundationLib
import UI

final class BankerManagerView: DesignableView, CanShowNotificationsBadgeProtocol {
    
    @IBOutlet private weak var headerFrame: UIView!
    @IBOutlet private weak var getToKnowMeLabel: UILabel!
    @IBOutlet private weak var topSeparationView: UIView!
    @IBOutlet private weak var managerImage: UIImageView!
    @IBOutlet private weak var managerInitials: UILabel!
    @IBOutlet private weak var managerPositionLabel: UILabel!
    @IBOutlet private weak var managerNameLabel: UILabel!
    @IBOutlet private weak var actionsView: BankerManagerActionsView!
    @IBOutlet private weak var rateButton: UIButton!
    @IBOutlet private weak var bottomSeparationView: UIView!
    private var actionButtonsDisabled: Bool = false
    
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.leafyGreen
        view.isHidden = true
        addSubview(view)
        view.layer.cornerRadius = 8.0
        view.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        view.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        managerImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 9.5).isActive = true
        view.topAnchor.constraint(equalTo: managerImage.topAnchor, constant: 5.0).isActive = true
        view.accessibilityIdentifier = "PersonalManagerViewNotificationBadge"
        return view
    }()
    
    private var managerCode: String?
    weak var delegate: LaunchManagerActionsDelegate?
    
    private var viewStyle: ManagerViewStyle? {
        didSet {
            applyStyle()
        }
    }
    
    override func commonInit() {
        super.commonInit()
        configureManagerImage()
        configureLabels()
        configureRateButton()
        setAccesibilityIdentifiers()
    }
    
    public func setManagerInfo(_ info: ManagerViewModel, delegate: LaunchManagerActionsDelegate) {
        managerPositionLabel.text = localized(info.position)
        managerNameLabel.text = info.formattedName
        managerInitials.text = info.nameInitials
        setImage(info.image)
        actionsView?.setActions(info.actions, delegate: self, style: viewStyle ?? .bankerStyle)
        managerCode = info.managerCode
        getToKnowMeLabel.isHidden = !info.hasHobbies
        self.delegate = delegate
    }
    
    public func showNotificationBadge(_ show: Bool, in viewIdentifier: String) {
        badgeView.isHidden = !show
        actionsView.showNotificationBadge(show, in: viewIdentifier)
    }
    
    public func setStyle(_ style: ManagerViewStyle) {
        self.viewStyle = style
    }
}

private extension BankerManagerView {
     func setImage(_ img: String?) {
        guard let img = img, let url = URL(string: img) else { showInitial(); return }
        managerImage.loadImage(urlString: img, placeholder: nil) { [weak self] in
            self?.managerInitials.isHidden = self?.managerImage.image != nil
        }
    }
    
    func showInitial() {
        managerInitials.isHidden = false
    }
    
    func applyStyle() {
        headerFrame.backgroundColor = viewStyle?.headerFrameBackgroundColor
        topSeparationView.backgroundColor = viewStyle?.separationColor
        contentView?.backgroundColor = viewStyle?.contentViewColor
        managerImage.layer.borderColor = viewStyle?.imageBorderColor
        managerPositionLabel.textColor = viewStyle?.positionLabelColor
        managerNameLabel.textColor = viewStyle?.nameLabelColor
        getToKnowMeLabel.textColor = viewStyle?.knowMeLabelColor
        rateButton.setTitleColor(viewStyle?.rateButtonTextColor, for: .normal)
        rateButton.setImage(viewStyle?.rateButtonIcon, for: .normal)
        rateButton.backgroundColor = viewStyle?.rateButtonBackgroundColor
        rateButton.layer.shadowColor = viewStyle?.rateButtonShadowColor
        if let borderColor = viewStyle?.rateButtonBorderColor {
            rateButton.layer.borderWidth = 1
            rateButton.layer.borderColor = borderColor
        }
    }
    
    func configureManagerImage() {
        managerImage.layer.borderWidth = 2.0
        managerImage.layer.cornerRadius = (managerImage?.bounds.height ?? 0.0) / 2.0
        managerImage.clipsToBounds = true
        managerImage.backgroundColor = UIColor.white
        managerImage.contentMode = .scaleAspectFill
        managerInitials.font = UIFont.santander(type: .bold, size: 36.0)
        managerInitials.textColor = UIColor.lisboaGray
        managerInitials.backgroundColor = UIColor.clear
        managerInitials.isHidden = true
        managerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openManagerDetail)))
        managerImage.isUserInteractionEnabled = true
    }
    
    func configureLabels() {
        managerPositionLabel.font = UIFont.santander(type: .bold, size: 12.0)
        managerPositionLabel.text = localized("manager_title_personalManager")
        managerNameLabel.font = UIFont.santander(type: .bold, size: 18.0)
        getToKnowMeLabel.font = UIFont.santander(type: .regular, size: 12.0)
        getToKnowMeLabel.text = localized("manager_label_knowMe")
        getToKnowMeLabel.isUserInteractionEnabled = true
        getToKnowMeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openManagerDetail)))
    }
    
    func configureRateButton() {
        rateButton.setTitle(localized("manager_button_opinator"), for: .normal)
        rateButton.titleLabel?.font = UIFont.santander(type: .regular, size: 14.0)
        rateButton.tintColor = .white
        rateButton.layer.cornerRadius = 5.0
        rateButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        rateButton.layer.shadowRadius = 2.0
        rateButton.layer.shadowOpacity = 1.0
        rateButton.layer.masksToBounds = false
        rateButton.addTarget(self, action: #selector(rateButtonPressed), for: .touchUpInside)
    }
    
    @objc func rateButtonPressed() {
        guard let managerCode = managerCode else { return }
        delegate?.rateManager(withCode: managerCode)
    }
    
    @objc func openManagerDetail() {
        guard let managerCode = managerCode else { return }
        delegate?.imageActionForManager(withCode: managerCode)
    }
    
    func setAccesibilityIdentifiers() {
        getToKnowMeLabel.accessibilityIdentifier = "manager_label_knowMe"
        managerImage.accessibilityIdentifier = "manager_title_banker"
        managerNameLabel.accessibilityIdentifier = "manager_title_name"
        rateButton.accessibilityIdentifier = "btnRateYourManager"
    }
    
    private func disableButtonsInteractionTemporarily() {
        actionButtonsDisabled = true
        Async.after(seconds: 0.5) { [weak self] in
                self?.actionButtonsDisabled = false
        }
    }
}

extension BankerManagerView: ManagerActionDelegate {
    func didSelect(_ action: ManagerAction) {
        guard let managerCode = managerCode, !actionButtonsDisabled else { return }
        delegate?.start(action, managerType: .banker, forManagerWithCode: managerCode)
        self.disableButtonsInteractionTemporarily()
    }
}

enum ManagerViewStyle {
    case bankerStyle
    case personalStyle
    
    var headerFrameBackgroundColor: UIColor {
        switch self {
        case .bankerStyle:
            return .blueAnthracita
        case .personalStyle:
            return .skyGray
        }
    }
    
    var separationColor: UIColor {
        switch self {
        case .bankerStyle:
            return .blueAnthracita
        case .personalStyle:
            return .mediumSkyGray
        }
    }
    
    var contentViewColor: UIColor {
        switch self {
        case .bankerStyle:
            return UIColor(red: 51/255, green: 59/255, blue: 69/255, alpha: 1)
        case .personalStyle:
            return .clear
        }
    }
    
    var knowMeLabelColor: UIColor {
        switch self {
        case .bankerStyle:
            return .white
        case .personalStyle:
            return .darkTorquoise
        }
    }
    
    var positionLabelColor: UIColor {
        switch self {
        case .bankerStyle:
            return .white
        case .personalStyle:
            return .sanGreyDark
        }
    }
    
    var nameLabelColor: UIColor {
        switch self {
        case .bankerStyle:
            return .white
        case .personalStyle:
            return .lisboaGray
        }
    }
    
    var imageBorderColor: CGColor {
        switch self {
        case .bankerStyle:
            return UIColor.leafyGreen.cgColor
        case .personalStyle:
            return UIColor.limeGreen.cgColor
        }
    }
    
    var rateButtonIcon: UIImage? {
        switch self {
        case .bankerStyle:
            return Assets.image(named: "icnRatePb")
        case .personalStyle:
            return Assets.image(named: "icnRate")
        }
    }
    
    var rateButtonTextColor: UIColor {
        switch self {
        case .bankerStyle:
            return .white
        case .personalStyle:
            return .sanGreyDark
        }
    }
    
    var rateButtonBackgroundColor: UIColor {
        switch self {
        case .bankerStyle:
            return UIColor.mediumSkyGray.withAlphaComponent(0.2)
        case .personalStyle:
            return .white
        }
    }
    
    var rateButtonBorderColor: CGColor? {
        switch self {
        case .bankerStyle:
            return nil
        case .personalStyle:
            return UIColor.mediumSkyGray.cgColor
        }
    }
    
    var rateButtonShadowColor: CGColor {
        return UIColor.atmsShadowGray.withAlphaComponent(0.3).cgColor
    }
    
    var actionViewBackgroundColor: UIColor {
        switch self {
        case .bankerStyle:
            return UIColor.mediumSkyGray.withAlphaComponent(0.2)
        case .personalStyle:
            return .white
        }
    }
    
    var actionViewBorderColor: CGColor? {
        switch self {
        case .bankerStyle:
            return nil
        case .personalStyle:
            return UIColor.mediumSkyGray.cgColor
        }
    }
    
    var actionViewTitleLabelColor: UIColor {
        switch self {
        case .bankerStyle:
            return .white
        case .personalStyle:
            return .sanGreyDark
        }
    }
    
    var actionViewSubtitleLabelColor: UIColor {
        switch self {
        case .bankerStyle:
            return .white
        case .personalStyle:
            return .grafite
        }
    }
    
    var actionViewImageTintColor: UIColor? {
        switch self {
        case .bankerStyle:
            return .white
        case .personalStyle:
            return nil
        }
    }
}
