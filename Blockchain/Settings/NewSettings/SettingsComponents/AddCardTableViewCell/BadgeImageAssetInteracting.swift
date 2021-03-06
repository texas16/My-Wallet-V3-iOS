//
//  BadgeImageAssetInteracting.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift

protocol BadgeImageAssetPresenting {
    var state: Observable<LoadingState<BadgeImageViewModel>> { get }
}
