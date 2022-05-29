import Foundation

class BSANAssembleProvider {

    static func getAuthenticateAssembleV1() -> BSANAssemble {
        return AuthenticateCredentialAssemble.getInstance(isV1: true)
    }

    static func getAuthenticateAssembleV2() -> BSANAssemble {
        return AuthenticateCredentialAssemble.getInstance(isV1: false)
    }
	
	static func getTokenAssemble() -> BSANAssemble {
		return TokenAssemble.getInstance()
	}

    static func getGlobalPositionAssemble(_ isNew: Bool,_ isPb: Bool) -> BSANAssemble {
        return GlobalPositionAssemble.getInstance(isNew: isNew, isPB: isPb)
    }
	
	static func getUserSegmentAssemble() -> BSANAssemble {
		return UserSegmentAssemble.getInstance()
	}
    
    static func getAccountsAssemble(_ isPb: Bool) -> BSANAssemble {
        return AccountAssemble.getInstance(isPb: isPb)
    }
	
	static func getDepositAssemble() -> BSANAssemble {
		return DepositsAssemble.getInstance()
	}
	
	static func getFundTransactionsAssemble() -> BSANAssemble {
		return FundAssemble.getInstance()
	}
    
    static func getFundsAssemble() -> BSANAssemble {
        return FundAssemble.getInstance()
    }
    
    static func getFundSubscriptionAssemble() -> BSANAssemble {
        return FundSubscriptionAssemble.getInstance()
    }
    
    static func getFundTransferAssemble() -> BSANAssemble {
        return FundTransferAssemble.getInstance()
    }
	
	static func getLoanAssemble() -> BSANAssemble {
		return LoanAssemble.getInstance()
	}
    
    static func getLoanOperationsAssemble() -> BSANAssemble {
        return LoanOperationsAssemble.getInstance()
    }
    
    static func getStockAssemble() -> BSANAssemble {
        return StockAssemble.getInstance()
    }
	
	static func getPensionAssemble() -> BSANAssemble {
		return PensionAssemble.getInstance()
	}

    static func getCardsAssemble(_ isPb: Bool) -> BSANAssemble {
        return CardsAssemble.getInstance(isPB: isPb)
    }

    static func getCMCSignatureAssemble() -> BSANAssemble {
        return CMCSignatureAssemble.getInstance()
    }

    static func getPullOffersAssemble() -> BSANAssemble {
        return PullOffersAssemble.getInstance()
    }

    static func getPortfoliosAssemble() -> BSANAssemble {
        return PortfoliosAssemble.getInstance()
    }

    static func getSendMoneyAssemble() -> BSANAssemble {
        return SendMoneyAssemble.getInstance()
    }

    static func getCardsPrepaidAssemble() -> BSANAssemble {
        return CardsPrepaidAssemble.getInstance()
    }

    static func getTransfersAssemble(_ isPb: Bool) -> BSANAssemble {
        return TransfersAssemble.getInstance(isPB: isPb)
    }
    
    static func getInstantTransfersAssemble() -> BSANAssemble {
        return InstantTransfersAssemble.getInstance()
    }

    static func getCardDataAssemble() -> BSANAssemble {
        return CardDataAssemble.getInstance()
    }

    static func getPersonDataAssemble() -> BSANAssemble {
        return PersonDataAssemble.getInstance()
    }
    
    static func getBasicPersonDataAssemble() -> BSANAssemble {
        return PersonBasicDataAssemble.getInstance()
    }

    static func getSociusAssemble() -> BSANAssemble {
        return SociusAssemble.getInstance()
    }
    
    static func getMifidAssemble() -> BSANAssemble {
        return MifidAssemble.getInstance()
    }
    
    static func getPINAssemble() -> BSANAssemble {
        return PINAssemble.getInstance()
    }
    
    static func getSignatureAssemble() -> BSANAssemble {
        return SignatureAssemble.getInstance()
    }
    
    static func getBillTaxesDetailAssemble() -> BSANAssemble {
        return BillAndTaxesDetailAssemble.getInstance()
    }
    
    static func getBillTaxesAssemble() -> BSANAssemble {
        return BillTaxesAssemble.getInstance()
    }
    
