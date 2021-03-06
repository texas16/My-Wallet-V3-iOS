//
//  LabelContentPresenting.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

public protocol LabelContentPresenting {
    var stateRelay: BehaviorRelay<LabelContent.State.Presentation> { get }
    var state: Observable<LabelContent.State.Presentation> { get }
}
