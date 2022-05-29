//
//  PersonalManagerView.swift
//  PersonalManager
//
//  Created by Luis Escámez Sánchez on 21/09/2020.
//

import UIKit
import CoreFoundationLib
import UI

final class PersonalManagerView: DesignableView, CanShowNotificationsBadgeProtocol {
    
    @IBOutlet private weak var headerFrame: UIView!
    @IBOutlet private weak var topSeparationView: UIView!
    @IBOutlet private weak var managerImage: UIImageView!
    @IBOutlet private weak var managerInitials: UILabel!
    @IBOutlet private weak var managerPositionLabel: UILabel!
    @IBOutlet private weak var managerNameLabel: UILabel!
    @IBOutlet private weak var actionsView: ManagerActionsView!
    @IBOutlet private weak var getToKnowMeLabel: UILabel!
    @IBOutlet private weak var rateButton: UIButton!
    @IBOutlet private weak var bottomSeparationView: UIView!
    
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.leafyGreen
        view.isHidden = true
        addSubview(view)
        view.layer.cornerRadius = 8.0
        view.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        view.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        managerImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 6.0).isActive = true
        view.topAnchor.constraint(equalTo: managerImage.topAnchor, constant: 5.0).isActive = true
        view.accessibilityIdentifier = "PersonalManagerViewNotificationBadge"
        return view
    }()
    
    private var managerCode: String?
    weak var delegate: LaunchManagerActionsDelegate?
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureManagerImage()
        configureLabels()
        configureRateButton()
        setAccesibilityIdentifiers()
    }
    
    public func setManagerInfo(_ info: ManagerViewModel, delegate: LaunchManagerActionsDelegate) {
        managerPositionLabel?.text = localized(info.position)
        managerNameLabel?.text = info.formattedName
        managerInitials?.text = info.nameInitials
        setImage(info.image)
        actionsView?.setActions(info.actions, delegate: self)
        managerCode = info.managerCode
        getToKnowMeLabel.isHidden = !info.hasHobbies
        self.delegate = delegate
    }
    
    public func hideBottomSeparation(_ hide: Bool) {
        bottomSeparationView?.isHidden = hide
    }
    
    public func showNotificationBadge(_ show: Bool, in viewIdentifier: String) {
        badgeView.isHidden = !show
        actionsView?.showNotificationBadge(show, in: viewIdentifier)
    }
    
    private func setImage(_ img: String?) {
        guard let img = img, let url = URL(string: img) else { showInitial(); return }
        managerImage.loadImage(urlString: img, placeholder: nil) { [weak self] in
            self?.managerInitials?.isHidden = self?.managerImage.image != nil
        }
    }
    
    private func showInitial() {
        managerInitials?.isHidden = false
    }
    
    private func configureView() {
        headerFrame?.backgroundColor = UIColor.skyGray
        topSeparationView?.backgroundColor = UIColor.mediumSkyGray
        bottomSeparationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureManagerImage() {
        managerImage?.layer.borderColor = UIColor.leafyGreen.cgColor
        managerImage?.layer.borderWidth = 2.0
        managerImage?.layer.cornerRadius = (managerImage?.bounds.height ?? 0.0) / 2.0
        managerImage?.clipsToBounds = true
        managerImage?.backgroundColor = UIColor.white
        managerImage?.contentMode = .scaleAspectFill
        
        managerInitials?.font = UIFont.santander(type: .bold, size: 36.0)
        managerInitials?.textColor = UIColor.lisboaGray
        managerInitials?.backgroundColor = UIColor.clear
        managerInitials?.isHidden = true
        
        managerImage?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openManagerDetail)))
        managerImage?.isUserInteractionEnabled = true
    }
    
    private func configureLabels() {
        managerPositionLabel?.backgroundColor = UIColor.clear
        managerPositionLabel?.font = UIFont.santander(type: .bold, size: 12.0)
        managerPositionLabel?.textColor = .sanGreyDark
        managerPositionLabel?.text = localized("manager_title_officeManager")
        
        managerNameLabel?.backgroundColor = UIColor.clear
        managerNameLabel?.font = UIFont.santander(type: .bold, size: 18.0)
        managerNameLabel?.textColor = UIColor.lisboaGray
        
        getToKnowMeLabel?.font = UIFont.santander(type: .regular, size: 12.0)
        getToKnowMeLabel?.textColor = .darkTorquoise
        getToKnowMeLabel?.text = localized("manager_label_knowMe")
        getToKnowMeLabel?.isUserInteractionEnabled = true
        getToKnowMeLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openManagerDetail)))
    }
    
    private func configureRateButton() {
        rateButton?.setTitle(localized("manager_button_opinator"), for: .normal)
        rateButton?.titleLabel?.font = UIFont.santander(type: .regular, size: 14.0)
        rateButton?.setImage(Assets.image(named: "icnRate"), for: .normal)
        rateButton?.setTitleColor(.sanGreyDark, for: .normal)
        rateButton?.backgroundColor = UIColor.white
        rateButton?.layer.cornerRadius = 5.0
        rateButton?.layer.borderWidth = 1.0
        rateButton?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        rateButton?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        rateButton?.layer.shadowRadius = 2.0
        rateButton?.layer.shadowOpacity = 1.0
        rateButton?.layer.shadowColor = UIColor(white: 213.0 / 255.0, alpha: 0.3).cgColor
        rateButton?.layer.masksToBounds = false
        rateButton?.addTarget(self, action: #selector(rateButtonPressed), for: .touchUpInside)
    }
    
    @objc private func rateButtonPressed() {
        guard let managerCode = managerCode else { return }
        delegate?.rateManager(withCode: managerCode)
    }
    
    @objc private func openManagerDetail() {
        guard let managerCode = managerCode else { return }
        delegate?.imageActionForManager(withCode: managerCode)
    }
    
    private func setAccesibilityIdentifiers() {
        getToKnowMeLabel?.accessibilityIdentifier = "manager_label_knowMe"
        managerImage?.accessibilityIdentifier = "manager_title_banker"
        managerNameLabel?.accessibilityIdentifier = "manager_title_name"
        rateButton?.accessibilityIdentifier = "btnRateYourManager"
    }
}

extension PersonalManagerView: ManagerActionDelegate {
    func didSelect(_ action: ManagerAction) {
        guard let managerCode = managerCode else { return }
        delegate?.start(action, managerType: .personal, forManagerWithCode: managerCode)
    }
}
