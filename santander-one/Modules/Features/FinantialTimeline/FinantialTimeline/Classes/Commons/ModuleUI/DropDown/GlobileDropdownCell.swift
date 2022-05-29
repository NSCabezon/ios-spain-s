//
//  GlobileDropdownCell.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

/// Component color options
///
/// - red: BostonRed (default)
/// - turquoise: Turquoise
enum GlobileDropDownTintColor {
    case red
    case turquoise
}


class GlobileDropdownCell: UITableViewCell  {

    var backView: UIView?
    
    /// The tint color to apply to the checkbox button.
    var color: GlobileDropDownTintColor = .red


    /// Override selection function for custom aspect.
    ///
    /// - Parameters:
    ///   - selected: item selected
    ///   - animated: set animation
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.textLabel?.textColor = .white
        } else {
            self.textLabel?.textColor = .darkGray
        }
    }


    /// Init function
    ///
    /// - Parameters:
    ///   - style: cell style
    ///   - reuseIdentifier: name of reuse cell.
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        switch color {
        case .red:
            backView!.backgroundColor = .bostonRed
        case .turquoise:
            backView!.backgroundColor = .turquoise
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Setup cell properties.
    func setupCell() {
        isUserInteractionEnabled = true
        textLabel?.font = .santanderText(type: .regular, with: 16)
        textLabel?.textColor = .lightGray
        setupView()
    }

    // Setup view inside cell.
    func setupView() {
        backView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backView!.backgroundColor = .bostonRed
        backView!.layer.cornerRadius = 4
        selectedBackgroundView = backView
        
        NSLayoutConstraint.activate([
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 5.0),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: -5.0),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0)
            ])
    }
}
