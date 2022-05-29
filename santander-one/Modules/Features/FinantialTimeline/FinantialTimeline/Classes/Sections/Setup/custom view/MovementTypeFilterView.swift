//
//  MovementTypeFilterView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 18/11/2019.
//

import UIKit

class MovementTypeFilterView: UIView {
    @IBOutlet var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: GlobileCards!
    @IBOutlet weak var cardheight: NSLayoutConstraint!
    var listGroup: GlobileCheckBoxGroup = GlobileCheckBoxGroup(checkboxes: [])
    
    weak var delegate: MovementTypeFilterProtocol?
    var typeListArray: [TimeLineConfiguration.Text]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: MovementTypeFilterView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        setTitle()
    }
    
    func set(with list: [TimeLineConfiguration.Text]?, and delegate: MovementTypeFilterProtocol) {
        self.typeListArray = list
        self.delegate = delegate
        setList()
        returnSelected()
    }
    
    private func setTitle() {
        titleLabel.font = .santanderText(type: .bold, with: 17)
        titleLabel.textColor = .greyishBrown
        titleLabel.text = SetupString().displayByType
    }
    
    private func setList() {
        listGroup.removeFromSuperview()
        guard let typeList = getTypeList() else { return }
        listGroup = typeList
        cardView.addSubviewWithAutoLayout(listGroup, topAnchorConstant: .equal(to: 16), bottomAnchorConstant: .equal(to: -16), leftAnchorConstant: .equal(to: 8), rightAnchorConstant: .equal(to: -8))
        cardheight.constant = CGFloat(listGroup.checkboxes.count * 50) + 72 + 32
        delegate?.onUpdatedConstraint(cardheight.constant)
        checkLocalStorage()
    }
    
    private func getTypeList() -> GlobileCheckBoxGroup? {
        guard let thisList = typeListArray else { return nil }
        var list = [GlobileCheckBox]()
        thisList.forEach({list.append(getCheckBox(with: $0))})
        let group = GlobileCheckBoxGroup(checkboxes: list)
        group.delegate = self
        return group
    }
    
    private func getCheckBox(with text: TimeLineConfiguration.Text) -> GlobileCheckBox {
        let language = GeneralString().languageKey
        let check = GlobileCheckBox()
        check.text = text.transactionName[language]
        check.color = .turquoise
        check.isSelected = true
        return check
    }
    
    private func checkLocalStorage() {
        guard let blackList = SecureStorageHelper.getBlackList() else { return }
        listGroup.checkboxes.forEach { (check) in
            let language = GeneralString().languageKey
            if blackList.eventTypeCodes?.contains(where: {$0.transactionName[language] == check.text}) ?? false {
                check.isSelected = false
            }
        }
    }
    
}

extension MovementTypeFilterView: GlobileCheckboxGroupDelegate {
    func didSelect(checkbox: GlobileCheckBox) {
        returnSelected()
    }
    
    func didDeselect(checkbox: GlobileCheckBox) {
        returnSelected()
    }
    
    func returnSelected() {
        var returnList = [TimeLineConfiguration.Text]()
        listGroup.checkboxes.forEach { (check) in
            let language = GeneralString().languageKey
            guard !check.isSelected, let text = typeListArray?.first(where: {$0.transactionName[language] == check.text}) else { return }
            returnList.append(text)
        }
        delegate?.onUpdated(returnList)
    }
}

protocol MovementTypeFilterProtocol: AnyObject {
    func onUpdatedConstraint(_ height: CGFloat)
    func onUpdated(_ list: [TimeLineConfiguration.Text])
}
