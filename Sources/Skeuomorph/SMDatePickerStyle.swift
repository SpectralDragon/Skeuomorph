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

public struct DumpingEnvironment<V: View>: View {
    @Environment(\.self) var env
    let content: V
    
    public init(_ content: V) {
        self.content = content
    }
    
    public var body: some View {
        dump(env)
        return content
    }
}

public struct SMNavigationViewStyle: NavigationViewStyle {
    
    public init() {}
    
    public func _body(configuration: _NavigationViewStyleConfiguration) -> some View {
        configuration.content
    }
    
    struct InnerNavigationView<Content: View>: View {
        
        @Environment(\.self) private var env
        
        let content: Content
        
        var body: some View {
            return content
        }
    }
}
