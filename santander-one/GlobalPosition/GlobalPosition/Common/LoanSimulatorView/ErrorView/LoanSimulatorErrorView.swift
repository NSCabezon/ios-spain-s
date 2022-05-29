//
//  LoanSimulatorErrorView.swift
//  GlobalPosition
//
//  Created by César González Palomino on 31/01/2020.
//

import UI

final class LoanSimulatorErrorView: UIView {
    private var iconImage = UIImageView(image: Assets.image(named: "icnDanger"))
    private var text: String
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        self.drawBorder(color: .mediumSkyGray)
        addSubview(iconImage)
        iconImage.translatesAutoresizingMaskIntoConstraints = false

        iconImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let label = UILabel()
        label.text = self.text
        label.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        label.textColor = UIColor.bostonRed
        label.textAlignment = .left
        label.numberOfLines = 0
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10.0).isActive = true
        label.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 8.0).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true    }
}
