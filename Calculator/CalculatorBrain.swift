//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Yue Liu on 6/7/17.
//  Copyright © 2017 Yue Liu. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private  enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private enum InputTypes {
        case operand(Double)
        case variable(String)
        case operation(String)
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
        pendingInputs.append(.operation(symbol))
    }
    
    mutating func setOperand(_ operand: Double) {
        pendingInputs.append(.operand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        pendingInputs.append(.variable(named))
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var accumulator: Double?
        
        var pendingBinaryOperation: PendingBinaryOperaiton?
        
        var description: String = " "
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        struct PendingBinaryOperaiton {
            let function: (Double, Double) -> Double
            let firstOperand: Double
            
            func perform(with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
        }
        
        for input in pendingInputs {
            switch input {
            case .operand(let value):
                accumulator = value
                description += " \(value)"
            case .variable(let name):
                accumulator = variables?[name] ?? 0.0
                description += " \(name)"
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = value
                        description += " \(symbol)"
                    case .unaryOperation(let function):
                        if accumulator != nil {
                            if (pendingBinaryOperation != nil) {
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
        }
        
        var resultIsPending: Bool {
            return pendingBinaryOperation != nil
        }
        
        return (accumulator, resultIsPending, resultIsPending ? description + " ..." : description + " =")
    }
    
    var result: Double? {
            return evaluate().result
    }
    
    var description: String {
            return evaluate().description
    }
    
    mutating func reset() {
        pendingInputs.removeAll()
    }
    
    mutating func undo() {
        print("undo")
        if(!pendingInputs.isEmpty) {
            pendingInputs.removeLast()
        }
    }
}
