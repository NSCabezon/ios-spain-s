//
//  OneSmallSelectorListView.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 4/1/22.
//

import UI
import CoreFoundationLib

public protocol OneSmallSelectorListViewDelegate: AnyObject {
    func didSelectOneSmallSelectorListView(status: OneSmallSelectorListViewModel.Status, at index: Int)
}

public final class OneSmallSelectorListView: XibView {
    private enum Constants {
        static let borderWidth: CGFloat = 1.0
        static let cornerIconName: String = "icnCheckOvalGreen"
    }
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var leftTextLabel: UILabel!
    @IBOutlet private weak var rightTextLabel: UILabel!
    @IBOutlet private weak var rightIconImageView: UIImageView!
    @IBOutlet private weak var cornerIconImageView: UIImageView!
    public weak var delegate: OneSmallSelectorListViewDelegate?
    private var status: OneSmallSelectorListViewModel.Status = .inactive
    private var index: Int = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    public func setViewModel(_ viewModel: OneSmallSelectorListViewModel, index: Int = 0) {
        self.status = viewModel.status
        self.index = index
        self.configureByStatus()
        self.configureByRightAccessory(viewModel.rightAccessory)
        self.setLeftLabelText(viewModel.leftTextKey, highlightedText: viewModel.highlightedText)
        self.setAccessibilityIdentifiers(suffix: viewModel.accessibilitySuffix)
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix: suffix)
    }
    
    public func setStatus(_ status: OneSmallSelectorListViewModel.Status) {
        self.status = status
        self.configureByStatus()
    }
    
    public func prepareForReuse() {
        self.leftTextLabel.attributedText = nil
    }
}

private extension OneSmallSelectorListView {
    func configureView() {
        self.configureViews()
        self.configureLabels()
        self.configureImageViews()
        self.configureRightAccessories()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func configureViews() {
        self.contentView.layer.borderWidth = Constants.borderWidth
        self.contentView.layer.borderColor = UIColor.oneMediumSkyGray.cgColor
        self.contentView.setOneCornerRadius(type: .oneShRadius8)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnContentView))
        self.contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configureLabels() {
        self.leftTextLabel.font = .typography(fontName: .oneB300Regular)
        self.leftTextLabel.textColor = .oneLisboaGray
        self.rightTextLabel.font = .typography(fontName: .oneH200Bold)
        self.rightTextLabel.textColor = .oneDarkTurquoise
    }
    
    func configureImageViews() {
        self.cornerIconImageView.image = Assets.image(named: Constants.cornerIconName)
    }
    
    func configureRightAccessories() {
        self.rightIconImageView.isHidden = true
        self.rightTextLabel.isHidden = true
    }
    
    func configureByStatus() {
        self.contentView.backgroundColor = self.status.backgroundColor
        self.contentView.layer.borderWidth = self.status.borderWidth
        self.leftTextLabel.textColor = self.status.leftTextColor
        self.leftTextLabel.font = self.status.leftTextFont
        self.cornerIconImageView.isHidden = self.status != .activated
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func configureByRightAccessory(_ type: OneSmallSelectorListViewModel.RightAccessory) {
        switch type {
        case .text(let textKey):
            self.rightTextLabel.isHidden = false
            self.rightTextLabel.text = localized(textKey)
        case .icon(let imageName):
            self.rightIconImageView.isHidden = false
            if let image = Assets.image(named: imageName) {
                self.rightIconImageView.image = image
            } else {
                self.rightIconImageView.loadImage(urlString: imageName)
            }
        case .none:
            break
        }
    }
    
    func setLeftLabelText(_ textKey: String, highlightedText: String?) {
        let localizedText: String = localized(textKey)
        guard let highlightedText = highlightedText,
              !highlightedText.isEmpty else {
            self.leftTextLabel.text = localizedText
            return
        }
        let attributedString = NSMutableAttributedString(string: localizedText)
        if let highlightedRange = localizedText.lowercased().deleteAccent().range(of: highlightedText.lowercased().deleteAccent()) {
            attributedString.addAttribute(.backgroundColor,
                                          value: UIColor.onePaleYellow,
                                          range: NSRange(highlightedRange, in: localizedText.lowercased().deleteAccent()))
        }
        self.leftTextLabel.attributedText = attributedString
    }
    
    func toggleStatus() {
        switch self.status {
        case .activated:
            self.status = .inactive
        case .inactive:
            self.status = .activated
        }
        self.configureByStatus()
    }
    
    func setAccessibilityIdentifiers(suffix: String? = nil) {
        self.leftTextLabel.accessibilityIdentifier = AccessibilityOneComponents.oneSmallSelectorListLabel + (suffix ?? "")
        self.rightTextLabel.accessibilityIdentifier = AccessibilityOneComponents.oneSmallSelectorListHelperText + (suffix ?? "")
        self.rightIconImageView.accessibilityIdentifier = AccessibilityOneComponents.oneSmallSelectorListIcon + (suffix ?? "")
        self.cornerIconImageView.accessibilityIdentifier = AccessibilityOneComponents.oneSmallSelectorListCheck + (suffix ?? "")
        self.contentView.accessibilityIdentifier = AccessibilityOneComponents.oneSmallSelectorListView + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.contentView.isAccessibilityElement = true
        self.contentView.accessibilityLabel = self.leftTextLabel.text
        self.contentView.accessibilityValue = self.status == .activated ? localized("voiceover_selected") : localized("voiceover_unselected")
        self.contentView.accessibilityTraits = .button
    }
    
    @objc func didTapOnContentView() {
        self.toggleStatus()
        self.delegate?.didSelectOneSmallSelectorListView(status: self.status, at: self.index)
        UIAccessibility.post(notification: .layoutChanged, argument: self.contentView)
    }
}

extension OneSmallSelectorListView: AccessibilityCapable {}
