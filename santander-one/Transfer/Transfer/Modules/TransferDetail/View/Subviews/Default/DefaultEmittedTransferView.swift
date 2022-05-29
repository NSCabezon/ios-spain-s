import UIKit
import UI
import CoreFoundationLib

final class DefaultEmittedTransferView: XibView {
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var content: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        configureStyle()
    }
    
    func configureStyle() {
        self.backgroundColor = UIColor.mediumSkyGray
        self.title.textColor = .grafite
        self.title.font = .santander(family: .text, type: .regular, size: 13)
        self.content.textColor = .lisboaGray
        self.content.font = .santander(family: .text, type: .bold, size: 14)
        self.content.numberOfLines = 0
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
    
    func setLastRow() {
        bottomConstraint.constant = 20
    }
}

extension DefaultEmittedTransferView: SetLastRowProtocol {
    func setLastRow(_ last: Bool) {
        if last { setLastRow() }
    }
}
