//
//  HelperFile.swift
//  Metamask-ES
//
//  Created by Beeone Innovations on 14/03/25.
//
import SocketIO
import Foundation

public typealias NetworkData = SocketData
public typealias RequestTask = Task<Any, Never>
public typealias CodableData = Codable & SocketData

struct Transaction: CodableData {
    let to: String
    let from: String
    let value: String
    let data: Data?

    init(to: String, from: String, value: String, data: Data? = nil) {
        self.to = to
        self.from = from
        self.value = value
        self.data = data
    }

    func socketRepresentation() -> NetworkData {
        [
            "to": to,
            "from": from,
            "value": value,
            "data": data as Any
        ]
    }
}

enum SupportedToken: String, CaseIterable {
    case VOW
    case DKK
    case GBP
    case ZAR
    case EUR
    case INR
    case USD
    case AUD
    case NATIVE

    var name: String {
        switch self {
        case .VOW: return "VOW"
        case .DKK: return "DKK"
        case .GBP: return "GBP"
        case .ZAR: return "ZAR"
        case .EUR: return "EUR"
        case .INR: return "INR"
        case .USD: return "USD"
        case .AUD: return "AUD"
        case .NATIVE: return "ETH"
        }
    }

    var address: String {
        switch self {
        case .VOW: return "0x1BBf25e71EC48B84d773809B4bA55B6F4bE946Fb"
        case .DKK: return "0x40a07abd0da20d9ec859c564727c10ce5cb7600e"
        case .GBP: return "0x72bf018df20fbacf542f5ec159c6a7f0d7850967"
        case .ZAR: return "0xc669b1920bb901292c11020d27d1bf7168e49eac"
        case .EUR: return "0x448fa53be5b9f792d6f799428df8d4c89eb9f04a"
        case .INR: return "0x047128bf54f643403864cb37a5df134e3ecf1bf4"
        case .USD: return "0xba7fe208e0167e4047a996e1efea830515f433f8"
        case .AUD: return "0x547649976443cd3b6ad8c9781f17f8ad6f061f2f"
        case .NATIVE: return "0x"
        }
    }
}
