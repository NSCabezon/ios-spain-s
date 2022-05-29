//
//  OfficeManagerView.swift
//  PersonalManager
//
//  Created by alvola on 11/02/2020.
//

import UIKit
import CoreFoundationLib

final class OfficeManagerView: DesignableView {
    @IBOutlet private weak var headerFrame: UIView!
    @IBOutlet private weak var topSeparationView: UIView!
    @IBOutlet private weak var managerImage: UIImageView!
    @IBOutlet private weak var managerInitials: UILabel!
    @IBOutlet private weak var managerPositionLabel: UILabel!
    @IBOutlet private weak var managerNameLabel: UILabel!
    @IBOutlet private weak var actionsView: ManagerActionsView?
    
    private var managerCode: String?
    weak var delegate: LaunchManagerActionsDelegate?
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureManagerImage()
        configureLabels()
        setAccesibilityIdentifiers()
    }
    
    public func setManagerInfo(_ info: ManagerViewModel, delegate: LaunchManagerActionsDelegate) {
        managerPositionLabel?.text = localized(info.position)
        managerNameLabel?.text = info.formattedName
        managerInitials?.text = info.nameInitials
        setImage(info.image)
        actionsView?.setActions(info.actions, delegate: self)
        managerCode = info.managerCode
        self.delegate = delegate
    }
    
    private func setImage(_ img: String?) {
        guard let img = img, let url = URL(string: img) else { showInitial(); return }
        managerImage?.setImage(url: img, completion: { [weak self] image in
            self?.managerInitials?.isHidden = image != nil
        })
    }
    
    private func showInitial() {
        managerInitials?.isHidden = false
    }
    
    private func configureView() {
        headerFrame?.backgroundColor = UIColor.skyGray
        topSeparationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureManagerImage() {
        managerImage?.layer.borderColor = UIColor.santanderRed.cgColor
        managerImage?.layer.borderWidth = 2.0
        managerImage?.layer.cornerRadius = (managerImage?.bounds.height ?? 0.0) / 2.0
        managerImage?.clipsToBounds = true
        managerImage?.backgroundColor = UIColor.white
        managerImage?.contentMode = .scaleAspectFill

        managerInitials?.font = UIFont.santander(type: .bold, size: 19.0)
        managerInitials?.textColor = UIColor.santanderRed
        managerInitials?.backgroundColor = UIColor.clear
        managerInitials?.isHidden = true
    }
    
    private func configureLabels() {
        managerPositionLabel?.backgroundColor = UIColor.clear
        managerPositionLabel?.font = UIFont.santander(type: .bold, size: 12.0)
        managerPositionLabel?.textColor = UIColor.sanGreyDark
        managerPositionLabel?.text = localized("manager_title_officeManager")

        managerNameLabel?.backgroundColor = UIColor.clear
        managerNameLabel?.font = UIFont.santander(type: .bold, size: 18.0)
        managerNameLabel?.textColor = UIColor.lisboaGray
    }
    
    private func setAccesibilityIdentifiers() {
        managerImage?.accessibilityIdentifier = "manager_title_banker"
        managerNameLabel?.accessibilityIdentifier = "manager_title_name"
    }
}

extension OfficeManagerView: ManagerActionDelegate {
    func didSelect(_ action: ManagerAction) {
        guard let managerCode = managerCode else { return }
        delegate?.start(action, managerType: .office, forManagerWithCode: managerCode)
    }
}
