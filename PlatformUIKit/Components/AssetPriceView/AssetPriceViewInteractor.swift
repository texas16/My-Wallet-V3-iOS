//
//  AssetPriceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class AssetPriceViewInteractor: AssetPriceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction
    
    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        return stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(historicalPriceProvider: HistoricalFiatPriceServiceAPI) {
        historicalPriceProvider.calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    let delta = result.historicalPrices.delta
                    let currency = result.historicalPrices.currency
                    let window = result.priceWindow
                    let currentPrice = result.currentFiatValue
                    let fiatChange = FiatValue.create(
                        amount: result.historicalPrices.fiatChange,
                        currencyCode: result.currentFiatValue.currencyCode
                    )
                    return .loaded(
                        next: .init(
                            time: window.time(for: currency),
                            fiatValue: currentPrice,
                            changePercentage: delta,
                            fiatChange: fiatChange
                        )
                    )
                }
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
