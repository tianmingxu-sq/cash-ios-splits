//
//  SplitsSliderRow.swift
//  splits
//
//  Created by Joseph Romero on 6/29/22.
//

import SwiftUI

struct SplitsSliderRow: View {

    @Binding var recipient: SplitsRecipient
    @Binding var showingSheet: Bool
    var splitsSettings: SplitsSettings

    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text("\(recipient.name)").fixedSize()
                    Spacer()
                    if splitsSettings.isSelfIncluded && recipient.name == "Your portion" {
                        Text("Won't be requested").fixedSize()
                    } else {
                        Text("$\(recipient.name)").fixedSize()
                    }
                }
                Spacer()
                Button(String(format: "$%.2f", Float($recipient.amount.wrappedValue)/100.0)) {
                    showingSheet.toggle()
                }
                .sheet(isPresented: $showingSheet) {
                    SplitsKeyboardView(splitRecipient: recipient)
                }
                .buttonStyle(.plain)

            }
            HStack {
                Spacer()
                Slider(
                    value: $recipient.amount.float(),
                    in: 0.0...Float(splitsSettings.totalDollarAmount),
                    step: Float(splitsSettings.sliderStep)) { isChanging in
                        if !isChanging {
                            let currentSum = splitsSettings.recipients.reduce(0) { $0+$1.amount }
                            if let previousAmount = recipient.previousAmount, currentSum > splitsSettings.totalDollarAmount || !recipient.shouldUpdate {
                                $recipient.amount.wrappedValue = previousAmount
                                $recipient.previousAmount.wrappedValue = nil
                                return
                            }
                            $recipient.isLocked.wrappedValue = true
                        }
                    }
                Button {
                    $recipient.isLocked.wrappedValue.toggle()
                } label: {
                    Image(recipient.isLocked ? "Lock" : "Unlock")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                }
                .buttonStyle(CapsuleButton())
                Spacer()
            }
            Spacer()
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

extension Binding where Value == Int {
    public func float() -> Binding<Float> {
        return Binding<Float>(get:{ Float(self.wrappedValue) },
                              set: { self.wrappedValue = Int($0)})
    }
}

struct SplitsSliderRow_Previews: PreviewProvider {

    static var previews: some View {
        SplitsSliderRow(
            recipient: .constant(.init(name: "Preview", amount: 30)),
            showingSheet: .constant(false),
            splitsSettings: SplitsSettings()
        )
        .frame(height: 100)
    }
}
