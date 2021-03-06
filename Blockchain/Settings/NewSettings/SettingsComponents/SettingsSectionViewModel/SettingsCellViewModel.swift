//
//  SettingsCellViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxDataSources
import ToolKit

struct SettingsCellViewModel {
    
    var action: SettingsScreenAction {
        cellType.action
    }
    
    let cellType: SettingsSectionType.CellType
    let analyticsRecorder: AnalyticsEventRecording
    
    init(cellType: SettingsSectionType.CellType,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
        self.cellType = cellType
    }
    
    func recordSelection() {
        guard let event = cellType.analyticsEvent else { return }
        analyticsRecorder.record(event: event)
    }
}

extension SettingsCellViewModel: IdentifiableType, Equatable {
    var identity: String {
        cellType.identity
    }
    
    typealias Identity = String
    
    static func == (lhs: SettingsCellViewModel, rhs: SettingsCellViewModel) -> Bool {
        return lhs.cellType == rhs.cellType
    }
}

