//
//  GlobileCheckBox.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

enum GlobileCheckboxTintColor {
    case red
    case turquoise
}

class GlobileCheckBox: UIControl {

    // MARK: Colors

    private let textColor = UIColor.brownishGrey
    private let infoButtonColor = UIColor.brownishGrey


    /// A Boolean value indicating whether the info button is enabled.
    var infoButtonEnabled: Bool = false {
        didSet {
            infoButton.isHidden = !infoButtonEnabled
        }
    }

    /// A Boolean value indicating whether the control is in the selected state.
    override var isSelected: Bool {
        didSet {
            checkboxButton.isSelected = isSelected
            updateLabel()
        }
    }

    /// The tint color to apply to the checkbox button.
    var color: GlobileCheckboxTintColor = .red


    /// The current text that is displayed by the button.
    var text: String?

    // MARK: Subviews

    private let checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        let image = UIImage(fromModuleWithName: "empty_checkbox")
        button.setImage(image, for: .normal)
        return button
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .santanderText(type: .regular, with: 16)
        return label
    }()

    private let infoButton: UIButton = {
        let button = UIButton(type: .infoDark)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupViews()
    }

    // MARK: Private

    private func addSubviews() {
        addSubview(checkboxButton)
        addSubview(label)
        addSubview(infoButton)

        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            checkboxButton.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            checkboxButton.heightAnchor.constraint(equalToConstant: 30.0),
            checkboxButton.widthAnchor.constraint(equalTo: checkboxButton.heightAnchor),
            checkboxButton.topAnchor.constraint(equalTo: topAnchor, constant: -3),
            ])

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

        NSLayoutConstraint.activate([
            infoButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            infoButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
            infoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoButton.heightAnchor.constraint(equalToConstant: 18.0),
            infoButton.widthAnchor.constraint(equalTo: infoButton.heightAnchor),
            ])
    }
    
    private func setupViews() {
        backgroundColor = .clear

        label.textColor = textColor
        infoButton.tintColor = infoButtonColor

        label.text = text
        checkboxButton.addTarget(self, action: #selector(checkboxButtonTapped(_:)), for: .touchUpInside)

        addTarget(self, action: #selector(selectView(_:)), for: .touchUpInside)

        switch color {
        case .red:
            let image = UIImage(fromModuleWithName: "selected_red_checkbox")
            checkboxButton.setImage(image, for: .selected)
        case .turquoise:
            let image = UIImage(fromModuleWithName: "selected_turquoise_checkbox")
            checkboxButton.setImage(image, for: .selected)
        }
    }
    
    private func updateLabel() {
        label.textColor = isSelected ? UIColor.black : UIColor.greyishBrown
    }

    // MARK: Actions

    @objc func selectView(_ sender: UITapGestureRecognizer) {
        checkboxButton.isSelected.toggle()
        isSelected = checkboxButton.isSelected
        sendActions(for: .valueChanged)
    }

    @objc func checkboxButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        isSelected = sender.isSelected
        updateLabel()
        sendActions(for: .valueChanged)
    }
}
