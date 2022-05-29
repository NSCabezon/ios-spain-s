//
//  GlobileDropdownButton.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

class GlobileDropdownButton: UIButton{

    fileprivate lazy var mainView: UIView = {
        let mv = UIView(frame: .zero)
        return mv
    }()

    lazy var labelView: UILabel = {
        let view = UILabel()
        view.textColor = .darkGray
        view.font = .santanderText(type: .regular, with: 17)
        view.textAlignment = .left
        view.text = "Select an option..."
        view.isHidden = false
        return view
    }()

    lazy var floatingLabel: UILabel = {
        let label = UILabel()
        label.font = .santanderText(type: .regular, with: 13)
        label.textColor = .mediumSanGray
        label.text = " "
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    fileprivate lazy var separatorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1.0, height: 49.0))
        view.backgroundColor = .mediumSky
        view.isHidden = false
        return view
    }()

    fileprivate lazy var iconImageview: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        iv.isHidden = false
        iv.image = UIImage(fromModuleWithName: "dropdown_arrow")
        iv.contentMode = .center
        return iv
    }()

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

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()

    }

    func setupView() {

        layer.borderWidth = 1.0
        layer.borderColor = UIColor.mediumSky.cgColor
        layer.cornerRadius = 3.0
        titleLabel?.isHidden = true
        addSubviews()
    }

    func addSubviews() {

        mainView.addSubview(labelView)
        mainView.addSubview(floatingLabel)
        mainView.addSubview(separatorView)
        mainView.addSubview(iconImageview)
        addSubview(mainView)

        iconImageview.anchor( top: mainView.topAnchor, right: mainView.rightAnchor, bottom: mainView.bottomAnchor)
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        iconImageview.translatesAutoresizingMaskIntoConstraints = false

        iconImageview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        iconImageview.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageview.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageview.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: iconImageview.leadingAnchor, constant: -8).isActive = true

        floatingLabel.anchor(left: mainView.leftAnchor, top: mainView.topAnchor)
        
        floatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        floatingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        floatingLabel.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: -15).isActive = true
        floatingLabel.isHidden = true
        
        labelView.anchor(left: mainView.leftAnchor, top: floatingLabel.bottomAnchor)
        
        labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        labelView.topAnchor.constraint(equalTo: floatingLabel.bottomAnchor, constant: -10).isActive = true
        labelView.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: -5).isActive = true
    
    }

    func rotateUpArrow() {
        UIView.animate(withDuration: 0.3, animations: {
            self.iconImageview.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        })
    }

    func rotateDownArrow() {
        UIView.animate(withDuration: 0.3, animations: {
            self.iconImageview.transform = CGAffineTransform(rotationAngle: (2.0 * .pi) / 180.0)
        })
    }
    
    func setPlaceholderText(text: String){
        labelView.text = text
        if ((floatingLabel.text != nil) && !(floatingLabel.text!.isEmpty) && (floatingLabel.text! != " ")){
            
            floatingLabel.isHidden = false
            
            labelView.anchor(left: mainView.leftAnchor, top: floatingLabel.bottomAnchor, bottom: mainView.bottomAnchor)
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
            labelView.topAnchor.constraint(equalTo: floatingLabel.bottomAnchor, constant: -5).isActive = true
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
            labelView.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: -15).isActive = true
            
        } else {
            floatingLabel.isHidden = true
        }
    }
}
