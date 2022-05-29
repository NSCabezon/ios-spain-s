//
//  AtmTipCollectionViewCell.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 02/09/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol AtmTipCollectionViewCellProtocol {
    func setViewModel(_ viewModel: AtmTipViewModel)
}

final class AtmTipCollectionViewCell: UICollectionViewCell, AtmTipCollectionViewCellProtocol {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var imageTipView: UIImageView!
    @IBOutlet weak private var viewContainer: UIView!
    @IBOutlet weak var descriptionView: UIView!
    private var tagView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeTagLabel()
    }

    func setViewModel(_ viewModel: AtmTipViewModel) {
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 18.0)
        self.descriptionLabel.configureText(withLocalizedString: viewModel.description)
        if let imageUrl = viewModel.tipImageUrl {
            self.imageTipView.loadImage(urlString: imageUrl)
        } else {
            self.imageTipView.image = nil
        }
        if viewModel.isHighlighted {
            self.titleLabel.attributedText = viewModel.highlight(self.titleLabel.attributedText)
            self.descriptionLabel.attributedText = viewModel.highlight(self.descriptionLabel.attributedText)
        }
        guard !(viewModel.tag ?? "").isEmpty else { return removeTagLabel() }
        self.addTagLabel(viewModel.tag?.uppercased())
    }
    
    // MARK: - Private Methods
    private func configureCell() {
        self.clipsToBounds = false
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.layer.masksToBounds = true
        self.contentView.layer.masksToBounds = false
        self.contentView.backgroundColor = UIColor.clear
        self.titleLabel.font = .santander(family: .headline, type: .bold, size: 10.0)
        titleLabel.textColor = .mediumSanGray
        titleLabel.textAlignment = .left
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 18.0)
        self.descriptionLabel.textAlignment = .left
        self.descriptionLabel.lineBreakMode = .byTruncatingTail
        self.descriptionLabel.adjustsFontSizeToFitWidth = false
        self.viewContainer.clipsToBounds = true
        self.accessibilityIdentifier = AccessibilityAtm.atmCarouselTips.rawValue
    }
    
    func removeTagLabel() {
        self.tagView?.removeFromSuperview()
        self.tagView = nil
    }
    
    func addTagLabel(_ tag: String?) {
        guard let tag = tag else { return }
        let tagView = UIView()
        self.tagView = tagView
        tagView.accessibilityIdentifier = AccessibilityAtm.tagView.rawValue
        tagView.backgroundColor = .darkTorquoise
        tagView.layer.cornerRadius = 2.0
        tagView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagView)
        bringSubviewToFront(tagView)
        let label = UILabel()
        label.text = localized(tag)
        label.font = UIFont.santander(type: .bold, size: 10.0)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        tagView.addSubview(label)
        NSLayoutConstraint.activate([
            tagView.heightAnchor.constraint(equalToConstant: 16.0),
            tagView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: -5),
            tagView.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: -8),
            label.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: tagView.centerYAnchor, constant: -1),
            label.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 8.0)
        ])
    }
}
