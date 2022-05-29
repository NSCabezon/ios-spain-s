//
//  OneFooterTipCell.swift
//  CoreDomain
//
//  Created by Cristobal Ramos Laina on 24/11/21.
//

import UI
import CoreFoundationLib

class OneFooterTipCell: UICollectionViewCell {
    @IBOutlet private weak var offerImageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    static let identifier = "OneFooterTipCell"
    override func prepareForReuse() {
        super.prepareForReuse()
        self.offerImageView?.image = nil
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }
    
    func setCell(title: String, url: String?) {
        self.titleLabel.text = title
        guard let urlUnwrapped = url else { return }
        self.offerImageView.loadImage(urlString: urlUnwrapped)
    }
}

private extension OneFooterTipCell {
    
    func configureCell() {
        self.titleLabel.textColor = .oneBrownishGray
        self.titleLabel.font = .typography(fontName: .oneB200Regular)
        self.containerView.setOneCornerRadius(type: .oneShRadius4)
        self.contentView.backgroundColor = UIColor.clear
        self.setAccesibilityIdentifiers()
    }
    
    func setAccesibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterTipLabel
        self.offerImageView.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterTipImage
    }
}
