//
//  TotalSavingsView.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 01/04/2020.
//

import UI

class TotalSavingsView: UIDesignableView {
    @IBOutlet weak var savingsTitleLabel: UILabel!
    @IBOutlet weak var bottomLine: UIView!
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func updateInfoWith(_ model: TotalSavingsViewModel) {
        if let localizedText = model.localizedTitle() {
            self.savingsTitleLabel.configureText(withLocalizedString: localizedText)
        }
    }
}

private extension TotalSavingsView {
    func setupView() {
        self.savingsTitleLabel.setSantanderTextFont(type: .regular, size: 16, color: .lisboaGray)
        self.bottomLine.backgroundColor = .mediumSkyGray
    }
}
