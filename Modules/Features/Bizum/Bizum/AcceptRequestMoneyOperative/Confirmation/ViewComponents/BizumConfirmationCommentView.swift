//
//  BizumConfirmationCommentView.swift
//  Bizum
//
//  Created by Cristobal Ramos Laina on 03/12/2020.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class BizumConfirmationCommentView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var lisboaTextFieldView: LisboaTextView!
    private var style = LisboaTextFieldStyle.default

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func getComment() -> String? {
        return self.lisboaTextFieldView.getText()
    }
}

private extension BizumConfirmationCommentView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel?.set(localizedStylableText: localized("bizum_label_addComment"))
        self.lisboaTextFieldView.setupView(placeholder: localized("bizum_hint_commentary"))
        self.setAccessibilityIdentifiers()
    }

    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityBizumConfirmation.titleComment
        self.lisboaTextFieldView.accessibilityIdentifier = AccessibilityBizumConfirmation.commentView
        self.view?.accessibilityIdentifier = AccessibilityBizumConfirmation.bizumInputCommentaryContainer
    }
}
