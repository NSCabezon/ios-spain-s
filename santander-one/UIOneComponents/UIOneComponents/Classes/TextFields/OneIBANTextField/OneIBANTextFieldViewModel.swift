import CoreFoundationLib

public struct OneIBANTextFieldViewModel {
    let style: OneStatus?
    let filledIban: String?
    weak var delegate: OneIBANTextFieldDelegate?
    let pasteCompletion: (() -> Void)?
    let accessibilitySuffix: String?
    
    public init(style: OneStatus? = nil,
                filledIban: String? = nil,
                delegate: OneIBANTextFieldDelegate? = nil,
                pasteCompletion: (() -> Void)? = nil,
                accessibilitySuffix: String? = nil) {
        self.style = style
        self.filledIban = filledIban
        self.delegate = delegate
        self.pasteCompletion = pasteCompletion
        self.accessibilitySuffix = accessibilitySuffix
    }
}
