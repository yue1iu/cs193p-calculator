//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Yue Liu on 6/7/17.
//  Copyright © 2017 Yue Liu. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    
    private var pendingBinaryOperation: PendingBinaryOperaiton?
    
    private var description: String = " "
    
    private  enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation({ -$0 }),
        "✕" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "-" : Operation.binaryOperation({ $0 - $1 }),
        "x²" : Operation.unaryOperation({ pow($0, 2) }),
        "x³" : Operation.unaryOperation({ pow($0, 3) }),
        "e" : Operation.constant(M_E),
        "1/x" : Operation.unaryOperation({ 1 / $0 }),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                description += " \(symbol)"
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    let accumulatorString = String(accumulator!)
                    description += "\(symbol)(\(accumulatorString))"
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperaiton(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    description += " \(symbol)"
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private struct PendingBinaryOperaiton {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        description += " \(operand)"
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var pendingInfo: String {
        get {
            return resultIsPending ? description + " ..." : description + " ="
        }
    }
}
