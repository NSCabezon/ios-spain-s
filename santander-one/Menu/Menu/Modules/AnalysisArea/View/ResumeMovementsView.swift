//
//  ResumeMovementsView.swift
//  UI
//
//  Created by Ignacio González Miró on 03/06/2020.
//

import UI
import CoreFoundationLib

final class ResumeMovementsView: UIDesignableView {
    @IBOutlet weak private var stackView: UIStackView!
    @IBOutlet weak private var detailView: ResumeDetailView!
    @IBOutlet weak private var extraView: ResumeDetailView!
    @IBOutlet weak var baseStackView: UIView!
    @IBOutlet weak private var verticalSeparator: UIView!
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func singleView() {
        if self.stackView.arrangedSubviews.count <= 2 {
            self.stackView.removeArrangedSubview(self.extraView)
        }
        
        self.hideExtraView()
    }
    
    func configView(_ title: String, _ detail: NSAttributedString) {
        self.detailView.loadTextInDetailView(title, detail)
    }
    
    func configExtraView(_ title: String, _ detail: NSAttributedString) {
        self.extraView.loadTextInDetailView(title, detail)
        self.extraView.isHidden = false
    }
}

private extension ResumeMovementsView {
    func setupView() {
        self.verticalSeparator.isHidden = false
        self.verticalSeparator.backgroundColor = .mediumSkyGray
        self.baseStackView.backgroundColor = .clear
        self.stackView.roundedWithColor(.mediumSkyGray, radius: 4.0)
    }
    
    func hideExtraView() {
        self.extraView.isHidden = true
        self.verticalSeparator.isHidden = true
        self.configExtraView("", NSAttributedString(string: ""))
    }
}
