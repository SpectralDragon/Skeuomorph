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
    
    @State var value: Float = 0.5
    
    @State var textFieldValue = ""
    
    @State var date: Date = Date()
    
    @State var isAlertPresented = false
    
    let message: String = """
    Очень много текста, чтобы можно было даже скролить. Если текст не вмещается, это критично, так что будем как-то выруливать.
    Еще очень хотелось бы, чтобы здесь был осмысленный текст, но я сейчас на созвоне, так что особо не думаю, что писать.

    Пожалуйста, нажмите на ту или иную кнопку, чтобы решить что делать дальше.
    Мы в свою очередь просто закроем вьюшку)
    """
    
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle(isOn: $isSkeuomorphed.animation(), label: {
                    Text(isSkeuomorphed ? "turn off Skeuomorph" : "turn on Skeuomorph")
                })
                
                TextField("Hello", text: self.$textFieldValue)
                
                SMSlider(value: $value, minimumValueLabel: Text("Kek"), maximumValueLabel: Text("Lol"), label: {
                    Text("Label")
                })
                    .sliderStyle(SkeuomorphSliderStyle())
                
                Slider(value: $value, minimumValueLabel: Text("Kek"), maximumValueLabel: Text("Lol"), label: {
                    Text("Label")
                })
                
                Button(action: { self.isAlertPresented.toggle() }, label: {
                    Text("Present Alert")
                })
                
//                DatePicker(selection: $date) {
//                    Text("kek")
//                }

            }
            .padding()
            .navigationBarTitle("Hello", displayMode: .inline)
            .alertMorph(isPresented: $isAlertPresented) { () -> Alert in
                Alert(title: Text("Изменить экран домой"), message: Text(String(repeating: message, count: 1)), primaryButton: .cancel(), secondaryButton: .default(Text("Понятно")))
            }
        }
//        .navigationViewStyle(SMNavigationViewStyle())
        .toggleStyle(SMToggleStyle())
        .alertStyle(SMAlertStyle())
        .textFieldStyle(SkeuomorphTextFieldStyle())
        .datePickerStyle(SMDatePickerStyle())
        .accentColor(.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
