//
//  LoadingView.swift
//  Login
//
//  Created by Iván Estévez on 02/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class LoadingView: XibView {

    @IBOutlet private weak var loadingImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension LoadingView {
    func setupView() {
        loadingImageView.setSecondaryLoader()
        titleLabel.text = localized("generic_popup_loadingContent")
        titleLabel.font = .santander(family: .text, type: .regular, size: 22)
        titleLabel.textColor = .lisboaGray
        descriptionLabel.text = localized("loading_label_moment")
        descriptionLabel.font = .santander(family: .text, type: .regular, size: 15)
        descriptionLabel.textColor = .grafite
    }
}
