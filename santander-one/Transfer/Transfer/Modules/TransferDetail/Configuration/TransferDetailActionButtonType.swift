enum TransferDetailActionButtonType {
    case pdf
    case share
    case resend
    case delete
    case edit
    
    func iconFor(transferType: TransferDetailType) -> String {
        switch self {
        case .pdf:
            return "icnPdf"
        case .resend, .share:
            switch transferType {
            case .emitted:
                return "icnUpdate"
            case .received:
                return "icnShare"
            case .scheduled:
                return ""
            }
        case .delete:
            return "icnDeleteRed"
        case .edit:
            return "icnEditRed"
        }
    }
    
    func titleFor(transferType: TransferDetailType) -> String {
        switch self {
        case .pdf:
            return "deliveryDetails_button_downloadPDF"
        case .resend, .share:
            switch transferType {
            case .emitted:
                return "deliveryDetails_button_sendAgain"
            case .received:
                return "generic_button_share"
            case .scheduled:
                return ""
            }
        case .delete:
            return "generic_buttom_delete"
        case .edit:
            return "generic_buttom_edit"
        }
    }
}
