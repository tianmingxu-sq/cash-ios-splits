//
//  SplitsSliderView.swift
//  splits
//
//  Created by Tianming Xu on 6/22/22.
//

import SwiftUI
import Combine

struct SplitsSliderView: View {
    @ObservedObject var splitsSettings: SplitsSettings
    @State private var showingSheet = false

    var body: some View {
        List {
            Section {
                Toggle("Including Self", isOn: $splitsSettings.isSelfIncluded)
            }
            Section {
                ForEach($splitsSettings.recipients) { recipient in
                    SplitsSliderRow(
                        recipient: recipient,
                        showingSheet: $showingSheet,
                        splitsSettings: splitsSettings
                    )
                }
            } header: {
                Text("SET UP SPLIT")
            }
            Section {
                HStack {
                    Spacer()
                    Button("Reset") {
                        splitsSettings.reset()
                    }.fixedSize()
                    Spacer()
                }
            }
        }
    }
}

struct SplitsSliderView_Previews: PreviewProvider {
    static var previews: some View {
        SplitsSliderView(
            splitsSettings: SplitsSettings()
        )
    }
}
