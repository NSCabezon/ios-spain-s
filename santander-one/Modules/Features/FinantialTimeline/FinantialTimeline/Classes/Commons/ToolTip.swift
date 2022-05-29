//
//  ToolTip.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 17/07/2019.
//

import UIKit

class ToolTip: NSObject {
    
    private let title: String
    private let tooltipDescription: String
    private weak var sourceView: UIView?
    private let sourceFrame: CGRect
    private let arrowDirection: UIPopoverArrowDirection
    private weak var sourceViewController: UIViewController?
    
    init(title: String, description: String, sourceViewController: UIViewController, sourceView: UIView, sourceFrame: CGRect, arrowDirection: UIPopoverArrowDirection) {
        self.title = title
        self.tooltipDescription = description
        self.sourceView = sourceView
        self.sourceFrame = sourceFrame
        self.arrowDirection = arrowDirection
        self.sourceViewController = sourceViewController
    }
    
    func show() {
        let tooltip = ToolTipViewController.fromXib()
        tooltip.loadView()
        tooltip.viewDidLoad()
        tooltip.set(text: title, description: tooltipDescription)
        tooltip.modalPresentationStyle = .popover
        tooltip.popoverPresentationController?.backgroundColor = .white
        tooltip.popoverPresentationController?.delegate = self
        tooltip.popoverPresentationController?.permittedArrowDirections = arrowDirection
        tooltip.popoverPresentationController?.sourceView = sourceView
        tooltip.popoverPresentationController?.sourceRect = sourceFrame
        tooltip.preferredContentSize = tooltip.preferedSize()
        sourceViewController?.present(tooltip, animated: false)
    }
}

extension ToolTip: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

class ToolTipViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    // MARK: - Public
    
    func set(text: String, description: String) {
        titleLabel.text = text
        titleLabel.textColor = .sanRed
        titleLabel.font = .santanderHeadline(type: .bold, with: 18)
        separator.backgroundColor = .sanRed
        descriptionLabel.text = description
        descriptionLabel.font = .santanderText(type: .light, with: 16)
        descriptionLabel.textColor = .greyishBrown
    }
    
    func preferedSize() -> CGSize {
        titleLabel.sizeToFit()
        descriptionLabel.sizeToFit()
        view.layoutIfNeeded()
        let topMargin: CGFloat = 15
        let bottomMargin: CGFloat = 15
        let leftMargin: CGFloat = 10
        let rightMargin: CGFloat = 10
        let spacing = CGFloat(stackView.arrangedSubviews.count) * stackView.spacing
        let maxWidthAvailable = UIScreen.main.bounds.size.width - leftMargin - rightMargin
        let maxHeight = CGFloat.greatestFiniteMagnitude
        let descriptionLabelSize = descriptionLabel.sizeThatFits(CGSize(width: maxWidthAvailable, height: maxHeight))
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: maxWidthAvailable, height: maxHeight))
        let widthRequired = max(descriptionLabelSize.width, titleLabelSize.width)
        let heightRequired = descriptionLabelSize.height + titleLabelSize.height
        return CGSize(width: widthRequired, height: heightRequired + topMargin + bottomMargin + spacing)
    }
}

extension ToolTipViewController: XibInstantiable {
    
    static func xibName() -> String {
        return "ToolTip"
    }
}
