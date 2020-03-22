//
//  SMDatePickerStyle.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/18/20.
//

import SwiftUI

public struct SMDatePickerStyle: DatePickerStyle {
    
    public init() {}
    
    public func _body(configuration: DatePicker<Self._Label>) -> some View {
        GeometryReader { container in
            ZStack {
                configuration.body
                
                VStack {
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(height: 34)
                    
                    Spacer()
                }
            }
            .frame(width: container.size.width, height: container.size.height)
        }
    }
}
