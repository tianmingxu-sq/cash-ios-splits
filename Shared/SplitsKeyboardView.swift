//
//  SplitsKeyboardView.swift
//  splits
//
//  Created by Tianming Xu on 6/22/22.
//

import SwiftUI

struct SplitsKeyboardView: View {
    @ObservedObject var splitRecipient: SplitsRecipient
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Set amount for \(splitRecipient.name) ").font(.title)
                Spacer()
                TextField("", value: $splitRecipient.amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .fixedSize()
                    .font(.title)
                Spacer()
                Text("Here is the keyboard").font(.title)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(.title)
                .padding()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark").frame(width: 48, height: 48, alignment: .center)
                    }
                }
            }
        }
    }
}

struct SplitsKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        SplitsKeyboardView(splitRecipient: SplitsRecipient(name: "", amount: 1))
    }
}
