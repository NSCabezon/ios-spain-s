//
//  CreateBudgetCollectionViewCell.swift
//  Menu
//
//  Created by David Gálvez Alonso on 26/03/2020.
//

import UI
import CoreFoundationLib

protocol CreateBudgetCollectionViewCellDelegate: AnyObject {
    func didPressBudgetCell(originView: UIView, newBudget: Bool)
}

class CreateBudgetCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var falseButtonLabel: UILabel!
    
    private weak var delegate: CreateBudgetCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    public func setDelegate(_ delegate: CreateBudgetCollectionViewCellDelegate?) {
        self.delegate = delegate
    }
}

// MARK: - Private methods

private extension CreateBudgetCollectionViewCell {
    func setupView() {
        setupContainerView()
        setupLabels()
        setAccessibilityIdentifiers()
        
        iconImageView.image = Assets.image(named: "icnCheeseGraphic")
    }
    
    func setupContainerView() {
        containerView.backgroundColor = UIColor.white
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 6
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightSanGray.cgColor
        self.containerView.drawBorder(cornerRadius: 6, color: UIColor.mediumSkyGray, width: 1)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressContainer)))
    }
    
    func setupLabels() {
        descriptionLabel.textColor = .grafite
        descriptionLabel.numberOfLines = 0
        descriptionLabel.configureText(withKey: "analysis_text_createBudget",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                            lineHeightMultiple: 0.9))

        falseButtonLabel.textColor = .darkTorquoise
        falseButtonLabel.configureText(withKey: "analysis_label_createYourBudget",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16)))
    }
    
    func setAccessibilityIdentifiers() {
        containerView.accessibilityIdentifier = AccessibilityAnalysisArea.btnBudgets.rawValue
        descriptionLabel.accessibilityIdentifier = AccessibilityAnalysisArea.labelCreateBudget.rawValue
        falseButtonLabel.accessibilityIdentifier = AccessibilityAnalysisArea.textCreateBudget.rawValue
    }
    
    @objc func didPressContainer() {
        delegate?.didPressBudgetCell(originView: descriptionLabel, newBudget: true)
    }
}
