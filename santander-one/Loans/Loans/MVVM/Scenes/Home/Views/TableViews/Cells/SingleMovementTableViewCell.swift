//
//  MovementTableViewCell.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/11/19.
//

import UI
import UIOneComponents
import CoreFoundationLib

class SingleMovementTableViewCell: UITableViewCell {
    
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet weak var amountLabelView: OneLabelHighlightedView!
    @IBOutlet weak var highlightView: UIView!
    private var bottomLineSeparator: UIView?
    private var dottedLineSeparator: DottedLineView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bottomLineSeparator?.removeFromSuperview()
        dottedLineSeparator?.removeFromSuperview()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.highlightView.layer.cornerRadius = 2
    }
    
    func configure(withViewModel viewModel: LoanTransaction) {
        self.transactionDescriptionLabel.text = localized(viewModel.description)
        self.amountLabelView.attributedText = viewModel.amountAttributeString
        if viewModel.mustShowBottomLineForSingleCell == true {
            self.addBottomLineSeparator()
        }
        if viewModel.mustHideSeparationLine == false {
            self.addDottedLineSeparator()
        }
        if let value = viewModel.transaction.amountRepresentable?.value, value > 0 {
            amountLabelView.style = .lightGreen
        } else {
            amountLabelView.style = .clear
        }
    }
    
    func setIdentifiers(descriptionIdentifier: String, amountIdentifier: String) {
        self.transactionDescriptionLabel.accessibilityIdentifier = descriptionIdentifier
        self.amountLabelView.accessibilityIdentifier = amountIdentifier
    }
}

private extension SingleMovementTableViewCell {
    func addBottomLineSeparator() {
        bottomLineSeparator = UIView()
        bottomLineSeparator?.translatesAutoresizingMaskIntoConstraints = false
        bottomLineSeparator?.backgroundColor = .mediumSkyGray
        self.contentView.addSubview(bottomLineSeparator!)
        self.setBottomViewConstraints(bottomLineSeparator)
    }
    
    func addDottedLineSeparator() {
        dottedLineSeparator = DottedLineView()
        dottedLineSeparator?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(dottedLineSeparator!)
        self.setBottomViewConstraints(dottedLineSeparator, leadingSpace: 15)
    }
    
    func setBottomViewConstraints(_ view: UIView?, leadingSpace: CGFloat = 0) {
        view?.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        view?.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: leadingSpace).isActive = true
        view?.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        view?.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
