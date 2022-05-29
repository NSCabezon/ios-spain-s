//
//  ErrorView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 19/09/2019.
//

import UIKit

class ErrorView: UIView {
    @IBOutlet var container: UIView!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var titleErrorLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: ErrorView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        prepareUI()
    }
    
    private func prepareUI() {
        errorView.isHidden = false
        titleErrorLabel.textColor = .blueGreen
        titleErrorLabel.font = .santanderText(type: .bold, with: 20)
        errorLabel.textColor = .blueGreen
        errorLabel.textAlignment = .center
        errorLabel.font = .santanderText(type: .regular, with: 14)
        errorImage.tintColor = .turquoise
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.turquoise.withAlphaComponent(0.40).cgColor
    }
    
    func setError(with title: String, and error: String, type: TimeLineEventsErrorType) {
        titleErrorLabel.text = title
        errorLabel.text = error
        errorImage.image = UIImage(fromModuleWithName: type.logo())?.withRenderingMode(.alwaysTemplate)

    }
}
