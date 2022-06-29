//
//  SplitsDataModel.swift
//  splits
//
//  Created by Tianming Xu on 6/22/22.
//

import Foundation
import Combine

class SplitsSettings: ObservableObject {
    @Published var numberOfRecipients: Int = 2 {
        didSet {
            reset()
        }
    }
    @Published var isSelfIncluded: Bool = false {
        didSet {
            reset()
        }
    }
    @Published var totalDollarAmount: Int = 10000 {
        didSet {
            reset()
        }
    }
    @Published var sliderStep: Int = 100 {
        didSet {
            reset()
        }
    }
    @Published var recipients: [SplitsRecipient] = []
    var newRecipients: [SplitsRecipient] = []
    let minAmount = 100

    func reset() {
        let recipientsCount = isSelfIncluded ? numberOfRecipients + 1 : numberOfRecipients
        let splittedAmount = totalDollarAmount / recipientsCount // Floor the result 100 / 3 -> 33
        let remain = totalDollarAmount - splittedAmount * recipientsCount
        let firstAmount = remain + splittedAmount
        recipients = (0...numberOfRecipients).compactMap { no in
            if no == 0 {
                if isSelfIncluded {
                    // If has reamin, add it to self
                    return SplitsRecipient(name: "Your portion", amount: firstAmount, self)
                }
                return nil
            }
            if no == 1 {
                return SplitsRecipient(name: "Recipient \(no)", amount: isSelfIncluded ? splittedAmount : firstAmount, self)
            }
            return SplitsRecipient(name: "Recipient \(no)", amount: splittedAmount, self)
        }

    }

    func update(_ recipient: SplitsRecipient, amount: Int, previousAmount: Int) -> Bool {
        let diff = amount - previousAmount
        let recipientsCount = recipients.reduce(
            0, {
                if $1.isLocked || $1.id == recipient.id {
                    return $0
                } else {
                    return $0+1
                }
            }
        )

        // If no movable recipients return false
        guard recipientsCount > 0 else { return false }

        let splittedAmount = diff / recipientsCount // Floor the result 100 / 3 -> 33

        // If some amount is smaller than minAmount return false
        let overLimitRecipientsCount = recipients.reduce(
            0, {
                if !$1.isLocked && ($1.id != recipient.id && $1.amount-splittedAmount < minAmount) {
                    return $0+1
                } else {
                    return $0
                }
            }
        )
        guard overLimitRecipientsCount == 0 else { return false }

        let remain = diff - splittedAmount * recipientsCount
        var hasCountRemain = remain == 0
        newRecipients = recipients.map{ re in
            if re.id == recipient.id {
                return recipient
            }
            if re.isLocked { return re }
            if hasCountRemain {
                return SplitsRecipient(name: re.name, amount: re.amount-splittedAmount, self, isLocked: re.isLocked)
            } else {
                hasCountRemain = true
                return SplitsRecipient(name: re.name, amount: re.amount-splittedAmount-remain, self, isLocked: re.isLocked)
            }
        }
        return true
    }

    init() {
        recipients = [
            SplitsRecipient(name: "Recipient 1", amount: 5000, self),
            SplitsRecipient(name: "Recipient 2", amount: 5000, self)
        ]
    }
}

class SplitsRecipient: ObservableObject, Identifiable {
    let name: String
    let id = UUID()
    weak var parent: SplitsSettings?
    @Published var amount: Int {
        willSet {
            shouldUpdate = self.parent?.update(self, amount: newValue, previousAmount: amount) ?? false
        }
        didSet {
            if let newRecipients = self.parent?.newRecipients, shouldUpdate {
                self.parent?.recipients = newRecipients
            } else if !isUpdating && amount != oldValue {
                isUpdating = true
                amount = oldValue
                isUpdating = false
            }
        }
    }
    @Published var isLocked: Bool = false
    @Published var shouldUpdate: Bool = true
    var isUpdating = false
    init(name: String, amount: Int, _ parent:SplitsSettings? = nil, isLocked: Bool = false) {
        self.name = name
        self.amount = amount
        self.parent = parent
    }
}
