//
//  ViewControllerExtension.swift
//  BranchLocator
//
//  Created by Daniel Rincon on 10/06/2019.
//

import Foundation


func addNavBarImage(imageName: String, navigationItem: UINavigationItem) {
    
    
    let imageView = UIImageView.init(image: UIImage.init(named: imageName))
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 16))
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)
    
    navigationItem.titleView = view
    imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CGFloat(0.6)).isActive = true
    
    view.heightAnchor.constraint(equalTo: navigationItem.titleView!.heightAnchor).isActive = true
    view.centerXAnchor.constraint(equalTo: navigationItem.titleView!.centerXAnchor).isActive = true
    view.centerYAnchor.constraint(equalTo: navigationItem.titleView!.centerYAnchor).isActive = true
}

func loadCustomTitleView() -> UIView {
    let titleLbl = UILabel()
    let color = UIColor.santanderRed
    let font = UIFont(name: "SantanderHeadline-Bold", size: 18)
    let title = localizedString("bl_braches_and_atms")
    let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font,
                                                     NSAttributedString.Key.foregroundColor: color]
    titleLbl.attributedText = NSAttributedString(string: title, attributes: attributes)
    titleLbl.sizeToFit()
    return titleLbl
}
