//
//  GlobalSearchAdviseAtmCollectionViewCell.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 03/09/2020.
//

import Foundation
import UI
import CoreFoundationLib

final class GlobalSearchAdviseAtmCollectionViewCell: UICollectionViewCell, AtmTipCollectionViewCellProtocol {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var imageTipView: UIImageView!
    @IBOutlet weak private var viewContainer: UIView!
    @IBOutlet weak private var descriptionView: UIView!
    private var tagView: UIView?
    private var task: CancelableTask?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageTipView.image = nil
        self.task?.cancel()
        self.removeTagLabel()
        self.configureLabels()
    }
    
    public func setViewModel(_ viewModel: AtmTipViewModel) {
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        self.descriptionLabel.configureText(withLocalizedString: viewModel.description)
        if let imageUrl = viewModel.tipImageUrl {
            self.task = self.imageTipView.loadImage(urlString: imageUrl)
        }
        if viewModel.isHighlighted {
            self.titleLabel.attributedText = viewModel.highlight(self.titleLabel.attributedText)
            self.descriptionLabel.attributedText = viewModel.highlight(self.descriptionLabel.attributedText)
        }
        guard let tag = viewModel.tag else { return removeTagLabel() }
        addTagLabel(tag.uppercased())
    }
}

private extension GlobalSearchAdviseAtmCollectionViewCell {
    func configureCell() {
        configureView()
        configureLabels()
        configureAccessibilityIdentifiers()
    }
    
    func configureView() {
        clipsToBounds = false
        contentView.backgroundColor = UIColor.clear
        
        viewContainer.layer.cornerRadius = 5
        viewContainer.layer.masksToBounds = true
        descriptionView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.atmsShadowGray.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 2.0
        contentView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        viewContainer.layer.borderColor = UIColor.mediumSkyGray.cgColor
        viewContainer.layer.borderWidth = 1.0
    }
    
    func configureLabels() {
        titleLabel.font = .santander(family: .headline, type: .bold, size: 10.0)
        titleLabel.textColor = .brownGray
        titleLabel.textAlignment = .left
        descriptionLabel.font = UIFont.santander(type: .light, size: 16.0)
        descriptionLabel.textAlignment = .left
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.adjustsFontSizeToFitWidth = false
    }
    
    func configureAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AccessibilityAtm.titleLabelGlobalSearch.rawValue
        descriptionLabel.accessibilityIdentifier = AccessibilityAtm.descriptionLabelGlobalSearch.rawValue
        descriptionView.accessibilityIdentifier = AccessibilityAtm.descriptionViewGlobalSearch.rawValue
        imageTipView.accessibilityIdentifier = AccessibilityAtm.imageTipViewGlobalSearch.rawValue
        viewContainer.accessibilityIdentifier = AccessibilityAtm.viewContainerGlobalSearch.rawValue
    }
    
    func removeTagLabel() {
        self.tagView?.removeFromSuperview()
        self.tagView = nil
    }
    
    func addTagLabel(_ tag: String) {
        let tagView = UIView()
        self.tagView = tagView
        tagView.accessibilityIdentifier = "GlobalSearchLabelHomeTipCellTagLabel"
        tagView.backgroundColor = .darkTorquoise
        tagView.layer.cornerRadius = 2.0
        tagView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagView)
        bringSubviewToFront(tagView)
        let label = UILabel()
        label.text = tag
        label.font = UIFont.santander(type: .bold, size: 10.0)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        tagView.addSubview(label)
        NSLayoutConstraint.activate([
            tagView.heightAnchor.constraint(equalToConstant: 16.0),
            tagView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: -5),
            tagView.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: -7),
            label.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: tagView.centerYAnchor, constant: -1),
            label.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 8.0)
        ])
    }
}
