//
//  CardSectionHeaderView.swift
//  UI
//
//  Created by Iván Estévez Nieto on 26/5/21.
//

import Foundation

public struct CardSectionHeaderViewModel {
    var image: UIImage?
    var url: String?
    var defaultImage: UIImage?
    let title: String
    let subtitle: String
    
    public init(image: UIImage, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }
    
    public init(url: String, defaultImage: UIImage?, title: String, subtitle: String) {
        self.url = url
        self.defaultImage = defaultImage
        self.title = title
        self.subtitle = subtitle
    }
}

public final class CardSectionHeaderView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setViewModel(_ viewModel: CardSectionHeaderViewModel) {
        if let image = viewModel.image {
            self.imageView.image = image
        } else if let url = viewModel.url {
            self.imageView.loadImage(urlString: url, placeholder: viewModel.defaultImage)
        }
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
    }
}

private extension CardSectionHeaderView {
    func setAppearance() {
        self.setupViews()
        self.setupLabels()
    }
    
    func setupViews() {
        self.view?.backgroundColor = .skyGray
        self.bottomSeparatorView.backgroundColor = .mediumSkyGray
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.borderWidth = 1
        self.containerView.layer.borderColor = UIColor.silverLight.cgColor
        [containerView, imageView].forEach { view in
            view?.layer.shadowColor = UIColor.lightSanGray.cgColor
            view?.layer.shadowOpacity = 0.7
            view?.layer.shadowOffset = CGSize(width: 0, height: 2)
            view?.layer.shadowRadius = 5
        }
    }
    
    func setupLabels() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.subtitleLabel.textColor = .lisboaGray
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 14)
    }
}
