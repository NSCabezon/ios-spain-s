//
//  LoadingTipsViewController.swift
//  UI
//
//  Created by Luis Escámez Sánchez on 07/02/2020.
//

import UIKit
import CoreFoundationLib

public protocol LoadingTipViewProtocol: AnyObject {
    func configureView(with viewModel: LoadingTipViewModel?)
}

public class LoadingTipViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tipImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var giftViewTitle: UILabel!
    private let presenter: LoadingTipPresenterProtocol
    
    public init(presenter: LoadingTipPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "LoadingTipViewController", bundle: .module)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter.viewDidLoad()
    }
    
    private func setupViews() {
        setFonts()
        setStrings()
        blankAllViewsBackground()
    }
}

extension LoadingTipViewController: LoadingTipViewProtocol {
    
    public func configureView(with viewModel: LoadingTipViewModel?) {
        if let viewModel = viewModel {
            self.tipImageView.contentMode = .scaleAspectFit
            self.tipImageView.image = Assets.image(named: viewModel.imageName)
            self.titleLabel.text = viewModel.mainTitle
            self.fullTitleLabel.attributedText = createAttributedString(with: viewModel.title, and: viewModel.boldTitle)
            self.fullTitleLabel.textAlignment = .center
            self.subtitleLabel.text = viewModel.subtitle
            self.initializeGiftAnimation()
        } else {
            self.initializeGiftAnimation()
        }
    }
}

private extension LoadingTipViewController {
    
    func createAttributedString(with normalTtile: String, and boldTitle: String) -> NSAttributedString {
        
        let attributedTitle = NSMutableAttributedString(string: normalTtile + "\n",
                                                        attributes: [
                                                            .font: UIFont(name: "SantanderText-Regular", size: 24.0)!,
                                                            .foregroundColor: UIColor.lisboaGray
        ])
        
        let attributedBoldTitle = NSMutableAttributedString(string: boldTitle,
                                                            attributes: [
                                                                .font: UIFont(name: "SantanderText-Bold", size: 24.0)!,
                                                                .foregroundColor: UIColor.lisboaGray
        ])
        
        attributedTitle.append(attributedBoldTitle)
        
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineSpacing = CGFloat(1.0)
        
        let stringLength = attributedTitle.string.count
        attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle,
                                     value: mutableParagraphStyle,
                                     range: NSRange(location: 0, length: stringLength))
        
        return attributedTitle
    }
    
    func setFonts() {
        self.fullTitleLabel.font = UIFont(name: "SantanderText-Bold", size: 16.0)
        self.fullTitleLabel.textColor = UIColor.santanderRed
        self.subtitleLabel.font = UIFont(name: "SantanderText-Regular", size: 18.0)
        self.subtitleLabel.textColor = UIColor.grafite
        giftViewTitle.font = UIFont.santander(family: .text, type: .regular, size: 12)
        giftViewTitle.textColor = .lisboaGray
    }
    
    func setStrings() {
        self.giftViewTitle.text = localized("generic_label_secureConnection")
    }
    
    func blankAllViewsBackground() {
        [containerView, tipImageView, titleLabel, fullTitleLabel, subtitleLabel, giftImageView, giftViewTitle].forEach {
                $0?.backgroundColor = .clear
        }
    }
    
    func initializeGiftAnimation() {
        self.giftImageView.setJumpingLoader()
    }
}
