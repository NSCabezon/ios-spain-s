//
//  PublicOfferCarrouselCellCollectionViewCell.swift
//  Menu
//
//  Created by alvola on 29/04/2020.
//

import UI
import CoreFoundationLib

final class PublicOfferCarrouselCell: UICollectionViewCell {
    private lazy var image: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(image, at: 0)
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        return title
    }()
    
    private var currentTask: CancelableTask?
    private var title = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentTask?.cancel()
        image.image = nil
        titleLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.refreshFont(force: true)
        setTitle(title)
    }
    
    func setTitle(_ title: String) {
        self.title = title
        titleLabel.refreshFont(force: true)
        titleLabel.configureText(withKey: title,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, size: 23.0),
                                                                                      lineHeightMultiple: 0.85))
    }
    
    func setImageURL(_ imageURL: String) {
        currentTask = image.loadImage(urlString: imageURL)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: 176.0, height: 103.0)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityPublicMenuButtons.offerCarouselCell
        self.titleLabel.accessibilityIdentifier = AccessibilityPublicMenuButtons.titleCarouselCell
        self.image.accessibilityIdentifier = AccessibilityPublicMenuButtons.imageCarouselCell
    }
}

private extension PublicOfferCarrouselCell {
    func commonInit() {
        backgroundColor = .clear
        layer.cornerRadius = 4.0
        configureTitle()
        configureImage()
    }
    
    func configureTitle() {
        titleLabel.font = UIFont.santander(family: .headline, size: 23.0)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
        trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 45.0).isActive = true
    }
    
    func configureImage() {
        image.backgroundColor = .clear
        image.layer.cornerRadius = 4.0
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        bottomAnchor.constraint(equalTo: image.bottomAnchor, constant: 0.0).isActive = true
        image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
        trailingAnchor.constraint(equalTo: image.trailingAnchor, constant: 0.0).isActive = true
    }
}
