//
//  DefaultWithSubtitleView.swift
//  Transfer
//
//  Created by alvola on 15/07/2021.
//

import UIKit
import UI
import CoreFoundationLib

final class DefaultWithSubtitleView: XibView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var content: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    func set(title: String) {
        self.title.configureText(withKey: title)
        self.title.accessibilityIdentifier = title
    }

    func set(content: NSAttributedString, accessibilityIdentifier: String) {
        self.content.attributedText = content
        self.content.accessibilityIdentifier = accessibilityIdentifier
    }

    func set(content: LocalizedStylableText, accessibilityIdentifier: String) {
        self.content.configureText(withLocalizedString: content)
        self.content.accessibilityIdentifier = accessibilityIdentifier
    }

    func set(subtitle: String) {
        self.subtitle.configureText(withKey: subtitle)
        self.subtitle.accessibilityIdentifier = subtitle
    }

    func setLastRow() {
        bottomConstraint.constant += 12
    }
}

extension DefaultWithSubtitleView: SetLastRowProtocol {
    func setLastRow(_ last: Bool) {
        if last { setLastRow() }
    }
}

private extension DefaultWithSubtitleView {
    private func setupView() {
        self.backgroundColor = UIColor.mediumSkyGray
        title.textColor = .grafite
        title.font = .santander(size: 13)
        content.textColor = .lisboaGray
        content.font = .santander(type: .bold, size: 14)
        subtitle.textColor = .grafite
        subtitle.font = .santander(size: 13)
    }
}
