//
//  GenericErrorDialogAction.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 14/04/2020.
//

import Foundation

final class GenericErrorDialogActionView: XibView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var actionImageView: UIImageView!
    @IBOutlet private weak var arrowImageView: UIImageView! {
        didSet {
            self.arrowImageView.image = Assets.image(named: "icnArrowGrey")
        }
    }
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separator: PointLine!
    
    // MARK: - Private
    
    private var viewModel: GenericErrorDialogViewModel.Action?
    
    // MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setupWithViewModel(_ viewModel: GenericErrorDialogViewModel.Action) {
        self.viewModel = viewModel
        self.actionImageView.image = Assets.image(named: viewModel.logo)?.withRenderingMode(.alwaysTemplate)
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        if let description = viewModel.description {
            self.descriptionLabel.isHidden = false
            self.descriptionLabel.configureText(withLocalizedString: description,
                                                andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        } else {
            self.descriptionLabel.isHidden = true
        }
        switch viewModel.position {
        case .last:
            self.separator.isHidden = true
        case .unknown:
            self.separator.isHidden = false
        }
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectAction)))
    }
    
    // MARK: - Objc methods
    
    @objc func didSelectAction() {
        self.viewModel?.action()
    }
}

private extension GenericErrorDialogActionView {
    
    func setup() {
        self.actionImageView.tintColor = .white
        self.titleLabel.setSantanderTextFont(type: .regular, size: 16, color: .white)
        self.descriptionLabel.setSantanderTextFont(type: .regular, size: 12, color: .white)
    }
}
