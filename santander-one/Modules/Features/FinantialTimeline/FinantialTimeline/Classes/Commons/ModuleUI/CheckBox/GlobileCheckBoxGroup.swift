//
//  GlobileCheckBoxGroup.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

protocol GlobileCheckboxGroupDelegate: class {
    func didSelect(checkbox: GlobileCheckBox)
    func didDeselect(checkbox: GlobileCheckBox)
}

class GlobileCheckBoxGroup: UIView {
    
    /// The object that acts as the delegate of the checkbox group.
    var delegate: GlobileCheckboxGroupDelegate?
    
    /// The group's checkboxes.
    var checkboxes: [GlobileCheckBox]
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.distribution = .fill
        return stackView
    }()
    
    
    /// Returns a new checkbo group that manages the provided checkboxes.
    ///
    /// - Parameter checkboxes: The checkboxes to be arranged by the group view.
    init(checkboxes: [GlobileCheckBox]) {
        self.checkboxes = checkboxes
        super.init(frame: .zero)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupViews()
    }
    
    
    /// Select all checkboxes.
    func selectAll() {
        checkboxes.forEach { $0.isSelected = true }
    }
    
    
    /// Deselect all checkboxes.
    func deselectAll() {
        checkboxes.forEach { $0.isSelected = false }
    }
    
    // MARK: Private
    
    private func addSubviews() {
        addSubview(stackView)
        
        checkboxes.forEach { self.stackView.addArrangedSubview($0) }
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: stackView.topAnchor),
            leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }
    
    private func setupViews() {
        checkboxes.forEach { checkbox in
            checkbox.addTarget(self, action: #selector(checkboxTapped(_:)), for: .valueChanged)
        }
    }
    
    // MARK: Actions
    
    @objc func checkboxTapped(_ sender: GlobileCheckBox) {
        if sender.isSelected {
            delegate?.didSelect(checkbox: sender)
        } else {
            delegate?.didDeselect(checkbox: sender)
        }
        
    }

}
