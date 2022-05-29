//
//  EditAccountOperativeHeader.swift
//  UI
//
//  Created by Juan Carlos López Robles on 5/22/20.
//

import Foundation

public protocol EditAccountOperativeHeaderDelegate: AnyObject {
    func didSelectEditAccount()
}

public final class EditAccountOperativeHeader: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var editImageVeiw: UIImageView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editButton: UIButton!
    public weak var delegate: EditAccountOperativeHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setViewModel(_ viewModel: EditAccountViewModel) {
        self.titleLabel.configureText(withKey: viewModel.title)
        self.descriptionLabel.text = viewModel.subTitle
        self.amountLabel.text = viewModel.amount
    }
    
    @IBAction func didSelectEditAccount(_ sender: Any) {
        self.delegate?.didSelectEditAccount()
    }
    
    public func getBottomLine() -> UIView {
        return self.bottomLine
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.fullFit()
    }
}

private extension EditAccountOperativeHeader {
    func setAppearance() {
        self.editButton.accessibilityIdentifier = "btnChangeAccount"
        self.backgroundColor = .skyGray
        self.containerView.backgroundColor = .skyGray
        self.editView.backgroundColor = .skyGray
        self.bottomLine.backgroundColor = .mediumSkyGray
        self.editImageVeiw.image = Assets.image(named: "icnEdit")
        self.editLabel.configureText(withKey: "generic_button_changeAccount", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
    }
}

public struct EditAccountViewModel {
    let title: String
    let subTitle: String
    let amount: String
    
    public init(title: String, subTitle: String, amount: String) {
        self.title = title
        self.subTitle = subTitle
        self.amount = amount
    }
}
