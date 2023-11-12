//
//  PremiumView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 11/11/23.
//

import SwiftUI
import StoreKit

struct PremiumView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var premium: Premium
    
    @State private var products: [Product] = []
    
    var body: some View {
        Group {
            if let product = products.first {
                VStack(spacing: 25) {
                    VStack {
                        Image("Bits&Bobs Icon")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 10)
                            .padding()
                        Text("bits & bobs")
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                        Text("Premium")
                            .textCase(.uppercase)
                            .font(.system(.largeTitle, weight: .bold))
                            .fontWidth(.expanded)
                    }
                    Text("Upgrade to the Premium version to create multiple collections!")
                        .font(.system(.title3, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                        .padding(.horizontal)
                    Spacer()
                    Button {
                        Task {
                            guard !premium.isActive else { dismiss(); return }
                            if await premium.purchase(product) {
                                dismiss()
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(PersistenceController.themeColor)
                            if !premium.isActive {
                                VStack {
                                    Text("Purchase for \(product.displayPrice)")
                                        .font(.system(.title2, design: .rounded, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("One-time charge")
                                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            } else {
                                HStack {
                                    Text("Unlocked")
                                    Image(systemName: "checkmark")
                                }
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: 500, maxHeight: 100)
                        .shadow(radius: 10)
                    }
                    Button {
                        Task {
                            await premium.restore(product)
                        }
                    } label: {
                        Text("Restore Purchase")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.gray)
                    }
                    .padding(.bottom, 10)
                }
                .padding()
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PersistenceController.themeColor.opacity(0.2))
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.gray.opacity(0.5))
                    .padding()
            }
        }
        .task {
            products = await premium.retrieveProducts()
        }
    }
}
