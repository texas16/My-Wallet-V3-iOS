//
//  BalanceType.swift
//  PlatformKit
//
//  Created by AlexM on 1/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum BalanceType: Hashable {
    public enum CustodialType: Hashable {
        case trading
        case savings
    }
    
    case nonCustodial
    case custodial(CustodialType)
    
    public var isCustodial: Bool {
        switch self {
        case .custodial:
            return true
        case .nonCustodial:
            return false
        }
    }
    
    public var isTrading: Bool {
        switch self {
        case .custodial(let type):
            return type == .trading
        case .nonCustodial:
            return false
        }
    }
}
