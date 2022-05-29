//
//  HorizontalSelectorView.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 30/6/21.
//

import UIKit
import UI
import CoreFoundationLib

public struct HorizontalSelectorItem {
    
    var attributedString: LocalizedStylableText
    var image: UIImage?
    var accessibilityIdentifier: String
    var selectedImage: UIImage?
    var selectedColor: UIColor = .darkTorquoise
    var defaultColor: UIColor = .lisboaGray
    var defaultFont: UIFont = .santander(family: .text, type: .regular, size: 14)
    
    init(text: LocalizedStylableText, identifier: String) {
        self.attributedString = text
        self.accessibilityIdentifier = identifier
    }
    
    init(image: UIImage?, selected: UIImage?, identifier: String) {
        self.image = image
        self.accessibilityIdentifier = identifier
        self.selectedImage = selected
        self.attributedString = LocalizedStylableText(text: "", styles: nil)
    }
}

protocol HorizontalSelectorViewDelegate: AnyObject {
    func didSelectItem(at index: Int)
}

final class HorizontalSelectorView: UIView {
    
    private var items: [HorizontalSelectorItem] = []
    private var indicatorView: UIView = UIView()
    private var selectedIndex: Int = 0
    private var selectedView: UIView?
    private var stackView = UIStackView()
    public weak var delegate: HorizontalSelectorViewDelegate?
    
    private enum Config {
        static let minItemWith: CGFloat = 40.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setIndicatorTo(selectedIndex)
    }
    
    public func configureWith(_ items: [HorizontalSelectorItem], preSelectedIndex: Int = 0) {
        self.items = items
        for (index, item) in self.items.enumerated() {
            let itemView: UIView
            if let image = item.image {
                let view = UIImageView(image: image)
                view.contentMode = .center
                itemView = view
            } else {
                let view = UILabel()
                view.textAlignment = .center
                view.numberOfLines = 2
                view.font = item.defaultFont
                view.textColor = item.defaultColor
                view.configureText(withLocalizedString: item.attributedString)
                itemView = view
            }
            itemView.tag = index
            itemView.isUserInteractionEnabled = true
            itemView.accessibilityIdentifier = item.accessibilityIdentifier
            itemView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(didSelectFractionedPaymentMovement(_:)))]
            stackView.addArrangedSubview(itemView)
        }
        selectedIndex = preSelectedIndex
        selectedView = stackView.arrangedSubviews[safe: preSelectedIndex]
    }
}

private extension HorizontalSelectorView {
    func setupView() {
        self.backgroundColor = UIColor.inactiveGray
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        indicatorView.layer.cornerRadius = 5
        indicatorView.clipsToBounds = true
        indicatorView.backgroundColor = .white
        indicatorView.layer.masksToBounds = false
        indicatorView.layer.shadowOffset = CGSize(width: 1, height: 1)
        indicatorView.layer.shadowColor = UIColor.black.cgColor
        indicatorView.layer.shadowOpacity = 0.2
        indicatorView.layer.shadowRadius = 2
        self.addSubview(indicatorView)
        self.addSubview(stackView)
        stackView.fullFit()
    }
    
    func setIndicatorTo(_ index: Int) {
        guard let view = stackView.arrangedSubviews[safe: index] else { return }
        guard indicatorView.frame.width == 0.0 else {
            moveIndicatorTo(view)
            return
        }
        if view.frame.width > Config.minItemWith {
            self.indicatorView.frame = CGRect(x: 0, y: 0, width: view.frame.width-10, height: view.frame.height-10)
            self.moveIndicatorTo(view)
        }
    }
    
    func moveIndicatorTo(_ view: UIView) {
        UIView.animate(withDuration: 0.1) {
            self.indicatorView.center = view.center
        } completion: { _ in
            self.makeSelected()
        }
    }
    
    @objc func didSelectFractionedPaymentMovement(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        makeUnselected()
        selectedIndex = index
        selectedView = view
        layoutSubviews()
        delegate?.didSelectItem(at: index)
    }
    
    func makeSelected() {
        if let label = selectedView as? UILabel {
            label.textColor = items[safe: selectedIndex]?.selectedColor
        } else if let image = selectedView as? UIImageView {
            image.image = items[safe: selectedIndex]?.selectedImage
        }
    }
    
    func makeUnselected() {
        if let label = selectedView as? UILabel {
            label.textColor = items[safe: selectedIndex]?.defaultColor
        } else if let image = selectedView as? UIImageView {
            image.image = items[safe: selectedIndex]?.image
        }
    }
}
