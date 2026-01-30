//
//  LifeProgressWidgetBundle.swift
//  LifeProgressWidget
//
//  Created by Shaw on 1/3/25.
//

import WidgetKit
import SwiftUI

@main
struct LifeProgressWidgetBundle: WidgetBundle {
    var body: some Widget {
        YearProgressWidget()
        MonthProgressWidget()
        // LifeProgressWidgetControl()
        // LifeProgressWidgetLiveActivity()
    }
}
