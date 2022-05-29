//
//  Constants.swift
//  Transfer
//
//  Created by alvola on 29/06/2021.
//

public enum TransferEmittedDetailAccessibilityIdentifier {
    public static let amountTitle = "deliveryDetails_label_amount"
    public static let amount = "transferEmittedLabelAmount"
    public static let conceptTitle = "deliveryDetails_label_concept"
    public static let concept = "transferEmittedLabelConcept"
    public static let beneficiary = "transferEmittedLabelBeneficiary"
    public static let account = "transferEmittedLabelAccount"
    public static let arrowButton = "transferEmittedBtnArrow"
    public static let destinationTitle = "transferEmittedLabelDestinationTitle"
    public static let shareButton = "transferEmittedViewShareButton"
    public static let bankImage = "transferEmittedViewBankImage"
    public static let transferEmittedLabelOriginAccount = "transferEmittedLabelOriginAccount"
    public static let transferEmittedLabelTransferType = "transferEmittedLabelTransferType"
    public static let transferEmittedLabelDestinationCountry = "transferEmittedLabelDestinationCountry"
    public static let transferEmittedLabelEmissionDate = "transferEmittedLabelEmissionDate"
    public static let transferEmittedLabelValueDate = "transferEmittedLabelValueDate"
    public static let transferEmittedLabelFee = "transferEmittedLabelFee"
}

public enum TransferReceivedDetailAccessibilityIdentifier {
    public static let amount = "transferReceivedLabelAmount"
    public static let concept = "transferReceivedLabelConcept"
    public static let destinationAccount = "transferReceivedLabelDestinationAccount"
    public static let operationDate = "transferReceivedLabelOperationDate"
    public static let valueDate = "transferReceivedLabelValueDate"
    public static let transferReceivedLabelTypeValue = "deliveryDetails_label_receiveTransfer"
    public static let transferReceivedLabelOriginAccount = "transferReceivedLabelOriginAccount"
}

public enum ScheduledTransferDetailAccessibilityIdentifier {
    public static let concept = "scheduledTransferLabelConcept"
    public static let scheduledTransferLabelOriginAccount = "scheduledTransferLabelOriginAccount"
    public static let scheduledTransferLabelDestinationCountry = "scheduledTransferLabelDestinationCountry"
    public static let scheduledTransferLabelPeriodicity = "scheduledTransferLabelPeriodicity"
    public static let scheduledTransferLabelEmissionDate = "scheduledTransferLabelEmissionDate"
    public static let scheduledTransferLabelNextEmissionDate = "scheduledTransferLabelNextEmissionDate"
}

public enum ScheduledTransfersListAccessibilityIdentifier {
    public static let scheduledTransfersSegmentedPeriodic = "transfer_tab_periodic"
    public static let scheduledTransfersSegmentedScheduled = "transfer_tab_scheduled"
    public static let scheduledTransfersBtnNewTrasfers = "onePay_button_newScheduledTransfer"
    public static let scheduledTransfersPeriodicConcept = "scheduledTransfersPeriodicLabelConcept"
    public static let scheduledTransfersPeriodicDate = "scheduledTransfersPeriodicDate"
    public static let scheduledTransfersPeriodicAmount = "scheduledTransfersPeriodicAmount"
    public static let scheduledTransfersPeriodicTransferCell = "scheduledTransfersPeriodicTransferCell"
    public static let scheduledTransfersScheduledConcept = "scheduledTransfersScheduledConcept"
    public static let scheduledTransfersScheduledDescription = "scheduledTransfersScheduledDescription"
    public static let scheduledTransfersScheduledAmount = "scheduledTransfersScheduledAmount"
    public static let scheduledTransfersScheduledTransferCell = "scheduledTransfersScheduledTransferCell"
    public static let scheduledTransfersEmptyImage = "imgLeaves"
}
