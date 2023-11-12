//
//  Premium.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 11/11/23.
//

import Foundation
import StoreKit

public class Premium: ObservableObject {
    
    public let ids = ["com.rupertusapps.BitsAndBobs.Premium"]

    @Published private(set) var purchasedProductIDs = Set<String>()

    // Premium is currently active
    public var isActive: Bool {
        !purchasedProductIDs.isEmpty || UserDefaults.standard.bool(forKey: "premiumActivated")
    }
    
    public init() { }
    
    // Retrieve the products from the App Store
    public func retrieveProducts() async -> [Product] {
        do {
            return try await Product.products(for: ids)
        } catch {
            print(error)
            return []
        }
    }

    // Update the transaction states on app launch
    @MainActor
    public func update() async {
        for await update in Transaction.updates {
            if case .verified(let transaction) = update {
                processTransaction(transaction)
            }
        }
    }
    
    // Process a transaction for the current session
    @MainActor
    private func processTransaction(_ transaction: Transaction) {
        if transaction.revocationDate == nil {
            self.purchasedProductIDs.insert(transaction.productID)
        } else {
            self.purchasedProductIDs.remove(transaction.productID)
        }
    }
    
    // Purchase a product
    @MainActor
    public func purchase(_ item: Product) async -> Bool {
        print("Making purchase")
        do {
            let result = try await item.purchase()
            if case .success(let verification) = result, case .verified(let transaction) = verification {
                processTransaction(transaction)
                print("Purchase was a success")
                return true
            } else {
                print("An error occurred with the purchase")
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    // Restore a product
    public func restore(_ item: Product) async {
        print("Restoring purchase")
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
}
