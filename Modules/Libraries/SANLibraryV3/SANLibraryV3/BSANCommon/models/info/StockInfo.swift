import Foundation

public struct StockInfo: Codable {
    public var stockListDictionary = [String : StockListDTO]()
    public var stockQuoteDetailDictionary = [String : StockQuoteDetailDTO]()
    public var stockOrdersListDictionary = [String : OrderListDTO]()
    public var stockOrderDetailsDictionary = [String : OrderDetailDTO?]()

    public mutating func add(stockList: StockListDTO, contract: String) {
        var stockListToAdd = stockList.stockListDTO ?? []
        var storedStockList = stockListDictionary[contract]
        if let storedStockList = storedStockList{
            let storedList = storedStockList.stockListDTO
            if let oldContentToInsertInNew = storedList{
                for stock in oldContentToInsertInNew{
                    if !stockListToAdd.contains(where: {$0.stockQuoteDTO.getLocalId() == stock.stockQuoteDTO.getLocalId()}) {
                        stockListToAdd.append(stock)
                    } else {
                        if let index = stockListToAdd.firstIndex(where: {$0.stockQuoteDTO.getLocalId() == stock.stockQuoteDTO.getLocalId()}) {
                            stockListToAdd[index] = stock
                        }
                    }
                }
            }
        }
        storedStockList = StockListDTO(stockListDTO: stockListToAdd, pagination: stockList.pagination, positionAmount: stockList.positionAmount)
        stockListDictionary[contract] = storedStockList
    }
    
    public mutating func add(ordersList: OrderListDTO?, contract: String) {

        guard let ordersList = ordersList, let ordersListToAdd = ordersList.orders else {
            stockOrdersListDictionary[contract] = nil
            stockOrderDetailsDictionary[contract] = nil
            return
        }
        
        var storedOrdersList = stockOrdersListDictionary[contract]
        var newList: [OrderDTO] = []
        
        if let oldContentToInsertInNew = storedOrdersList?.orders {
            for order in oldContentToInsertInNew {
                newList.append(order)
            }
        }
        
        newList += ordersListToAdd
        
        storedOrdersList = OrderListDTO(orders: newList, pagination: ordersList.pagination)
        stockOrdersListDictionary[contract] = storedOrdersList
    }
    
    public mutating func removeOrderDetail(contractId: String) {
        stockOrderDetailsDictionary[contractId] = nil
    }
    
    public mutating func removeStockOrderList() {
        stockOrdersListDictionary.removeAll()
        stockOrderDetailsDictionary.removeAll()
    }
}

