//

import Foundation
import UI

struct CardConfirmationModelViewIdentifiers {
    var titleLabelIdentifier: String? = nil
    var subtitleLabelIdentifier: String? = nil
    var rightTitleLabelIdentifier: String? = nil
    var rightSubtitleLabelIdentifier: String? = nil
    var cardImageIdentifier: String? = nil
}

class CardConfirmationModelView: TableModelViewItem<CardConfirmationTableViewCell> {
    
    private let name: String?
    private let type: LocalizedStylableText?
    private let header: LocalizedStylableText?
    private let avaliable: String?
    private let image: String?
    private let identifiers: CardConfirmationModelViewIdentifiers?

    init(name: String?, type: LocalizedStylableText?, header: LocalizedStylableText?, avaliable: String?, image: String?, dependencies: PresentationComponent, identifiers: CardConfirmationModelViewIdentifiers? = nil) {
        self.name = name
        self.type = type
        self.header = header
        self.avaliable = avaliable
        self.image = image
        self.identifiers = identifiers
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: CardConfirmationTableViewCell) {
        viewCell.titleLabel.text = name
        if let text = type {
            viewCell.subtitleLabel.set(localizedStylableText: text)
        } else {
            viewCell.subtitleLabel.text = nil
        }
        if let text = header {
            viewCell.rightTitleLabel.set(localizedStylableText: text)
        } else {
            viewCell.rightTitleLabel.text = nil
        }
        viewCell.rightSubtitleLabel.text = avaliable
        if let image = image {
            dependencies.imageLoader.load(relativeUrl: image, imageView: viewCell.cardImageView, placeholder: "defaultCard")
        } else {
            viewCell.cardImageView.image = Assets.image(named: "defaultCard")
        }
        if let identifiers = self.identifiers {
            viewCell.titleLabel.accessibilityIdentifier = identifiers.titleLabelIdentifier
            viewCell.subtitleLabel.accessibilityIdentifier = identifiers.subtitleLabelIdentifier
            viewCell.rightTitleLabel.accessibilityIdentifier = identifiers.rightTitleLabelIdentifier
            viewCell.rightSubtitleLabel.accessibilityIdentifier = identifiers.rightSubtitleLabelIdentifier
            viewCell.cardImageView.isAccessibilityElement = true
            viewCell.cardImageView.accessibilityIdentifier = identifiers.cardImageIdentifier
        }
    }
}
