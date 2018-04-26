//
//  ShoppingTotalViewController.swift
//  ComprasUSA
//
//  Created by Fellipe Soares Oliveira on 22/04/2018.
//  Copyright © 2018 Fellipe Soares Oliveira. All rights reserved.
//

import UIKit
import CoreData

class ShoppingTotalViewController: UIViewController {

    @IBOutlet weak var lbDolarValue: UILabel!
    @IBOutlet weak var lbRealValue: UILabel!
    
    var dataSource: [Product] = []
    var format = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadProducts()
        let dolar = UserDefaults.standard.string(forKey: "dolar")
        let iof = UserDefaults.standard.string(forKey: "iof")
        var results = 0.0
        dataSource.forEach { (product) in
            if let state = product.state {
                var result = product.price + calculateStateTax(value: product.price, tax: state.fee)
                
                if product.paymentForm {
                    result = result + calculateIOFValue(value: (result), iof: Double(iof!)!)
                }
                results += result
            }
        }
        
        lbRealValue.text = "\(results * Double(dolar!)!)"
        lbDolarValue.text = "\(results)"
    }
    
    func calculateStateTax(value: Double, tax: Double) -> Double {
        return value * (tax / 100)
    }
    
    func calculateIOFValue(value: Double, iof: Double) -> Double {
        return value * (iof / 100)
    }
    
    // MARK: - Methods
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }

}
