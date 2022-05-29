//
//  SantanderDropDownTableView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

class SantanderDropDownTableView: UITableView   {

    var theme: SantanderDropDownColorTheme = .white {
        didSet {
            switch theme {
            case .white:
                backgroundColor = .white
            case .sky:
                backgroundColor = .lightSky
            }
        }
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorStyle = .none
        bounces = false
    }

    func setupView() {
        isUserInteractionEnabled = true
        register(GlobileDropdownCell.self, forCellReuseIdentifier: "dropcell")
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 3.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.mediumSky.cgColor
    }
}
