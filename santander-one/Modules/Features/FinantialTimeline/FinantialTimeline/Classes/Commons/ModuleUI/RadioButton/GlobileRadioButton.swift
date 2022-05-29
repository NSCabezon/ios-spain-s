//
//  GlobileRadioButton.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

enum RadioButtonColor {
    case red, turquoise
}

protocol SantanderRadioButtonDelegate: class {
    func santanderRadioButtonSelected(button: GlobileRadioButton)
}

class GlobileRadioButton: UIView {

    var delegate: SantanderRadioButtonDelegate?

    private let greyColor = UIColor.mediumSanGray
    private let redColor = UIColor.bostonRed
    private let turquoiseColor = UIColor.turquoise

    /// A Boolean value indicating whether the radio button is in the selected state.
    var isSelected: Bool {
        return radioButton.isSelected
    }

    /// A Boolean value indicating whether the info button is enabled.
    @IBInspectable
    var infoButtonEnabled: Bool = false {
        didSet {
            infoButton.isHidden = !infoButtonEnabled
        }
    }

    /// The current text that is displayed by the button.
    @IBInspectable
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    /// The tint color to apply to the radio button.
    var radioButtonColor: RadioButtonColor = .red {
        didSet {
            switch radioButtonColor {
            case .red:
                radioButton.innerCircleColor = redColor
            case .turquoise:
                radioButton.innerCircleColor = turquoiseColor
            }
        }
    }

    // MARK: View components

    private var radioButton: RadioButton = {
        let radioButton = RadioButton()
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        return radioButton
    }()

    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.santanderText(type: .regular, with: 16)
        label.text = "By Push Notification"
        return label
    }()

    private var infoButton: UIButton = {
        let button = UIButton(type: .infoLight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupLayout()
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        setupLayout()
        setupViews()
    }

    func deselect() {
        radioButton.isSelected = false
        UIView.animate(withDuration: 0.5) {
            self.label.textColor = self.greyColor
            self.radioButton.outerCircleLineWidth = 1.0
        }
    }

    @objc func selectView(_ sender: UITapGestureRecognizer) {
        select()
    }

    // MARK: Private

    private func select() {
        delegate?.santanderRadioButtonSelected(button: self)
        radioButton.isSelected = true
        UIView.animate(withDuration: 0.5) {
//            self.label.textColor = .black
            self.label.textColor = .black
            self.radioButton.outerCircleLineWidth = 2.0
        }
    }
}

private extension GlobileRadioButton {

    func addSubviews() {
        addSubview(radioButton)
        addSubview(label)
        addSubview(infoButton)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            radioButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            radioButton.rightAnchor.constraint(equalTo: label.leftAnchor, constant: -12),
            radioButton.heightAnchor.constraint(equalToConstant: 30.0),
            radioButton.widthAnchor.constraint(equalTo: radioButton.heightAnchor),
            radioButton.topAnchor.constraint(equalTo: topAnchor, constant: -3)
            ])

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

        NSLayoutConstraint.activate([
            infoButton.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor),
            infoButton.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 12),
            infoButton.widthAnchor.constraint(equalTo: infoButton.heightAnchor),
            infoButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }

    func setupViews() {
        backgroundColor = .clear

        radioButton.outerCircleColor = greyColor
        radioButton.innerCircleColor = redColor
        radioButton.delegate = self

        infoButton.tintColor = greyColor
        label.textColor = greyColor

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectView(_:)))
        addGestureRecognizer(tapGesture)
    }

}

extension GlobileRadioButton: RadioButtonDelegate {

    func radioButtonSelected() {
        select()
    }
}
