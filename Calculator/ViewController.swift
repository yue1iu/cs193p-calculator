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
    
    var variables = [String:Double]()
    
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
        displayPendingOperation.text = brain.description;
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        variables["M"] = displayValue
        displayValue = brain.evaluate(using: variables).result!
    }
    
    @IBAction func getVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if(userIsInTheMiddleOfTypeing && display.text != " ") {
            if let text = display.text {
                display.text = text.substring(to: text.index(before: text.endIndex))
                if((display.text?.characters.count)! < 1) {
                    display.text = " "
                    userIsInTheMiddleOfTypeing = false
                }
            }
        } else {
            brain.undo()
            displayValue = brain.evaluate(using: variables).result ?? 0.0
            displayPendingOperation.text = brain.description;
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        display.text = "0"
        userIsInTheMiddleOfTypeing = false
        variables.removeAll()
        brain.reset()
        displayPendingOperation.text = " "
    }
}

