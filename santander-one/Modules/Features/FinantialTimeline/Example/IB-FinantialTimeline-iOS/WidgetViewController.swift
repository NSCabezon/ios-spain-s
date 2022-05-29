//
//  WidgetViewController.swift
//  IB-FinantialTimeline-iOS
//
//  Created by Jose Ignacio de Juan Díaz on 07/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import FinantialTimeline

class WidgetViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let topView = UIView()
    let bottomView = UIView()
    
    let widgetView: UIView
    
    init(widgetView: UIView) {
        widgetView.subviews.forEach { (view) in
            if let table = view as? UITableView {
                table.topAnchor.constraint(equalTo: widgetView.topAnchor, constant: -16).isActive = true
            }
        }
        
        self.widgetView = widgetView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    func configView() {
        view.backgroundColor = .lightGray
        scrollView.addSubview(widgetView)
        view.addSubview(topView)
        view.addSubview(bottomView)
        view.addSubview(scrollView)
        
        configScrollView()
        configWidgetView()
        configTopView()
        configBottomView()
    }
    
    func configScrollView() {
        scrollView.bounces = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        scrollView.layer.borderColor = UIColor.lightGray.cgColor
        scrollView.layer.borderWidth = 1
    }
    
    func configWidgetView() {
        widgetView.backgroundColor = .white
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        widgetView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250).isActive = true
        widgetView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        widgetView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        widgetView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        widgetView.clipsToBounds = true
    }
    
    func configTopView() {
        topView.layer.cornerRadius = 4
        
        topView.backgroundColor = .black
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        topView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 2).isActive = true
        topView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        let label = UILabel()
        label.textColor = .white
        label.text = NSLocalizedString("next.days", comment: "")
        
        topView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 8).isActive = true
        label.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
    }
    
    func configBottomView() {
        bottomView.layer.cornerRadius = 4
        bottomView.backgroundColor = .white
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bottomView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -2).isActive = true
        bottomView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        let label = UILabel()
        label.textColor = .primary
        label.text = NSLocalizedString("title.time.line", comment: "")
        
        bottomView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16).isActive = true
        label.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
    }
    
}
