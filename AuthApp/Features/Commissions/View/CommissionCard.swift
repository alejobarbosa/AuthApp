//
//  CommissionCard.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import SwiftUI

struct CommissionCard: View {
    let commission: Commission

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(commission.carBrand) \(commission.carModel)")
                .font(Typography.body.bold())

            Text(commission.status.displayName)
                .font(Typography.caption)
                .foregroundStyle(ColorPalette.secondaryText)
            
            if let amount = commission.commissionAmount {
                Text(amount, format: .currency(code: "USD"))
                    .font(Typography.caption)
            } else {
                Text("Amount unavailable")
                    .font(Typography.caption)
                    .foregroundStyle(ColorPalette.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}
