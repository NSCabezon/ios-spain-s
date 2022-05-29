//
//  PersonalAreaPromptDialog.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 23/11/2020.
//

import CoreFoundationLib

final public class PromptDialogBuilder {
    var items = [LisboaDialogItem]()
    let info: PromptDialogInfo
    let identifiers: PromptDialogInfoIdentifiers
    
    public init(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers) {
        self.info = info
        self.identifiers = identifiers
    }
    
    public func build() -> [LisboaDialogItem] {
        self.addItems()
        return self.items
    }
}

// MARK: - Private Methods
private extension PromptDialogBuilder {
    
    func addItems() {
        addMargin(27)
        addTitle()
        addMargin(8)
        addDescription()
        addMargin(23)
        addQuestionText()
        addMargin(16)
        addAcceptAction()
        addMargin(10)
        addCanceltAction()
        addMargin(16)
    }
    
    func addTitle() {
        guard let title = info.title else { return }
        let titleItem: LisboaDialogItem = .styledText(
            LisboaDialogTextItem(text: title,
                                 font: .santander(size: 28),
                                 color: .lisboaGray,
                                 alignament: .center,
                                 margins: (25, 25),
                                 accesibilityIdentifier: identifiers.title,
                                 lineHeightMultiple: 0.75)
        )
        items.append(titleItem)
    }
    
    func addDescription() {
        guard let description =  info.description else { return }
        let descriptionItem: LisboaDialogItem = .styledText(LisboaDialogTextItem(
            text: description,
            font: .santander(size: 16),
            color: .lisboaGray,
            alignament: .center,
            margins: (25, 25),
            accesibilityIdentifier: identifiers.body)
        )
        items.append(descriptionItem)
    }
    
    func addQuestionText() {
        guard let question = info.questionText else { return }
        let questionTextItem: LisboaDialogItem = .styledText(LisboaDialogTextItem(
            text: question,
            font: .santander(type: .bold, size: 18),
            color: .lisboaGray,
            alignament: .center,
            margins: (25, 25),
            accesibilityIdentifier: identifiers.question)
        )
        items.append(questionTextItem)
    }
    
    func addAcceptAction() {
        guard let acceptText = info.acceptButtonText,
              let acceptAction = info.acceptAction
        else { return }
        let acceptItem: LisboaDialogItem = .verticalAction(
            VerticalLisboaDialogAction(
                title: acceptText,
                type: .red,
                margins: (12, 12),
                accesibilityIdentifier: identifiers.acceptButton,
                action: acceptAction)
        )
        items.append(acceptItem)
    }
    
    func addCanceltAction() {
        guard let cancelText = info.cancelButtonText,
              let cancelAction = info.cancelAction
        else { return }
        let cancelItem: LisboaDialogItem =  .verticalAction(VerticalLisboaDialogAction(
            title: cancelText,
            type: .custom(backgroundColor: .clear,
                          titleColor: .darkTorquoise,
                          font: .santander(family: .text, type: .regular, size: 16)
            ),
            margins: (12, 12),
            accesibilityIdentifier: identifiers.cancelButton,
            isCancelAction: true,
            action: cancelAction)
        )
        items.append(cancelItem)
    }
    
    func addMargin(_ margin: CGFloat) {
        items.append(.margin(margin))
    }
}
