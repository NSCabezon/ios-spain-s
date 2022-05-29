//
//  SetupViewController.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 27/09/2019.
//

import UIKit

class SetupViewController: UIViewController {
    @IBOutlet weak var dateFilterView: DateFilterView!
    @IBOutlet weak var selectProductsLabel: UILabel!
    @IBOutlet weak var accountsFilterView: ProductFilterView!
    @IBOutlet weak var accountsFilterHeight: NSLayoutConstraint!
    @IBOutlet weak var cardsFilterView: ProductFilterView!
    @IBOutlet weak var cardsFilterHeight: NSLayoutConstraint!
    @IBOutlet weak var movementsFilterView: MovementTypeFilterView!
    @IBOutlet weak var movementsFilterheight: NSLayoutConstraint!
    @IBOutlet weak var confirmButton: GlobileEndingButton!
    
    var presenter: SetupPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setUI()
    }
}

// MARK: - UI
extension SetupViewController {
    func setUI() {
        self.view.backgroundColor = .white
        self.title = MenuTitle().setup
        self.view.backgroundColor = .paleGrey
        setBack()
        setViews()
        setTitles()
        setConfirmButton()
    }
    
    func setBack() {
        let barButton = UIBarButtonItem(image: UIImage(fromModuleWithName: "backButton"), style: .plain, target: self, action: #selector(onBackPressed))
        navigationItem.leftBarButtonItem = barButton
    }
    
    func setTitles() {
        selectProductsLabel.font = .santanderText(type: .bold, with: 17)
        selectProductsLabel.textColor = .greyishBrown
        selectProductsLabel.text = SetupString().displayProductsTitle
    }
    
    func setConfirmButton() {
        confirmButton.setTitle(SetupString().confirm, for: .normal)
        confirmButton.isEnabled = true
    }
    
    func setViews() {
        movementsFilterView.set(with: presenter?.getTransactionTypes(), and: self)
        dateFilterView.set(self)
       
    }
}

// MARK: - Actions
extension SetupViewController {
    @IBAction func onConfirmTap(_ sender: Any) {
        presenter?.saveBlackList()
    }
    
    @objc private func onBackPressed() {
        presenter?.didSelectBack()
    }
}

// MARK: - View Protocol
extension SetupViewController: SetupViewProtocol {
    func show(cardList: [Product]) {
        cardsFilterView.set(list: cardList, with: self, and: SetupString().cards)
        cardsFilterView.isHidden = cardList.isEmpty
    }
    
    func show(accountList: [Product]) {
        accountsFilterView.set(list: accountList, with: self, and: SetupString().accounts)
        accountsFilterView.isHidden = accountList.isEmpty
    }
}

// MARK: - StoryBoardInstatiable
extension SetupViewController: StoryBoardInstantiable {
    static func storyboardName() -> String {
        return "SetupViewController"
    }
}
