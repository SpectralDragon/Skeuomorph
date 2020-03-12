//
//  ContentView.swift
//  Example
//
//  Created by v.prusakov on 3/12/20.
//  Copyright © 2020 LiteCode. All rights reserved.
//

import SwiftUI
import Skeuomorph

struct ContentView: View {
    
    @State var isSkeuomorphed = false
    @State var isOn1 = false
    @State var isOn2 = false
    
    @State var flipped = false
    
    var body: some View {
        VStack {
            Toggle(isOn: $isSkeuomorphed.animation(), label: {
                Text(isSkeuomorphed ? "turn off Skeuomorph" : "turn on Skeuomorph")
            })
                .toggleStyle(SkeuomorphToggleStyle())

            VStack {
                Toggle(isOn: $isOn1, label: {
                    Text("Kekss")
                })
                .rotation3DEffect(self.isSkeuomorphed ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))

                Toggle(isOn: $isOn2, label: {
                    Text("Keksss")
                })
                .rotation3DEffect(self.isSkeuomorphed ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            }
            .toggleStyle(isSkeuomorphed: self.isSkeuomorphed)
            .rotation3DEffect(self.isSkeuomorphed ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))

        }
        .padding()
    }
}

extension View {
    func toggleStyle(isSkeuomorphed: Bool) -> some View {
        ZStack {
            if isSkeuomorphed {
                self.toggleStyle(SkeuomorphToggleStyle())
            } else {
                self.toggleStyle(DefaultToggleStyle())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
