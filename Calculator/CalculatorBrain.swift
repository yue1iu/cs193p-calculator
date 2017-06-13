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
    
    private var variables: Dictionary<String, Double>?
    
    private  enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private enum InputTypes {
        case operand(Double)
        case variable(String)
        case operation(Operation)
    }
    
    private var pendingInputs = [InputTypes]()
    
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
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            pendingInputs.append(.operation(operation))
            
            switch operation {
            case .constant(let value):
                accumulator = value
                description += " \(symbol)"
            case .unaryOperation(let function):
                if accumulator != nil {
                    if(resultIsPending) {
                        description += " \(symbol)(\(accumulator!))"
                    } else {
                        description = " \(symbol)(\(description))"
                    }
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                performPendingBinaryOperation()
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
        pendingInputs.append(.operand(operand))
        
        accumulator = operand
        if(!resultIsPending) {
            description += " \(operand)"
        }
    }
    
    mutating func setOperand(variable named: String) {
        pendingInputs.append(.variable(named))
        
        accumulator = variables?[named] ?? 0.0
        description += " \(named)"
        print("setOperand variable named: \(named) with value \(accumulator)")
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var accumulator: Double?
        
        for input in pendingInputs {
            switch input {
            case .operand(let value):
                accumulator = value
            case .variable(let name):
                accumulator = variables?[name] ?? 0.0
            case .operation:
                break
            }
        }
        
        return (accumulator, false, "")
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
    
    mutating func reset() {
        accumulator = nil
        description = " "
        pendingBinaryOperation = nil
        pendingInputs.removeAll()
    }
}
