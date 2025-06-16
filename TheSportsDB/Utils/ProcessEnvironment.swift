//
//  ProcessEnvironment.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 11/06/2025.
//

import Foundation

let ENV = ProcessEnvironment()

struct ProcessEnvironment {
    struct Variable {
        var name: String
        var `default`: String?
        var ciValue: String?
        
        init(_ name: String, default: String? = nil, ciValue: String? = nil) {
            self.name = name
            self.default = `default`
            self.ciValue = ciValue
        }
    }
    
    func value(_ variable: Variable) -> String? {
        let runtimeValue = string(for: variable.name) ?? variable.default
        let ciValue = variable.ciValue != "$(\(variable.name))" ? variable.ciValue : nil
    
        return runtimeValue ?? ciValue
    }
    
    func defines(_ variable: Variable) -> Bool {
        let runtimeDefined = string(for: variable.name) != nil || variable.default != nil
        let ciDefined = ![nil, "$(\(variable.name))"].contains(variable.ciValue)
        
        return runtimeDefined || ciDefined
    }
    
    private func string(for key: String) -> String? {
        return ProcessInfo.processInfo.environment[key]
    }
}
