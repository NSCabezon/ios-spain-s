//
//  AtmDateSectionView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 07/09/2020.
//

import UIKit
import CoreFoundationLib
import Foundation
import UI

final class AtmDateSectionView: XibView {
        
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var fecha: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()

    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()

    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        gestureRecognizers?.forEach({ removeGestureRecognizer($0) })
        super.addGestureRecognizer(gestureRecognizer)
    }

    func setupView() {
        self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
    }
    
    func configure(withDate date: LocalizedStylableText) {
        self.fecha.textColor = .bostonRed
        self.fecha.configureText(withLocalizedString: date,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14)))
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
    }
    
    func hideSeparator(_ hide: Bool) {
        self.separatorView.isHidden = hide
    }
}
