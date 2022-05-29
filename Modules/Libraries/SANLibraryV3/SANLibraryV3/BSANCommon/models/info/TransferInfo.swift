import Foundation

public struct TransferInfo: Codable {
    public var usualTransfersList: [PayeeDTO] = []
    public var microFavouriteTransferList: [PayeeDTO] = []
    private var transfersEmittedDictionary: [String: TransferEmittedListDTO] = [:]
    private var emptyTransfersEmittedDictionary: [String: TransferEmittedListDTO] = [:]
    public var transfersScheduledDictionary: [String: TransferScheduledListDTO] = [:]
    public var transfersEmittedDetailDictionary: [String: TransferEmittedDetailDTO] = [:]
    public var transfersScheduledDetailDictionary: [String: TransferScheduledDetailDTO] = [:]
    
    public mutating func addTransferEmittedCache(transferEmittedListDTO: TransferEmittedListDTO, contract: String) {
        var newStoredTransactions = Set(transfersEmittedDictionary[contract]?.transactionDTOs ?? [TransferEmittedDTO]())
        transferEmittedListDTO.transactionDTOs.forEach { newStoredTransactions.insert($0) }
        transfersEmittedDictionary[contract] = TransferEmittedListDTO(transactionDTOs: Array(newStoredTransactions), paginationDTO: transferEmittedListDTO.paginationDTO)
    }
    
    public func getTransferEmittedCacheFor(_ contract: String) -> TransferEmittedListDTO? {
        return transfersEmittedDictionary[contract]
    }

    public mutating func addEmptyTransferEmittedCache(contract: String) {
        emptyTransfersEmittedDictionary[contract] = TransferEmittedListDTO()
    }
    
    public func getEmptyTransferEmittedCacheFor(_ contract: String) -> TransferEmittedListDTO? {
        return emptyTransfersEmittedDictionary[contract]
    }
    
    public mutating func addTransferScheduled(transferScheduledListDTO: TransferScheduledListDTO, contract: String) {
        var storedTransactions = transfersScheduledDictionary[contract]?.transactionDTOs ?? []
        transferScheduledListDTO.transactionDTOs.forEach {
            if !storedTransactions.contains($0) {
                storedTransactions.append($0)
            }
        }
        transfersScheduledDictionary[contract] = TransferScheduledListDTO(transactionDTOs: storedTransactions, paginationDTO: transferScheduledListDTO.paginationDTO)
    }
    
    public mutating func removeScheduledTransfer(scheduledTransferDTO: TransferScheduledDTO, contract: String) {
        guard let index = transfersScheduledDictionary[contract]?.transactionDTOs.firstIndex(where: { $0 == scheduledTransferDTO }) else { return }
        transfersScheduledDictionary[contract]?.transactionDTOs.remove(at: index)
    }
    
    public mutating func removeFavouriteTransfer() {
        microFavouriteTransferList.removeAll()
    }
    
    public func getTransfersEmitted() -> [String: TransferEmittedListDTO] {
        return transfersEmittedDictionary
    }

}
