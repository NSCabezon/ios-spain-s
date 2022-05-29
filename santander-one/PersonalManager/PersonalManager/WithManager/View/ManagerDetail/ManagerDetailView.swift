//
//  ManagerDetailView.swift
//  PersonalManager
//
//  Created by alvola on 13/02/2020.
//

import UIKit
import CoreFoundationLib
import UI

struct ManagerDetailViewModel {
    let managerName: String
    let managerHobbies: String
    let imageUrl: String?
}

final class ManagerDetailView: XibView {
    @IBOutlet private weak var managerImageView: UIImageView!
    @IBOutlet private weak var closePressArea: UIView!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var managerHobbiesLabel: UILabel!
    private var viewModel: ManagerDetailViewModel?
    var closeAction: (() -> Void)?
    
    init(viewModel: ManagerDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        setupViewModel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func show() {
        alpha = 0.0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            UIView.animate(withDuration: 0.1, animations: {
                strongSelf.transform = CGAffineTransform.identity
            })
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            UIView.animate(withDuration: 0.1, animations: {
                strongSelf.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                strongSelf.alpha = 0.0
            }, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.closeAction?()
                strongSelf.removeFromSuperview()
            })
        })
    }
    
    private func commonInit() {
        configureView()
        configureLabels()
        configureClose()
    }
    
    private func configureView() {
        self.view?.layer.cornerRadius = 4.0
        self.view?.clipsToBounds = true
        managerImageView.backgroundColor = UIColor.skyGray
    }
    
    private func setupViewModel() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.managerName
        managerHobbiesLabel.configureText(withKey: viewModel.managerHobbies,
                                           andConfiguration: LocalizedStylableTextConfiguration(font: UIFont.santander(size: 15.0),
                                                                                                alignment: .left,
                                                                                                lineHeightMultiple: 0.85,
                                                                                                lineBreakMode: .byWordWrapping))
        managerHobbiesLabel.sizeToFit()
        guard let imageUrl = viewModel.imageUrl, let url = URL(string: imageUrl) else { return }
        managerImageView.setImage(url: imageUrl, placeholder: nil, completion: { [weak self] img in
            self?.managerImageView.backgroundColor = img == nil ? UIColor.white : UIColor.skyGray
        })
    }
    
    private func configureLabels() {
        nameLabel.font = UIFont.santander(type: .bold, size: 18.0)
        nameLabel.textColor = UIColor.lisboaGray
        
        managerHobbiesLabel.textColor = UIColor.lisboaGray
    }
    
    private func configureClose() {
        closeImageView.image = Assets.image(named: "icnClose")
        closePressArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePressed)))
        closePressArea.isUserInteractionEnabled = true
    }
    
    @objc private func closePressed() {
        hide()
    }
}
