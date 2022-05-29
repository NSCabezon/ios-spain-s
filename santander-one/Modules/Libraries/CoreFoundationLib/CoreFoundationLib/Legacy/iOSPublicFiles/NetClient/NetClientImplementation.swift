public class NetClientImplementation {
    public init() { }
}

private extension NetClientImplementation {
    func getDate(response: URLResponse?) -> Date? {
        guard let response = response as? HTTPURLResponse, let dateString = response.allHeaderFields["Last-Modified"] as? String else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter.date(from: dateString)
    }

    func checkHeaderDate(_ url: URL, date: Date) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = "HEAD"
        var dateHeader: Date?
        let task = URLSession.shared.dataTask(with: request) {_, response, _ in
            dateHeader = self.getDate(response: response)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if let dateHeaderUnwrapped = dateHeader {
            return dateHeaderUnwrapped.timeIntervalSince(date) <= 0
        } else {
            return false
        }
    }
    
    func load(_ url: URL) -> NetClientResponse {
        let semaphore = DispatchSemaphore(value: 0)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = "GET"
        var dateResponse: Date?
        var dataResponse: String?
        let task = URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let dataUnwrapped = data, let responseData = String(data: dataUnwrapped, encoding: .utf8) else {
                semaphore.signal()
                return
            }
            dataResponse = responseData
            dateResponse = self.getDate(response: response)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if let dataResponseUnwrapped = dataResponse {
            return .loaded(response: dataResponseUnwrapped, date: dateResponse ?? Date())
        } else {
            return .notLoaded
        }
    }
}

extension NetClientImplementation: NetClient {
    public func loadURL(_ url: String, date: Date?) -> NetClientResponse {
        guard let url = URL(string: url) else {
            return .notLoaded
        }
        if let date = date, self.checkHeaderDate(url, date: date) {
            return .notLoaded
        } else {
            return self.load(url)
        }
    }
}
