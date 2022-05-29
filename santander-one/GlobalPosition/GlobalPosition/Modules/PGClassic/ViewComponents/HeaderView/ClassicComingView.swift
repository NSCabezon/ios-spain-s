//
//  ClassicComingView.swift
//  GlobalPosition
//
//  Created by Carlos Monfort Gómez on 25/11/2019.
//

import UIKit
import CoreFoundationLib

class ClassicComingView: DesignableView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configView()
    }
    
    func configView() {
        backgroundView.layer.cornerRadius = 2.0
        backgroundView.backgroundColor = .darkTorquoise
        titleLabel.text = localized("generic_label_shortly")
        titleLabel.font = .santander(family: .text, type: .bold, size: 10)
        titleLabel.textColor = .white
    }
}
