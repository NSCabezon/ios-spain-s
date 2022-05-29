import Foundation

public enum AccesibilityBills: String {
    case billOriginAccount = "transfer_OriginAccountList"
    
    public enum BillActionView {
        public static let payBillTitle = "payBillTitle"
        public static let payBillSubtitle = "payBillSubtitle"
        public static let directDebitsTitle = "directDebitsTitle"
        public static let directDebitsAppendix = "directDebitsAppendix"
        public static let directDebitsSubtitle = "directDebitsSubtitle"
    }
    
    public enum FutureBillView {
        public static let nextBillsTitle = "nextBillsTitle"
    }
    
    public enum FutureBillTimeLineView {
        public static let showTimelineItemTitle = "show_timeline_item_title"
        public static let showTimelineItemSubtitle = "show_timeline_item_subtitle"
    }
    
    public enum FutureBillEmptyView {
        public static let expenseBudgetLabel = "expenseBudgetLabel"
    }
    
    public enum FutureBillCellView {
        public static let personNameLabel = "personNameLabel"
        public static let dateLabel = "dateLabel"
        public static let amountLabel = "amountLabel"
        public static let accountLabel = "accountLabel"
    }
    
    public enum LastBillFilterView {
        public static let lastBillsTitle = "lastBillsTitle"
        public static let lastBillsSubtitle = "lastBillsSubtitle"
    }
    
    public enum LastBillFilterTagView {
        public static let filterAccount = "filterAccount"
        public static let filterStatus = "filterStatus"
        public static let filterDate = "receiptsAndTaxesTabProduct"
    }
    
    public enum LastBillDateView {
        public static let lastBillTitleTextView = "lastBillTitleTextView"
        public static let lastBillAccountTypeTextView = "lastBillAccountTypeTextView"
        public static let lastBillAmountTextView = "lastBillAmountTextView"
        public static let lastBillStateTextView = "lastBillStateTextView"
    }
    
    public enum LastBillHeaderView {
        public static let lastBillDateTextView = "lastBillDateTextView"
    }
    
    public enum LastBillEmptyView {
        public static let lastBillTitleTextView = "send_money_empty_title_textview"
        public static let lastBillMessageTextView = "send_money_empty_message_textview"
    }
    
    public enum LastBillFilterSelectionAccount {
        public static let selectionAccountFilter = "areaBtn"
    }
    
    public enum LastBillProductHeaderView {
        public static let lastBillProductTitleTextView = "lastBillProductTitleTextView"
        public static let productDeployImageView = "productDeployImageView"
        public static let lastBillProductBankImageView = "lastBillProductBankImageView"
        public static let lastBillProductShortIbanTextView = "lastBillProductShortIbanTextView"
        public static let billsAndTaxesPaymentCounterTextView = "billsAndTaxesPaymentCounterTextView"
    }
    
    public enum LastBillProductElementView {
        public static let lastBillProductTitleTextView = "lastBillProductTitleTextView"
        public static let lastBillProductDateTextView = "lastBillProductDateTextView"
        public static let lastBillProductTotalAmountTextView = "lastBillProductTotalAmountTextView"
        public static let billsAndTaxesPaymentCounterTextView = "billsAndTaxesPaymentCounterTextView"
    }
    
    public enum TransmitterHeaderView {
        public static let lastBillIssuingTitleTextView = "lastBillIssuingTitleTextView"
        public static let lastBillIssuingLastDateTextView = "lastBillIssuingLastDateTextView"
        public static let lastBillIssuingTotalAmountTextView = "lastBillIssuingTotalAmountTextView"
        public static let receiptsAndTaxesReceipsCounterTextView = "receiptsAndTaxesReceipsCounterTextView"
        public static let lastBillIssuingBankImageView = "lastBillIssuingBankImageView"
        public static let lastBillIssuingAccountTextView = "lastBillIssuingAccountTextView"
    }
    
    public enum TransmitterElementView {
        public static let lastBillCardViewIssuingItemDateTextView = "lastBillCardViewIssuingItemDateTextView"
        public static let lastBillCardViewIssuingItemAmountText = "lastBillCardViewIssuingItemAmountText"
    }
    
    public enum BillEmittersPaymentInputModeView {
        public static let codeIssuingEntity = "codeIssuingEntity"
        public static let reference = "reference"
        public static let identification = "identification"
        public static let amount = "amount"
    }
    
    public enum BillEmittersPaymentDataView {
        public static let manualMode = "manualMode"
        public static let cameraMode = "cameraMode"
    }
    
    public enum BillEmittersPaymentConfirmationView {
        public static let ammount = "ammount"
        public static let originAccount = "originAccount"
        public static let type = "type"
        public static let emitter = "emitter"
        public static let emitterCode = "emitterCode"
        public static let date = "date"
    }
    
}
