//
//  AdvantageView.swift
//  PersonalManager
//
//  Created by alvola on 07/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class AdvantageView: DesignableView {

    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var subtitle: UILabel?
    @IBOutlet weak var labelsContainerStackView: UIStackView!
    
    public func setTitle(_ title: LocalizedStylableText, subtitle: LocalizedStylableText, icon: String) {
        self.title?.set(localizedStylableText: title)
        self.subtitle?.set(localizedStylableText: subtitle)
        self.icon?.image = Assets.image(named: icon)
        centerIconToTitleIfNeeded()
    }
    
    override func commonInit() {
        super.commonInit()
        configureLabels()
    }
    
    private func configureLabels() {
        title?.backgroundColor = UIColor.clear
        title?.font = UIFont.santander(type: .light, size: 20.0)
        title?.textColor = UIColor.lisboaGray
        
        subtitle?.backgroundColor = UIColor.clear
        subtitle?.font = UIFont.santander(size: 14.0)
        subtitle?.textColor = UIColor.mediumSanGray
    }
    
    private func centerIconToTitleIfNeeded() {
        if subtitle?.text?.isEmpty ?? false {
            let labelTag = 100
            subtitle?.tag = labelTag
            deleteFromStackViewView(with: labelTag)
        }
    }
    
    private func deleteFromStackViewView(with tag: Int) {
        let view = labelsContainerStackView.arrangedSubviews.filter { $0.tag == tag }.first
        view?.removeFromSuperview()
        setNeedsLayout()
    }
}
