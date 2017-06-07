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
    
    var userIsInTheMiddleOfTypeing = false
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypeing {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypeing = true
        }
        
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
    }
}

