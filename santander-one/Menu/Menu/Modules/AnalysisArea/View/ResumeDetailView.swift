//
//  ResumeDetailView.swift
//  Menu
//
//  Created by Ignacio González Miró on 03/06/2020.
//

import UIKit
import UI

final class ResumeDetailView: UIDesignableView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func loadTextInDetailView(_ title: String, _ detail: NSAttributedString) {
        self.titleLabel.text = title
        self.descriptionLabel.attributedText = detail
    }
}

private extension ResumeDetailView {
    func setupView() {
        self.backgroundColor = .clear
        self.setLabels()
    }
    
    func setLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 10.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.textAlignment = .center
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.textColor = .grafite
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .bold, size: 28.0)
    }
}
