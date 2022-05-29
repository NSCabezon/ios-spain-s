//
//  VirtualAssistantUnableHeaderView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 27/02/2020.
//

import UI
import CoreFoundationLib

class VirtualAssistantUnableHeaderView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var virtualAssistantImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        configureViews()
        configureLabels()
    }
    
    private func configureViews() {
        var gradientLayer: CAGradientLayer!
        let colorTop = UIColor.lightNavy
        let colorBottom = UIColor.darkTorquoise
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.cornerRadius = 4
        virtualAssistantImageView.image = Assets.image(named: "icnVirtualAssistant")
    }
    
    private func configureLabels() {
        titleLabel.text = localized("helpCenter_title_virtualAssistant")
    }
}
