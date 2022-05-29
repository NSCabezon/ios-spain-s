import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class FrequentDirectLinkChecker {
    
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
    }
    
    func isDirectLinkAvailable(_ directLink: DirectLinkTypeItem, completion: @escaping (Bool) -> Void) {
        switch directLink {
        case .internalTransfer:
            validateInternalTransfer(completion)
        case .transfer:
            validateTransfers(completion)
        case .pinQuery:
            validatePinQuery(completion)
        case .cvvQuery:
            validateCVVQuery(completion)
        case .activateCard:
            validateActivateCard(completion)
        case .ecash:
            validateCargeDischargeCard(completion)
        case .directMoney:
            validateDirectMoney(completion)
        case .easyPay:
            validateEasyPay(completion)
        case .cardPdfExtract:
            validatePDFExtract(completion)
        case .cesSignUp:
            validateCESSignUp(completion)
        case .payLater:
            validatePayLater(completion)
        case .billsAndTaxesPay:
            validateBillAndTaxesPay(completion)
        case .nationalTransfer:
            validateNationalTransfer(completion)
        case .withdrawMoneyWithCode:
            validateWithdrawWithCode(completion)
        case .extraordinaryContribution:
            validateExtraordinaryContirbution(completion)
        case .fundSuscription:
            validateFundSuscription(completion)
        case .marketplace:
            validateMarketplace(completion)
        case .personalArea:
            completion(true)
        case .tips:
            validateTips(completion)
        case .changePayMethod:
            validatechangeCardPayMethod(completion)
        case .myManager:
            completion(true)
        }
    }
    
    private func validateInternalTransfer(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPreSetupLocalTransfersUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validatePinQuery(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPreSetupPINQueryUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateCVVQuery(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPreSetupCVVQueryCardUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateActivateCard(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPreSetupActivateCardUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateCargeDischargeCard(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPreSetupChargeDischargeCardUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateDirectMoney(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPreSetupDirectMoneyUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateCESSignUp(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPreSetupDirectMoneyUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateTransfers(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPGDataUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            let condition = response.globalPosition.accounts.getVisibles().count > 0
            completion(condition)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validatePDFExtract(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getGetCreditCardsWithPdfUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            completion(response.cards.count > 0)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateBillAndTaxesPay(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPGDataUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            completion(response.globalPosition.accounts.getVisibles().count > 0)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateTips(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getTipsUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            completion(response.tips?.count ?? 0 > 0)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validatePayLater(_ completion: @escaping (Bool) -> Void) {
        let input = PreSetupPayLaterCardUseCaseInput(card: nil)
        let useCase = useCaseProvider.preSetupPayLaterCardUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            completion(response.cards.count > 0)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateExtraordinaryContirbution(_ completion: @escaping (Bool) -> Void) {
        let input = PreSetupPensionExtraordinaryContributionUseCaseInput(pension: nil)
        let useCase = useCaseProvider.getPreSetupPensionExtraordinaryContributionUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            completion(response.pensions.count > 0)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateWithdrawWithCode(_ completion: @escaping (Bool) -> Void) {
        let input = PreSetupWithdrawMoneyWithCodeUseCaseInput(card: nil)
        let useCase = useCaseProvider.preSetupWithdrawMoneyWithCodeUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateFundSuscription(_ completion: @escaping (Bool) -> Void) {
        let input = PreSetupFundSubscriptionUseCaseInput(fund: nil)
        let useCase = useCaseProvider.preSetupFundSubscriptionUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateNationalTransfer(_ completion: @escaping (Bool) -> Void) {
        let input = PreSetupOnePayTransferCardUseCaseInput(account: nil)
        let useCase = useCaseProvider.getPreSetupOnePayTransferCardUseCase().setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (_) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateEasyPay(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getPGDataUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            let isCardAllowingEasyPay = response.globalPosition.cards.getVisibles().contains(where: { $0.allowsEasyPay })
            completion(isCardAllowingEasyPay)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validateMarketplace(_ completion: @escaping (Bool) -> Void) {
        let useCase = useCaseProvider.getIsMarketplaceEnabledUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { (response) in
            completion(response.isEnabled)
        }, onError: { (_) in
            completion(false)
        })
    }
    
    private func validatechangeCardPayMethod (_ completion: @escaping (Bool) -> Void) {
        let input = PreSetupCardModifyPaymentFormUseCaseInput(card: nil)
        let useCase = useCaseProvider.preSetupCardModifyPaymentFormUseCase(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { ( _ ) in
            completion(true)
        }, onError: { (_) in
            completion(false)
        })
    }
}
