//
//  ContentView.swift
//  Example
//
//  Created by v.prusakov on 3/12/20.
//  Copyright © 2020 LiteCode. All rights reserved.
//

import SwiftUI
import Skeuomorph
import Morph

struct ContentView: View {
    
    @State var isSkeuomorphed = true
    @State var isOn1 = false
    @State var isOn2 = false
    
    @State var flipped = false
    
    @State var value: Float = 0.5
    
    @State var textFieldValue = "Title"
    
    @State var date: Date = Date()
    
    @State var isAlertPresented = false
    @State var isActionSheetPresented = false
    
    let message: String = """
    Очень много текста, чтобы можно было даже скролить. Если текст не вмещается, это критично, так что будем как-то выруливать.
    Еще очень хотелось бы, чтобы здесь был осмысленный текст, но я сейчас на созвоне, так что особо не думаю, что писать.

    Пожалуйста, нажмите на ту или иную кнопку, чтобы решить что делать дальше.
    Мы в свою очередь просто закроем вьюшку)
    """
    
    @State var isButtonActive = false
    
    @State var navSelection: String?
    
    var body: some View {
        NavigationView {
            VStack {
                
                Toggle(isOn: $isSkeuomorphed.animation(), label: {
                    Text(isSkeuomorphed ? "turn off Skeuomorph" : "turn on Skeuomorph")
                })
                    .toggleStyle(SMToggleStyle())
                    .padding(.top, 32)
                
                Spacer()
                
                VStack {
                    Toggle(isOn: $isOn1, label: {
                        Text("Store data")
                    })
                    
                    TextField("Hello", text: self.$textFieldValue)
                    
                    MorphSlider(value: $value, minimumValueLabel: Text("Kek"), maximumValueLabel: Text("Lol"), label: {
                        Text("Label")
                    })
                    
                    SwiftUI.Slider(value: $value, minimumValueLabel: Text("Kek"), maximumValueLabel: Text("Lol"), label: {
                        Text("Label")
                    })
                    
                    Button(action: { self.isAlertPresented.toggle() }, label: {
                        Text("Present Alert")
                    })
                        .padding([.top, .bottom], 8)
                    
                    Button(action: { self.isActionSheetPresented.toggle() }, label: {
                        Text("Present Action Sheet")
                    })
                    
                    NavigationButton(destination: DestinationView(text: "Screen", count: 1), tag: "1", selection: self.$navSelection, label: {
                        Text("Let's go")
                    })
                    .padding([.top, .bottom], 8)
                    
                }
                
                Spacer()
                
            }
            .padding()
            .alertWithStyle(isPresented: $isAlertPresented) { () -> Alert in
                Alert(title: Text("Изменить экран домой"), message: Text(String(repeating: message, count: 1)), primaryButton: .cancel(), secondaryButton: .destructive(Text("Понятно")))
            }
            .actionSheetWithStyle(isPresented: $isActionSheetPresented) { () -> ActionSheet in
                ActionSheet(title: Text("Удалить"), message: Text("Вы действительно хотите удалить"), buttons: [
                    .cancel(Text("Отмена")),
                    .destructive(Text("Удалить")),
                    .default(Text("Перенести"))
                ])
            }
            .navigationBarTitle(self.textFieldValue)
            .navigationBarButtonItems(
                leading: Button("Kek", action: { }),
                trailing: Button("Фотоальбом", action: { self.navSelection = "1" })
            )
            .navigationBarTintColor(.black)
        }
            .modifier(StyleViewModifier(isSkeumorphed: $isSkeuomorphed.animation()))
            .accentColor(.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct StyleViewModifier: ViewModifier {
    
    @Binding var isSkeumorphed: Bool
    
    func body(content: _ViewModifier_Content<StyleViewModifier>) -> some View {
        Group {
            if isSkeumorphed {
                content
                    .toggleStyle(SMToggleStyle())
                    .sliderStyle(SkeuomorphSliderStyle())
                    .alertStyle(SMAlertStyle())
                    .actionSheetStyle(SMActionSheetStyle())
                    .textFieldStyle(SkeuomorphTextFieldStyle())
                    .navigationViewStyle(SMNavigationViewStyle())
            } else {
                content
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct DestinationView: View {
    
    let text: String
    let count: Int
    
    var body: some View {
        VStack {
            Text(self.text)

            NavigationButton(destination: DestinationView(text: self.text, count: count + 1), label: {
                Text("Go next")
            })
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .navigationBarTitle("\(self.text) \(self.count)")
        .navigationBarButtonItems(trailing: Button("Item \(self.count)", action: {}))
    }
}
