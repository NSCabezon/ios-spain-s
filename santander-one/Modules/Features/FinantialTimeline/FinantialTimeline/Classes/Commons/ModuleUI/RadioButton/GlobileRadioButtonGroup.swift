//
//  GlobileRadioButtonGroup.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

protocol GlobileRadioButtonGroupDelegate: class {
    func didSelect(radioButton: GlobileRadioButton)
}

class GlobileRadioButtonGroup: UIView {
    
    
    /// The object that acts as the delegate of the radio button group
    var delegate: GlobileRadioButtonGroupDelegate?
    
    
    /// The group's radio buttons.
    var radioButtons: [GlobileRadioButton]?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.distribution = .fill
        return stackView
    }()
    
    
    init(radioButtons: [GlobileRadioButton]) {
        self.radioButtons = radioButtons
        super.init(frame: .zero)
        addSubviews()
        setupLayout()
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupSubviews()
    }
    
    // MARK: Private
    
    private func addSubviews() {
        addSubview(stackView)
        
        if let radioButtons = radioButtons {
            for button in radioButtons {
                stackView.addArrangedSubview(button)
            }
        }
    }
    
    private func setupSubviews() {
        if let radioButtons = radioButtons {
            for button in radioButtons {
                button.delegate = self
            }
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: stackView.topAnchor),
            leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }
}

extension GlobileRadioButtonGroup: SantanderRadioButtonDelegate {
    
    func santanderRadioButtonSelected(button: GlobileRadioButton) {
        guard let radioButtons = radioButtons else { return }
        
        radioButtons.forEach { radioButton in
            if radioButton.isSelected { radioButton.deselect() }
        }
        
        delegate?.didSelect(radioButton: button)
    }
}
