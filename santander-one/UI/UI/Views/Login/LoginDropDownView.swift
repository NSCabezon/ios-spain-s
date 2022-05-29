//
//  LoginDropDownView.swift
//  RetailClean
//
//  Created by Carlos Monfort Gómez on 23/12/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib

public protocol DropDownProtocol: AnyObject {
    func loginTypeSelected(type: LoginIdentityDocumentType)
}

public class LoginDropDownView: UIView {
    private var loginTypes = [LoginIdentityDocumentType]()
    private var typeSelected: LoginIdentityDocumentType = .nif
    private var tableView = UITableView()
    public weak var delegate: DropDownProtocol!
    private var viewWidth: CGFloat = 0
    private var viewPositionReference: CGRect?
    private var isDropDownPresent: Bool = false
    public var selectionColor = UIColor.lightSanGray
    // MARK: - Configuration
    public func setUpDropDown(viewPositionReference: CGRect) {
        LoginIdentityDocumentType.allCases.forEach({loginTypes.append($0)})
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY, width: 0, height: 0)
        tableView = UITableView(frame: CGRect(x: self.frame.minX, y: self.frame.maxY, width: 0, height: 0))
        self.viewWidth = viewPositionReference.width
        self.viewPositionReference = viewPositionReference
        configureTableView()
    }
    
    public func refreshPosition(viewPositionReference: CGRect) {
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY, width: 0, height: 0)
        self.viewPositionReference = viewPositionReference
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        roundBottomCorners(5.0)
    }
    
    // MARK: - Present Menu
    
    public  func toogleDropDown() {
        if isDropDownPresent {
            self.hideDropDown()
        } else {
            presentDropDown()
        }
    }
    
    public func hideDropDown() {
        isDropDownPresent = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.viewWidth, height: 0)
            self.tableView.frame.size = CGSize(width: self.viewWidth, height: 0)
        })
    }
    
    // MARK: - Getters
    
    public func getTypeSelected() -> LoginIdentityDocumentType {
        return self.typeSelected
    }
    
    public func getIsDropDownPresent() -> Bool {
        return self.isDropDownPresent
    }
}

private extension LoginDropDownView {
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isUserInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
    }
    
    func roundBottomCorners(_ radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            roundCornersInOlderVersions(radius)
        }
    }
    
    func roundCornersInOlderVersions(_ radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func presentDropDown() {
        isDropDownPresent = true
        self.frame = CGRect(x: self.viewPositionReference?.minX ?? 0, y: self.viewPositionReference?.maxY ?? 0, width: viewWidth, height: 0)
        self.tableView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 0)
        self.tableView.reloadData()
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            self.frame.size = CGSize(width: self.viewWidth, height: self.tableView.contentSize.height)
            self.tableView.frame.size = CGSize(width: self.viewWidth, height: self.tableView.contentSize.height)
        })
    }
    
    // MARK: - TableView
    func getDropDownCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = localized(loginTypes[indexPath.row].stringValue)
        if loginTypes[indexPath.row] == typeSelected {
            cell.textLabel?.font = UIFont.santander(family: .text, type: .bold, size: 15)
            cell.backgroundColor = selectionColor
        } else {
            cell.textLabel?.font = UIFont.santander(family: .text, type: .regular, size: 15)
        }
        cell.accessibilityIdentifier = getAccessibilityIdentifier(loginTypes[indexPath.row])
        return cell
    }
    
    private func dropDownDidSelectRow(_ indexPath: IndexPath) {
        self.typeSelected = loginTypes[indexPath.row]
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.toogleDropDown()
        self.delegate.loginTypeSelected(type: loginTypes[indexPath.row])
    }
    
    func getAccessibilityIdentifier(_ type: LoginIdentityDocumentType) -> String {
        switch type {
        case .nif: return AccessibilityUnrememberedLoginType.nif
        case .nie: return AccessibilityUnrememberedLoginType.nie
        case .cif: return AccessibilityUnrememberedLoginType.cif
        case .passport: return AccessibilityUnrememberedLoginType.passport
        case .user: return AccessibilityUnrememberedLoginType.user
        }
    }
}

extension LoginDropDownView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loginTypes.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getDropDownCell(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dropDownDidSelectRow(indexPath)
    }
}
