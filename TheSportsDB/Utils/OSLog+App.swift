//
//  OSLog+App.swift
//  TheSportsDB
//
//  Created by Mohamed Amine BEN HADDADA on 10/06/2025.
//

import Foundation
import os.log

extension OSLog {
    convenience init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier!, category: category)
    }

    func error(_ error: Error, function: String = #function, message: String? = nil) {
        if let message = message {
            os_log(
                .error, log: self,
                "🛑 %{public}@ - %{public}@ -> %{public}@",
                function,
                message,
                String(describing: error)
            )
        } else {
            os_log(
                .error, log: self,
                "🛑 %{public}@ - %{public}@",
                function,
                String(describing: error)
            )
        }
    }
}
