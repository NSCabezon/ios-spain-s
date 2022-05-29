//
//  GeneralSectionTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 11/11/2019.
//

import UIKit
import UI

protocol CellSubsectionProtocol: AnyObject {
    func didSelectCellSubsection(_ cellSubsection: PersonalAreaSection)
}

final class GeneralSectionTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var goToImage: UIImageView!
    @IBOutlet private weak var separationView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var topTitleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var botomTitleConstraint: NSLayoutConstraint!
    private weak var subSectionDelegate: CellSubsectionProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetView()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? GeneralSectionModel else { return }
        titleLabel.text = info.title
        titleLabel.numberOfLines = 0
        descriptionLabel.text = info.description
        iconImage.image = Assets.image(named: info.icon)?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = .botonRedLight
        setAccessibilityIdentifiers(info)
        adaptToNoDescriptionMode()
        guard let subsectionInfo = info.subsection else { return }
        addSubsection(with: subsectionInfo)
    }
    
    func setCellSubsectionDelegateIfNeeded(_ subSectionDelegate: CellSubsectionProtocol) {
        guard viewHasSubsection() else { return }
        self.subSectionDelegate = subSectionDelegate
    }
}

extension GeneralSectionTableViewCell: SubsectionButtonProtocol {
    func didSelectSubsection(_ subSection: PersonalAreaSection) {
        subSectionDelegate?.didSelectCellSubsection(subSection)
    }
}

private extension GeneralSectionTableViewCell {
    func commonInit() {
        resetView()
        configureView()
        configureLabels()
        configureArrow()
    }
    
    func configureView() {
        backgroundColor = UIColor.white
        selectionStyle = .none
        separationView.backgroundColor = UIColor.mediumSky
    }
    
    func configureLabels() {
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        titleLabel.textColor = UIColor.lisboaGray
        descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 14.0)
        descriptionLabel.textColor = UIColor.lisboaGray
    }
    
    func configureArrow() {
        goToImage.image = Assets.image(named: "icnArrowRight")
        goToImage.isUserInteractionEnabled = true
    }
    
    func resetView() {
        titleLabel.text = ""
        descriptionLabel.text = ""
        iconImage.image = nil
        removeSubsectionIfNeeded()
    }
    
    func addSubsection(with info: SubsectionInfo) {
        guard !viewHasSubsection() else { return }
        let subsectionView = SubsectionButtonView()
        subsectionView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        stackView.addArrangedSubview(subsectionView)
        subsectionView.setInfo(info)
        subsectionView.setDelegate(self)
        subsectionView.accessibilityIdentifier = "personalAreaBtnGlobalPositionCustomization"
        subsectionView.setAccessibilityIdentifiers(info)
        self.layoutIfNeeded()
    }
    
    func removeSubsectionIfNeeded() {
        guard viewHasSubsection(), let view = getSubsectionView() else { return }
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func viewHasSubsection() -> Bool {
        return stackView.subviews.contains { $0 is SubsectionButtonView }
    }
    
    func getSubsectionView() -> SubsectionButtonView? {
        return (stackView.subviews.filter { $0 is SubsectionButtonView }).first as? SubsectionButtonView
    }
    
    func setAccessibilityIdentifiers(_ info: GeneralSectionModel) {
        self.iconImage.accessibilityIdentifier = info.iconAccessibilityIdentifier
        self.titleLabel.accessibilityIdentifier = info.titleAccessibilityIdentifier
        self.descriptionLabel.accessibilityIdentifier = info.descriptionAccessibilityIdentifier
        self.goToImage.accessibilityIdentifier = info.arrowAccessibilityIdentifier
    }
    
    func adaptToNoDescriptionMode() {
        guard (descriptionLabel.text ?? "").isEmpty else { return }
        self.stackViewHeight.constant = 35.0
        self.topTitleConstraint.constant = 16.0
        self.botomTitleConstraint.constant = -15.0
    }
}
