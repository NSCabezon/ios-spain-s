//
//  SendMoneyShareItem.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 5/4/22.
//

import CoreFoundationLib
import UI

enum SendMoneyShareItem {
    case headerImage
    case greeting(value: LocalizedStylableText, accessibilityId: String?)
    case label(keyOrValue: String, isBold: Bool, accessibilityId: String? = nil)
    case attributedString(value: NSAttributedString, accessibilityId: String? = nil)
    case labelAndImage(keyOrValue: String, imageKeyOrUrl: String, accessibilityId: String? = nil)
    case separator
    
    var view: UIView {
        let view: UIView
        switch self {
        case .headerImage:
            view = self.getHeaderImageView()
        case .greeting(let value, let accessibilityId):
            view = self.getGreetingView(value: value, accessibilityId: accessibilityId)
        case .label(let keyOrValue, let isBold, let accessibilityId):
            view = self.getLabelView(keyOrValue: keyOrValue, isBold: isBold, accessibilityId: accessibilityId)
        case .attributedString(let value, let accessibilityId):
            view = self.getAttributedView(value: value, accessibilityId: accessibilityId)
        case .labelAndImage(let keyOrValue, let imageKey, let accessibilityId):
            view = self.getLabelAndImageView(keyOrValue: keyOrValue, imageKeyOrUrl: imageKey, accessiblityId: accessibilityId)
        case .separator:
            view = self.getSeparatorView()
        }
        return view
    }
    
    enum Constants {
        static let headerImageWidth: CGFloat = 131
        static let headerImageHeight: CGFloat = 23
        static let leading: CGFloat = 21
        static let trailing: CGFloat = 23
        static let trailingSeparator: CGFloat = 52
        static let imageHeight: CGFloat = 20
    }
}

private extension SendMoneyShareItem {
    func getHeaderImageView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: Constants.headerImageWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.headerImageHeight).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = Assets.image(named: "oneIcnSantander")
        imageView.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareView.santanderImage
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leading).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        return view
    }
    
    func getGreetingView(value: LocalizedStylableText, accessibilityId: String?) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leading).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.font = .typography(fontName: .oneB400Regular)
        label.textColor = .oneLisboaGray
        label.configureText(withLocalizedString: value)
        label.accessibilityIdentifier = accessibilityId
        label.numberOfLines = 0
        return view
    }
    
    func getLabelView(keyOrValue: String, isBold: Bool, accessibilityId: String?) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leading).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.trailing * -1).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.font = isBold ? .typography(fontName: .oneB400Bold) : .typography(fontName: .oneB300Regular)
        label.textColor = .oneLisboaGray
        label.configureText(withKey: keyOrValue)
        label.numberOfLines = 0
        label.accessibilityIdentifier = accessibilityId ?? keyOrValue
        return view
    }
    
    func getAttributedView(value: NSAttributedString, accessibilityId: String?) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leading).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.trailing * -1).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.attributedText = value
        label.accessibilityIdentifier = accessibilityId
        return view
    }
    
    func getLabelAndImageView(keyOrValue: String, imageKeyOrUrl: String, accessiblityId: String?) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leading).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.font = .typography(fontName: .oneB400Bold)
        label.textColor = .oneLisboaGray
        label.accessibilityIdentifier = accessiblityId ?? keyOrValue
        label.configureText(withKey: keyOrValue)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.setImage(url: imageKeyOrUrl) { image in
            guard let image = image else {
                imageView.image = Assets.image(named: imageKeyOrUrl)
                return
            }
            let ratio = image.size.width / image.size.height
            imageView.image = image
            imageView.isHidden = imageView.image.isNil
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageHeight * ratio).isActive = true
        }
        imageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight).isActive = true
        imageView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8).isActive = true
        imageView.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        return view
    }
    
    func getSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separator)
        separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leading).isActive = true
        separator.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.trailingSeparator * -1).isActive = true
        separator.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = .oneMediumSkyGray
        return view
    }
}
