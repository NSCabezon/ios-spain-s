//
//  FullViewLoading.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 18/06/2020.
//

import UI
import CoreFoundationLib

class FullViewLoading: UIDesignableView {
    @IBOutlet weak private var loadingView: UIImageView!
    @IBOutlet weak private var loadingText: UILabel!
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        setupViews()
    }
}

private extension FullViewLoading {
    func setupViews() {
        self.backgroundColor = .white
        self.loadingText.font = .santander(family: .text, type: .italic, size: 16.0)
        self.loadingText.textColor = .lisboaGray
        self.loadingText.configureText(withKey: "loading_label_transactionsLoading")
        loadingView.setSecondaryLoader(scale: 0.8)
    }
}