    static func getChangeCardAliasAssemble() -> BSANAssemble {
        return ChangeCardAliasAssemble.getInstance()
    }
    
    static func getBillTaxesSignatureAssemble() -> BSANAssemble {
        return BillTaxesSignatureAssemble.getInstance()
    }
    
    static func getTouchIdLoginAssemble() -> BSANAssemble {
        return TouchIdLoginAssemble.getInstance()
    }
    
    static func getCVVAssemble() -> BSANAssemble {
        return CardCVVAssemble.getInstance()
    }
    
    static func getPensionOperationsAssemble() -> BSANAssemble {
        return PensionOperationsAssemble.getInstance()
    }
    
    static func getTouchIdRegisterAssemble() -> BSANAssemble {
        return TouchIdRegisterAssemble.getInstance()
    }
    
    static func getCardsPayOffAssemble() -> BSANAssemble {
        return CardsPayOffAssemble.getInstance()
    }
    
    static func getMobileRechargeAssemble(_ isPb: Bool) -> BSANAssemble {
        return MobileRechargeAssemble.getInstance(isPB: isPb)
    }
    
    static func getPayLaterAssemble() -> BSANAssemble {
        return PayLaterAssemble.getInstance()
    }
    
    static func getCardPendingTransactionsAssemble() -> BSANAssemble {
        return CardPendingTransactionsAssemble.getInstance()
    }
    
    static func getEasyPayAssemble() -> BSANAssemble {
        return EasyPayAssemble.getInstance()
    }
    
    static func getCardsCesAssemble() -> BSANAssemble {
        return CardsCesAssemble.getInstance()
    }
    
    static func getCashWithdrawalAssemble() -> BSANAssemble {
        return CashWithdrawalAssemble.getInstance()
    }

    static func getUsualTransfersAssemble() -> BSANAssemble {
        return TransfersGetUsualAssemble.getInstance()
    }
    
    static func getSepaPayeeDetailAssemble() -> BSANAssemble {
        return SepaPayeeDetailAssemble.getInstance()
    }
    
    static func getScheduledTransfersAssemble() -> BSANAssemble {
        return ScheduledTransfersAssamble.getInstance()
    }
    
    static func getEmittedTransfersAssemble() -> BSANAssemble {
        return EmittedTransferAssamble.getInstance()
    }
    
    static func getAccountsMovementPdfAssemble() -> BSANAssemble {
        return AccountsMovementPdfAssemble.getInstance()
    }
    
    static func getCardsExtractPdfAssemble() -> BSANAssemble {
        return CardsExtractPdfAssemble.getInstance()
    }
    
    static func getChangePaymentMethodAssemble() -> BSANAssemble {
        return ChangePaymentMethodAssemble.getInstance()
    }
    
    static func getNoSEPAssemble() -> BSANAssemble {
        return NoSEPAAssemble.getInstance()
    }
    
    static func getChangeLimitCardAssemble() -> BSANAssemble {
        return ChangeLimitCardAssemble.getInstance()
    }
    
    static func getAccountEasyPayAssemble() -> BSANAssemble {
        return AccountEasyPayAssemble.getInstance()
    }
    
    static func getBillsManagementAsemble() -> BSANAssemble {
        return BillsManagementAssemble.getInstance()
    }
    
    static func getReceiptReturnBillsManagementAssemble() -> BSANAssemble {
        return ReceiptReturnBillsManagementAssemble.getInstance()
    }
    
    static func getOTPPushAssemble() -> BSANAssemble {
        return OTPPushAssemble.getInstance()
    }
    
    static func getScaAssemble() -> BSANAssemble {
        return ScaAssemble.getInstance()
    }
    
    static func getChangeProductAliasAssemble() -> BSANAssemble {
        return ChangeProductAliasAssemble.getInstance()
    }
    
    static func getApplePayAssemble() -> BSANAssemble {
        return ApplePayAssemble.getInstance()
    }
    
    static func getPendingSolicitudes() -> BSANAssemble {
        return PendingSolicitudesAssamble.getInstance()
    }
    
    static func getOnePlanAssemble() -> BSANAssemble {
        return OnePlanAssemble.getInstance()
    }
}
