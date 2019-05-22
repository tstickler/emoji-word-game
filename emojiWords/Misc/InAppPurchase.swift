//
//  InAppPurchase.swift
//  emojiWords
//
//  Created by Tyler Stickler on 5/6/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import Foundation
import StoreKit

enum IAP: String {
    case OneHundredGems     = "com.tstick.Spinmoji.OneHundredGems"
    case TwoFiftyGems       = "com.tstick.Spinmoji.TwoFiftyGems"
    case SevenFiftyGems     = "com.tstick.Spinmoji.SevenFiftyGems"
    case TwoThousandGems    = "com.tstick.Spinmoji.TwoThousandGems"
    case FiveThousandGems   = "com.tstick.Spinmoji.FiveThousandGems"
    case WatermelonPack     = "com.tstick.Spinmoji.WatermelonPack"
    case LemonPack          = "com.tstick.Spinmoji.LemonPack"
    case AvocadoPack        = "com.tstick.Spinmoji.AvocadoPack"
}

class InAppPurchase: NSObject {
    private override init() {
        super.init()
        getProducts()
    }
    static let shared = InAppPurchase()
    weak var delegate: InAppPurchaseDelegate?
    
    // Available products
    private var products = [SKProduct]()
    private let paymentQueue = SKPaymentQueue.default()
    
    private func getProducts() {
        // Gets products from itunes connect
        let products: Set = [IAP.OneHundredGems.rawValue, IAP.TwoFiftyGems.rawValue,
                             IAP.SevenFiftyGems.rawValue, IAP.TwoThousandGems.rawValue,
                             IAP.FiveThousandGems.rawValue, IAP.WatermelonPack.rawValue,
                             IAP.LemonPack.rawValue, IAP.AvocadoPack.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        
        // Sets our transaction observer
        paymentQueue.add(self)
    }
    
    func purchaseProduct(product: IAP) {
        if products.count <= 0 {
            // Gives a dialog if there are no available products
            delegate?.alertUser(title: "Product Retrieval Failed", message: "The selected product is not available at this time.")
            return
        }
        
        // If the product is the one we're looking for, set it for purchase
        guard let productToPurchase = products.filter({$0.productIdentifier == product.rawValue}).first else {
            // Gives a dialog if the selected product was not found
            delegate?.alertUser(title: "Product Not Found", message: "We could not find a product matching the one you are trying to purchase.")
            return
        }
        
        // If the user can make purchases, perform the purchase
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: productToPurchase)
            paymentQueue.add(payment)
        } else {
            // If the user can't make the purchase, alert them
            delegate?.alertUser(title: "Purchase Failed", message: "User is not allowed to make this purchase.")
        }
    }
    
    func restorePurchases() {
        // If the user can make the restore, perform it
        if SKPaymentQueue.canMakePayments() {
            paymentQueue.restoreCompletedTransactions()
        } else {
            // If the user can't make the restore, alert them
            delegate?.alertUser(title: "Restore Failed", message: "User is not allowed to restore this purchase.")
        }
    }
    
    private func handlePurchase(purchase: String) {
        // Handles the purchase and gives the user what they bought
        switch purchase {
        case IAP.OneHundredGems.rawValue:
            delegate?.redeemGemPurchase(gemCount: 100)
        case IAP.TwoFiftyGems.rawValue:
            delegate?.redeemGemPurchase(gemCount: 250)
        case IAP.SevenFiftyGems.rawValue:
            delegate?.redeemGemPurchase(gemCount: 750)
        case IAP.TwoThousandGems.rawValue:
            delegate?.redeemGemPurchase(gemCount: 2000)
        case IAP.FiveThousandGems.rawValue:
            delegate?.redeemGemPurchase(gemCount: 5000)
        case IAP.WatermelonPack.rawValue, IAP.LemonPack.rawValue, IAP.AvocadoPack.rawValue:
            delegate?.levelPackPurchaseCompleted()
        default:
            print("Unknown purchase identifier")
        }
    }
}

extension InAppPurchase: SKProductsRequestDelegate {
    internal func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

extension InAppPurchase: SKPaymentTransactionObserver {
    // Happens when the transaction is finished
    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // This alert is used to notify of restore completion or purchase failure
        
        
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                // A purchased transaction should give the user their product
                self.handlePurchase(purchase: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .restored:
                // A restored transaction should restore the user purchase and inform
                // of the completon
                self.handlePurchase(purchase: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                delegate?.alertUser(title: "Purchases Restored", message: "All previous purchases have been restored.")
            case .failed:
                // A failed transaction should inform the user that their purchase failed
                queue.finishTransaction(transaction)
                delegate?.alertUser(title: "Transaction Failed", message: "The transaction could not be completed at this time.")
            case .deferred:
                queue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {
    internal func status() -> String {
        switch self {
        case .deferred:
            return "Deferred"
        case .failed:
            return "Failed"
        case .purchased:
            return "Purchased"
        case .purchasing:
            return "Purchasing"
        case .restored:
            return "Restored"
        }
    }
}

