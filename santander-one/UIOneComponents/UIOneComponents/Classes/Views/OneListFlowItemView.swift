//
//  OneListFlowItem.swift
//  UIOneComponents
//
//  Created by José María Jiménez Pérez on 14/10/21.
//

import UI
import CoreFoundationLib
import UIKit

public class OneListFlowItemView: XibView {
    
    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var bulletImage: UIImageView!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var actionContainer: UIView!
    @IBOutlet private weak var actionLabel: UILabel!
    
    private var viewModel: OneListFlowItemViewModel?
    private var indexPath: IndexPath?
    private var action: (() -> Void)?
    
    public init() {
        super.init(frame: .zero)
        self.configureViews()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum Constants {
        static let imageViewHeight: CGFloat = 12
    }
}

private extension OneListFlowItemView {
    func configureViews() {
        self.bulletImage.image = Assets.image(named: "oval")
        self.topSeparator.backgroundColor = .oneSkyGray
        self.bottomSeparator.backgroundColor = .oneSkyGray
        self.actionLabel.font = .typography(fontName: .oneB200Bold)
        self.actionLabel.textColor = .oneDarkTurquoise
        self.actionContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.didTapOnAction))
        )
    }
    
    @objc func didTapOnAction() {
        self.action?()
    }
    
    func fillElements(viewModel: OneListFlowItemViewModel, accessibilitySuffix: String = "") {
        self.topSeparator.isHidden = viewModel.isFirstItem
        self.bottomSeparator.isHidden = viewModel.isLastItem
        if !viewModel.shouldShowSeparators {
            self.topSeparator.isHidden = true
            self.bottomSeparator.isHidden = true
        }
        if let action = viewModel.action {
            self.actionLabel.text = localized(action.actionKey)
            self.action = action.action
        } else {
            self.actionLabel.text = nil
        }
        viewModel.items.forEach {
            self.stackView.addArrangedSubview(
                self.createViewForItem($0,
                                       accessibilitySuffix: accessibilitySuffix))
        }
        self.setAccessibilityIdentifiers(accessibilitySuffix)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String = "") {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneListFlowItem + suffix
        self.actionLabel.accessibilityIdentifier = AccessibilityOneComponents.oneListFlowItemEdit + suffix
    }
    
    func setAccesibilityInfo() {
        guard let viewModel = self.viewModel else { return }
        self.actionLabel.accessibilityLabel = viewModel.actionAccessibilityLabel
        self.actionLabel.accessibilityTraits = .button
    }
    
    func createViewForItem(_ item: OneListFlowItemViewModel.Item, accessibilitySuffix: String) -> UIView {
        var view: UIView
        switch item.type {
        case .title(let keyOrValue): view = self.createLabelView(keyOrValue: keyOrValue, isBold: false)
        case .label(let keyOrValue, let isBold): view = self.createLabelView(keyOrValue: keyOrValue, isBold: isBold)
        case .image(let imageKeyOrUrl): view = self.createImageView(imageKeyOrUrl: imageKeyOrUrl)
        case .attributedLabel(let attributedString): view = self.createAttributedLabel(attributedString: attributedString)
        case .spacing(let height): view  = self.createSpacingView(height: height)
        case .custom(let associatedView): view = associatedView
        case .tag(let tag): view = self.createTagView(tag: tag, accessibilitySuffix: accessibilitySuffix)
        }
        view.accessibilityIdentifier = item.accessibilityId + accessibilitySuffix
        self.setAccessibility {
            if let accessibilityLabel = item.accessibilityLabel {
                view.accessibilityLabel = accessibilityLabel
            } else if let accessibilityAttributedLabel = item.accessibilityAttributedLabel {
                guard #available(iOS 11.0, *) else {
                    view.accessibilityLabel = accessibilityAttributedLabel.string
                    return
                }
                view.accessibilityAttributedLabel = accessibilityAttributedLabel
            }
        }
        return view
    }
    
    func createLabelView(keyOrValue: String?, isBold: Bool) -> UIView {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = isBold ? .typography(fontName: .oneB300Bold) : .typography(fontName: .oneB300Regular)
        label.textColor = .oneLisboaGray
        label.configureText(withKey: keyOrValue ?? "")
        return label
    }
    
    func createAttributedLabel(attributedString: NSAttributedString) -> UIView {
        let label = UILabel()
        label.attributedText = attributedString
        return label
    }
    
    func createSpacingView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    func createImageView(imageKeyOrUrl: String?) -> UIView {
        let container = UIStackView()
        let imageView = UIImageView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight).isActive = true
        container.axis = .horizontal
        container.addArrangedSubview(imageView)
        container.addArrangedSubview(UIView())
        
        _ = imageView.setImage(url: imageKeyOrUrl) { image in
            let finalImage = image ?? Assets.image(named: imageKeyOrUrl ?? "")
            guard let image = finalImage else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
            let ratio = image.size.width / image.size.height
            imageView.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: ratio).isActive = true
        }
        return container
    }
    
    func createTagView(tag: OneListFlowItemViewModel.Tag, accessibilitySuffix: String = "") -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        let label = UILabel()
        label.font = .typography(fontName: .oneB300Bold)
        label.textColor = .oneLisboaGray
        label.configureText(withKey: tag.itemKeyOrValue ?? "")
        stackView.addArrangedSubview(label)
        
        let tagContainer = UIView()
        tagContainer.accessibilityIdentifier = AccessibilityOneComponents.oneListFlowItemTag + accessibilitySuffix
        let tagLabel = UILabel()
        tagLabel.font = .typography(fontName: .oneB100Bold)
        tagLabel.textColor = .oneDarkTurquoise
        tagLabel.configureText(withKey: tag.tagKeyOrValue ?? "")
        tagContainer.addSubview(tagLabel)
        tagLabel.fullFit(topMargin: 2, bottomMargin: 2, leftMargin: 8, rightMargin: 8)
        tagContainer.drawBorder(cornerRadius: 4, color: .oneDarkTurquoise, width: 1)
        stackView.addArrangedSubview(tagContainer)
        
        let spacer = UIView()
        stackView.addArrangedSubview(spacer)
        
        return stackView
    }
}

public extension OneListFlowItemView {
    func setupViewModel(_ viewModel: OneListFlowItemViewModel, at indexPath: IndexPath? = nil) {
        self.fillElements(viewModel: viewModel, accessibilitySuffix: viewModel.accessibilitySuffix ?? "")
        self.viewModel = viewModel
        self.indexPath = indexPath
        self.setAccessibility(setViewAccessibility: self.setAccesibilityInfo)
    }
    
    func setAccessibilityFocus() {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .layoutChanged, argument: self.stackView)
        }
    }
}

extension OneListFlowItemView: AccessibilityCapable {}
