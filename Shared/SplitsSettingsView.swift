//
//  ContentView.swift
//  Shared
//
//  Created by Tianming Xu on 6/22/22.
//

import SwiftUI
import Combine

struct SplitsSettingsView: View {
    @StateObject var splitsSetting: SplitsSettings = SplitsSettings()
    var body: some View {
        NavigationView{
            Form {
                Section {
                    HStack {
                        Text("Total Amount in cents: ")
                        Spacer()
                        TextField("", value: $splitsSetting.totalDollarAmount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .fixedSize()
                    }
                    Text("Number of recipients: \(splitsSetting.numberOfRecipients)")
                    Picker("", selection: $splitsSetting.numberOfRecipients) {
                        ForEach(Range(2...10)) {
                            Text("\($0)").tag($0)
                        }
                    }
                    .pickerStyle(.wheel)
                    Toggle("Including Self", isOn: $splitsSetting.isSelfIncluded)
                    HStack {
                        Text("Slider step in cents: ")
                        Spacer()
                        TextField("", value: $splitsSetting.sliderStep, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .fixedSize()
                    }
                } header: {
                    Text("Split Settings")
                }
                Section {
                    NavigationLink {
                        SplitsSliderView(splitsSettings: splitsSetting)
                    } label: {
                        Button("Split it!") {}
                    }

                }
            }
        }
    }
}

struct SplitsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SplitsSettingsView()
    }
}
