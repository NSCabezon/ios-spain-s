//
//  ComingFeaturesEmptyView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 05/06/2020.
//

import Foundation
import UI
import CoreFoundationLib
class ComingFeaturesEmptyView: XibView {
    
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.emptyImageView.image = Assets.image(named: "imgLeaves")
        self.subtitleLabel.text = localized("shortly_text_emptyIdea")
        self.titleLabel.font = .santander(family: .headline, type: .regular, size: 20)
        self.titleLabel.textColor = .lisboaGray
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.subtitleLabel.textColor = .lisboaGray
        
    }
    
    func setTitle(title: String) {
        self.titleLabel.configureText(withKey: title)
    }
    
}
