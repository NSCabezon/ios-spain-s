//
//  TrusteerInfoDTO.swift
//
//  Created by José Carlos Estela Anguita on 29/10/2020.
//

public struct TrusteerInfoDTO {
    public let userAgent: String
    public let customerSessionId: String
    public let disabledServicesIP: [String]
    public var remoteAddr: String {
        return self.getAddress(for: .wifi) ?? self.getAddress(for: .cellular) ?? ""
    }
    
    public init(userAgent: String, customerSessionId: String, disabledServicesIP: [String]) {
        self.userAgent = userAgent
        self.customerSessionId = customerSessionId
        self.disabledServicesIP = disabledServicesIP
    }
}

private extension TrusteerInfoDTO {

    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
    }
    
    func getAddress(for network: Network) -> String? {
        var address: String?
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPv4:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
}
