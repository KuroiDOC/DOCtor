//
//  Container+builder.swift
//  
//
//  Created by Daniel Otero on 21/9/22.
//

import Foundation

@resultBuilder
public struct RegistrablesBuilder {
    public static func buildBlock(_ registrables: any Registrable...) -> [any Registrable] {
        registrables
    }
}

extension Container {
    public func register(@RegistrablesBuilder _ content: () -> [any Registrable]) {
        content().forEach { registrable in
            self.register(registrable)
        }
    }
}
