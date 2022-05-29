//
//  GlobalSearchAdviseCollectionViewCell.swift
//  GlobalSearch
//
//  Created by alvola on 03/08/2020.
//

import CoreFoundationLib

final class GlobalSearchAdviseCollectionViewCell: UICollectionViewCell, HelpCenterTipCollectionViewCellProtocol {

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
    
    public func setViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? HelpCenterTipViewModel else { return }
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

    func setupAccessibilityIdentifiers(with suffix: String) {
        configureAccessibilityIdentifiers(suffix: suffix)
    }
}

private extension GlobalSearchAdviseCollectionViewCell {
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
    
    func configureAccessibilityIdentifiers(suffix: String = "") {
        self.accessibilityIdentifier = "GlobalSearchLabelHomeTipCell" + suffix
        titleLabel.accessibilityIdentifier = "GlobalSearchLabelHomeTipCellTitle" + suffix
        descriptionLabel.accessibilityIdentifier = "GlobalSearchLabelHomeTipCellDescription" + suffix
        descriptionView.accessibilityIdentifier = "GlobalSearchViewHomeTipCellDescriptionZone" + suffix
        imageTipView.isAccessibilityElement = true
        setAccessibility { self.imageTipView.isAccessibilityElement = false }
        imageTipView.accessibilityIdentifier = "GlobalSearchImageHomeTipCellBackgroundImage" + suffix
        viewContainer.accessibilityIdentifier = "GlobalSearchButtonHomeTipCellGoToOffer" + suffix
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

extension GlobalSearchAdviseCollectionViewCell: AccessibilityCapable { }
