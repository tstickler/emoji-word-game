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
    case BananaPack         = "com.tstick.Spinmoji.BananaPack"
    case PeachPack          = "com.tstick.Spinmoji.PeachPack"
    case ApplePack          = "com.tstick.Spinmoji.ApplePack"
    case LemonPack          = "com.tstick.Spinmoji.LemonPack"
    case StrawberryPack     = "com.tstick.Spinmoji.StrawberryPack"
    case GrapesPack         = "com.tstick.Spinmoji.GrapesPack"
}

class InAppPurchase: NSObject {
    private override init() {}
    static let shared = InAppPurchase()
    weak var delegate: InAppPurchaseDelegate?
    
    // Available products
    private var products = [SKProduct]()
    private let paymentQueue = SKPaymentQueue.default()
    
    // The presenting view controller is used so we can display a UIAlert
    // after a purchase failure or purchase restore.
    private var presentingController: UIViewController!
    
    private func getProducts() {
        // Gets products from itunes connect
        let products: Set = [IAP.OneHundredGems.rawValue, IAP.TwoFiftyGems.rawValue,
                             IAP.SevenFiftyGems.rawValue, IAP.TwoThousandGems.rawValue,
                             IAP.FiveThousandGems.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        
        // Sets our transaction observer
        paymentQueue.add(self)
    }
    
    func purchaseProduct(product: IAP, in view: UIViewController) {
        // Saves the view sent the request
        presentingController = view
        
        if products.count <= 0 {
            // Gives a dialog if there are no available products
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            alert.title = "Product retrieval failed"
            alert.message = "The selected product is not available at this time."
            
            presentingController.present(alert, animated: true, completion: nil)
            return
        }
        
        // If the product is the one we're looking for, set it for purchase
        guard let productToPurchase = products.filter({$0.productIdentifier == product.rawValue}).first else {
            // Gives a dialog if the selected product was not found
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            alert.title = "Product not found"
            alert.message = "We could not find a product matching the one you are trying to purchase."
            
            presentingController.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // If the user can make purchases, perform the purchase
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: productToPurchase)
            paymentQueue.add(payment)
        } else {
            // If the user can't make the purchase, alert them
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            alert.title = "Purchase failed"
            alert.message = "User is not allowed to make this purchase."
            presentingController.present(alert, animated: true, completion: nil)
        }
    }
    
    func restorePurchases(in view: UIViewController) {
        // Saves the view sent the request
        presentingController = view
        
        // If the user can make the restore, perform it
        if SKPaymentQueue.canMakePayments() {
            paymentQueue.restoreCompletedTransactions()
        } else {
            // If the user can't make the restore, alert them
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            alert.title = "Restore failed"
            alert.message = "User is not allowed to make restore this purchase."
            presentingController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func handlePurchase(purchase: String) {
        // Handles the purchase and gives the user what they bought
        switch purchase {
        case IAP.OneHundredGems.rawValue:
            break
        case IAP.TwoFiftyGems.rawValue:
            break
        case IAP.SevenFiftyGems.rawValue:
            break
        case IAP.TwoThousandGems.rawValue:
            break
        case IAP.FiveThousandGems.rawValue:
            break
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
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
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
                alert.title = "Purchases restored"
                alert.message = "All previous purchases have been restored."
                presentingController.present(alert, animated: true, completion: nil)
            case .failed:
                // A failed transaction should inform the user that their purchase failed
                alert.title = "Transaction Failed"
                alert.message = "The transaction could not be completed at this time."
                queue.finishTransaction(transaction)
                presentingController.present(alert, animated: true, completion: nil)
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

