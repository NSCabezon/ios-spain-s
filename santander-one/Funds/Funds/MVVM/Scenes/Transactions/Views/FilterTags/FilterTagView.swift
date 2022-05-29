//
//  FilterTagView.swift
//  Funds
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine

private enum FilterTagViewIdentifiers {
    static let closeImage: String = "icnCloseFilterTag"
}

enum FilterTagType {
    case none
    case dateRange
}

final class FilterTagView: XibView {
    @IBOutlet private weak var filterTagLabel: UILabel!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    private var type: FilterTagType = .none
    var didSelectTag: ((FilterTagType) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func closeButtonDidPressed(_ sender: UIButton) {
        self.didSelectTag?(self.type)
    }

    func setupView(description: String, type: FilterTagType, buttonIdentifier: String? = nil, labelIdentifier: String? = nil) {
        self.type = type
        self.filterTagLabel.text = description
        self.closeImageView.image = UIImage(named: FilterTagViewIdentifiers.closeImage, in: .module, compatibleWith: nil)
        self.view?.layer.cornerRadius = 4
        self.view?.layer.borderWidth = 1.4
        self.view?.layer.borderColor = UIColor.oneDarkTurquoise.withAlphaComponent(0.35).cgColor
        self.filterTagLabel.accessibilityIdentifier = labelIdentifier
        self.closeButton.accessibilityIdentifier = buttonIdentifier
        self.setAccessibility {
            self.closeButton.accessibilityLabel = localized("voiceover_tapToClose") + " " + description
        }
    }
}

extension FilterTagView: AccessibilityCapable {}
