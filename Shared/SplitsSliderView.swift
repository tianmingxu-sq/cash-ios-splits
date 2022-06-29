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
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(recipient.wrappedValue.name)").fixedSize()
                                Spacer()
                                if splitsSettings.isSelfIncluded && recipient.wrappedValue.name == "Your portion" {
                                    Text("Won't be requested").fixedSize()
                                } else {
                                    Text("$\(recipient.wrappedValue.name)").fixedSize()
                                }
                            }
                            Spacer()
                            Button(String(format: "$%.2f", Float(recipient.amount.wrappedValue)/100.0)) {
                                showingSheet.toggle()
                            }
                            .sheet(isPresented: $showingSheet) {
                                SplitsKeyboardView(splitRecipient: recipient.wrappedValue)
                            }
                            .buttonStyle(CapsuleButton())
                        }
                        HStack {
                            Spacer()
                            Slider(
                                value: recipient.amount.float(),
                                in: Float(splitsSettings.minAmount)...Float(splitsSettings.totalDollarAmount - splitsSettings.minAmount),
                                step: Float(splitsSettings.sliderStep)
                            )
                            Button {
                                recipient.isLocked.wrappedValue.toggle()
                            } label: {
                                Image(recipient.isLocked.wrappedValue ? "Lock" : "Unlock")
                                    .resizable()
                                    .frame(width: 24, height: 24, alignment: .center)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        Spacer()
                    }
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

struct CapsuleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(Color(UIColor.systemGray5))
            .clipShape(Capsule())
    }
}

struct SplitsSliderView_Previews: PreviewProvider {
    static var previews: some View {
        SplitsSliderView(
            splitsSettings: SplitsSettings()
        )
    }
}

extension Binding where Value == Int {
    public func float() -> Binding<Float> {
        return Binding<Float>(get:{ Float(self.wrappedValue) },
            set: { self.wrappedValue = Int($0)})
    }
}
