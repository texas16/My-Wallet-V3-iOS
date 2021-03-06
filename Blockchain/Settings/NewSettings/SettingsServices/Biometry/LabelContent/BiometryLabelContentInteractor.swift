//
//  BiometryLabelContentInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class BiometryLabelContentInteractor: LabelContentInteracting {
    
    typealias InteractionState = LabelContent.State.Interaction
    
    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    init(biometryProviding: BiometryProviding) {
        var title = LocalizationConstants.Settings.enableTouchID
        switch biometryProviding.supportedBiometricsType {
        case .faceID:
            title = LocalizationConstants.Settings.enableFaceID
        case .touchID:
            title = LocalizationConstants.Settings.enableTouchID
        case .none:
            break
        }
        stateRelay.accept(.loaded(next: .init(text: title)))
    }
}
