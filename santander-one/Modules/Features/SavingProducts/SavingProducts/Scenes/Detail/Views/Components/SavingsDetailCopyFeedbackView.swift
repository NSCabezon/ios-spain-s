//
//  SavingsDetailCopyFeedbackView.swift
//  SavingProducts
//
//  Created by Simón Aparicio on 7/5/22.
//

import UIKit
import UI
import CoreFoundationLib
import OpenCombine

class SavingsDetailCopyFeedbackView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ticIcon: UIImageView!
    @IBOutlet weak var closeIcon: UIImageView!
    let closeTappedSubject = PassthroughSubject<Void, Never>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setAppearance()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAppearance()
    }
    @IBAction func didCloseIconTapped() {
        closeTappedSubject.send()
    }
}

private extension SavingsDetailCopyFeedbackView {
    func setupView() {
        ticIcon.image = Assets.image(named: "icnCheckToast")
        closeIcon.image = Assets.image(named: "icnCloseGray")
        titleLabel.font = .santander(family: .text, type: .regular, size: 14)
        titleLabel.textColor = .lisboaGray
        titleLabel.configureText(withKey: "generic_label_copy")
    }
    func setAppearance() {
        setAccesibilityIdentifers()
    }
    func setAccesibilityIdentifers() {
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityIdentifier = AccessibilitySavingDetails.copyTitle.rawValue
        ticIcon.accessibilityIdentifier = AccessibilitySavingDetails.icnCheckToast.rawValue
    }
}

