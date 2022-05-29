//
//  SecurityAreaVideoView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 23/01/2020.
//

import Foundation
import UI

protocol SecurityAreaVideoProtocol: AnyObject {
    func didSelectVideo(_ viewModel: SecurityVideoViewModel)
}

class SecurityAreaVideoView: UIView {
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var icnPlayImageView: UIImageView!
    
    // MARK: - Variables
    var view: UIView?
    weak var delegate: SecurityAreaVideoProtocol?
    var viewModel: SecurityVideoViewModel?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.xibSetup()
        configureView()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    public func setViewModel(_ viewModel: SecurityVideoViewModel) {
        self.viewModel = viewModel
        self.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.container]
        self.view?.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.action]
    }
    
    // MARK: - Setup
    private func configureView() {
        self.imageView.image = Assets.image(named: "imgSecureDevice")
        self.icnPlayImageView.image = Assets.image(named: "icnPlay")
        self.view?.isUserInteractionEnabled = true
        addAction()
    }
    
    private func addAction() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        self.view?.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapOnView() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectVideo(viewModel)
    }
}
