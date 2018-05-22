//
//  ViewController.swift
//  WebviewApp
//
//  Created by mac on 5/21/18.
//  Copyright © 2018 mobileappscompany. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var webView: ProductWebView!
    
    let navigationDelegate = NavigationDelegate()
    let scriptHandler = ScriptMessageHandler()

    var enableAction: UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scriptHandler.delegate = self
        webView.configure(nav: navigationDelegate, script: scriptHandler, homeURL: API.Products.home)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: JavascriptHandlerDelegate {
    
    func received(product: Product) {
        
        let alertController = UIAlertController(
            title: "Enter Payment Information",
            message: "Credit Card Number",
            preferredStyle: .alert)
        
        let cancel = UIAlertAction(
            title: "Cancel",
            style: .default,
            handler: nil)
        
        let purchase = UIAlertAction(
            title: "Purchase",
            style: .default) { _ in
            self.completePurchase(with: product)
        }
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Card number"
            textfield.addTarget(self, action: #selector(ViewController.textDidChange(txtfield:)), for: .editingChanged)
            textfield.keyboardType = .numberPad
            textfield.delegate = self
            
        }
        enableAction = purchase
        purchase.isEnabled = false
        
        alertController.addAction(purchase)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Limit user entry in credit card to 16 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= CreditCardValidator.maxLength
    }
    
    //MARK: Detect if Credit Card is valid
    @objc func textDidChange(txtfield: UITextField)
    {
        //check if textfield has value
        enableAction.isEnabled = ((txtfield.text?.count)! >= CreditCardValidator.minLength && (txtfield.text?.count)! <= CreditCardValidator.maxLength)
    }
    
    func completePurchase(with product: Product){
        guard let orderPage = Page.order else { return }
        
        webView.loadHTMLString(orderPage
                .replacingOccurrences(of: "{name}", with: product.name)
                .replacingOccurrences(of: "{price}", with: product.price)
                .replacingOccurrences(of: "{image}", with: product.image),
                               baseURL: nil)
    }
}
