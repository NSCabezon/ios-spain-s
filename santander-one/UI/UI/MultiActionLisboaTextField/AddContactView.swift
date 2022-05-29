//
//  AddContactView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 30/12/2020.
//

import CoreFoundationLib
public final class AddContactView: UIView {
    private lazy var buttonLabel: UILabel = {
        let btnLabel = UILabel()
        btnLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .white)
        btnLabel.textAlignment = .center
        btnLabel.adjustsFontSizeToFitWidth = true
        btnLabel.minimumScaleFactor = 0.5
        btnLabel.numberOfLines = 1
        btnLabel.text = localized("generic_button_add")
        btnLabel.translatesAutoresizingMaskIntoConstraints = false
        return btnLabel
    }()
    
    private lazy var buttonView: UIView = {
        let btnView = UIView()
        btnView.drawBorder(cornerRadius: 4.0, color: .darkTorquoise, width: 1.0)
        btnView.backgroundColor = .darkTorquoise
        btnView.translatesAutoresizingMaskIntoConstraints = false
        btnView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return btnView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .clear
        self.buttonView.addSubview(buttonLabel)
        NSLayoutConstraint.activate([
            buttonLabel.leadingAnchor.constraint(equalTo: self.buttonView.leadingAnchor, constant: 6.0),
            buttonLabel.trailingAnchor.constraint(equalTo: self.buttonView.trailingAnchor, constant: -6.0),
            buttonLabel.topAnchor.constraint(equalTo: self.buttonView.topAnchor, constant: 5.0),
            buttonLabel.bottomAnchor.constraint(equalTo: self.buttonView.bottomAnchor, constant: -5.0)
        ])
        self.addSubview(self.buttonView)
        NSLayoutConstraint.activate([
            self.buttonView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.buttonView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0),
            self.buttonView.heightAnchor.constraint(equalToConstant: 30.0),
            self.buttonView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self
    }
}
