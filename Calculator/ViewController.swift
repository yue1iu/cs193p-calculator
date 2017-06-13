//
//  ViewController.swift
//  Calculator
//
//  Created by Yue Liu on 6/7/17.
//  Copyright © 2017 Yue Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var displayPendingOperation: UILabel!
    
    var userIsInTheMiddleOfTypeing = false
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypeing {
            let textCurrentlyInDisplay = display.text!
            if userCanEnterDecimalPoint(digit, textCurrentlyInDisplay) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypeing = true
        }
    }
    
    private func userCanEnterDecimalPoint(_ digit: String, _ currentText: String) -> Bool {
            return digit != "." || !currentText.contains(".")
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTypeing {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTypeing = false
        }
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        displayPendingOperation.text = brain.pendingInfo;
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        displayValue = brain.evaluate(using: ["M": displayValue]).result!
    }
    
    @IBAction func getVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
    }
    
    
    @IBAction func clear(_ sender: Any) {
        display.text = "0"
        userIsInTheMiddleOfTypeing = false
        brain.reset()
        displayPendingOperation.text = " "
    }
}

