//
//  ConfirmationItemView.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 07/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

// Changed to public in order to use in TransferConfirmViewController. It'd be reverse when all Operatives working on Lisboa
public class ConfirmationItemView: UIView {
    
    private var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var pointLine: PointLine!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    private var viewModel: ConfirmationItemViewModel?
    private var groupedAccessibilityElements: [Any]?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setup(with viewModel: ConfirmationItemViewModel) {
        self.viewModel = viewModel
        self.adjustConstraintsForPosition(viewModel.position)
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        self.valueLabel.attributedText = viewModel.value
        self.valueLabel.numberOfLines = 0
        self.valueLabel.set(lineHeightMultiple: 0.85)
        self.setInfo(viewModel.info)
        self.setAction(viewModel.action)
        self.pointLine.isHidden = viewModel.position == .last
        self.setupAccessibilityId()
    }
    
    @IBAction private func actionButtonSelected(_ sender: UIButton) {
        self.viewModel?.action?.action()
    }
}

private extension ConfirmationItemView {
    
    func setupView() {
        self.xibSetup()
        self.titleLabel.setSantanderTextFont(size: 13, color: .grafite)
        self.valueLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.infoLabel.setSantanderTextFont(type: .regular, size: 14, color: .lisboaGray)
        self.actionButton.setTitleColor(.darkTorquoise, for: .normal)
        self.actionButton.titleLabel?.font = .santander(family: .text, size: 14)
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view)
        self.view.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func adjustConstraintsForPosition(_ position: ConfirmationItemViewModel.Position) {
        switch position {
        case .first:
            self.topLayoutConstraint.constant = 19
        case .last:
            self.bottomLayoutConstraint.constant = 26
            self.pointLine.isHidden = true
        case .unknown: break
        }
    }
    
    func setInfo(_ info: NSAttributedString?) {
        guard let info = info else { return self.infoLabel.isHidden = true }
        self.infoLabel.attributedText = info
    }
    
    func setAction(_ action: ConfirmationItemAction?) {
        guard let action = action
        else { return self.actionButton.isHidden = true }
        self.actionButton.setTitle(action.title, for: .normal)
        self.actionButton.accessibilityLabel = action.title
    }
    
    func setupAccessibilityId() {
        guard let accessibilityIdentifier = viewModel?.accessibilityIdentifier,
        let value = viewModel?.value else { return }
        self.accessibilityIdentifier = accessibilityIdentifier
        self.titleLabel.accessibilityIdentifier = accessibilityIdentifier + "_title"
        self.valueLabel.accessibilityIdentifier = accessibilityIdentifier + "_value"
        self.infoLabel.accessibilityIdentifier = accessibilityIdentifier + "_info"
        self.actionButton.accessibilityIdentifier = accessibilityIdentifier + "_action_button"
    }
}
