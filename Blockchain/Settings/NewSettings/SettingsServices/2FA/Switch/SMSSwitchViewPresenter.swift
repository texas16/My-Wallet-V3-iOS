//
//  SMSSwitchViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 3/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import NetworkKit
import PlatformKit
import PlatformUIKit

class SMSSwitchViewPresenter: SwitchViewPresenting {
    
    let viewModel = SwitchViewModel.primary()
    
    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()
    
    init(service: SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI) {
        interactor = SMSSwitchViewInteractor(service: service)
        
        viewModel.isSwitchedOnRelay
            .bind(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isEnabled }
            .bind(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isOn }
            .bind(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
}
