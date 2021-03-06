//
//  ActionSheetModifier.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/19/20.
//

import SwiftUI
import Morph

public struct SMActionSheetStyle: ActionSheetStyle {
    
    public init() {}
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        GeometryReader { container in
            ZStack(alignment: .bottom) {
                
                if !configuration.isPresented {
                    configuration.content
                } else {
                    configuration.content
                        .accentColor(Color.gray)
                }
                
                if configuration.isPresented {
                    Rectangle()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .opacity(0.4)
                        .transition(AnyTransition.opacity.animation(.linear(duration: 0.2)))
                        .edgesIgnoringSafeArea(.all)
                }
                
                if configuration.isPresented {
                    VStack {
                        configuration.actionSheet.title
                            .foregroundColor(.white)
                            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3), radius: 0, x: 0, y: -1)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(EdgeInsets(top: 20, leading: 8, bottom: 8, trailing: 8))
                        
                        configuration.actionSheet.message
                            .foregroundColor(Color.white)
                            .padding([.leading, .trailing], 8)
                        
                        ForEach(configuration.actionSheet.buttons) { button in
                            self.makeButton(configuration, button: button)
                                .padding(.top, button.style == .cancel ? 12 : 0)
                        }
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: container.safeAreaInsets.bottom + 16, trailing: 8))
                    }
                    .background(
                        ZStack(alignment: .top) {
                            LinearGradient(gradient: Gradient(colors: [
                                Color(red: 22/255, green: 23/255, blue: 25/255, opacity: 0.8),
                                Color(red: 22/255, green: 23/255, blue: 25/255, opacity: 0.7),
                                Color(red: 94/255, green: 94/255, blue: 94/255, opacity: 0.6)
                            ]),
                                           startPoint: .bottom,
                                           endPoint: .top)
                                .edgesIgnoringSafeArea(.all)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.7))
                                .frame(height: 1)
                        }
                    )
                        .shadow(color: Color.black.opacity(0.6), radius: 1, x: 0, y: -1)
                        .transition(AnyTransition.move(edge: .bottom)
                            .combined(with: .opacity)
                            .animation(.easeIn)
                    )
                }
            }
        }
    }
    
    func makeButton(_ configuration: Self.Configuration, button: Self.Configuration.ActionSheet.Button) -> some View {
        Button(action: {
            configuration.$isPresented.wrappedValue = false
            button.action()
        }, label: { button.label })
            .buttonStyle(ActionSheetButtonStyle(style: button.style))
    }
}

struct ActionSheetButtonStyle: ButtonStyle {
    
    let style: AlertStyleConfiguration.Alert.Button.Style
    
    @Environment(\.selectionFeedbackGenerator) private var feedbackGenerator
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
        if configuration.isPressed {
            self.feedbackGenerator.selectionChanged()
        }
        
        return
            configuration.label
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(.white)
                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3), radius: 0, x: 0, y: -1)
                .font(.system(size: 17, weight: .bold))
                .padding([.bottom, .top], 8)
                .background(
                    GeometryReader { container in
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(self.backgroundColor(for: configuration))
                                .overlay(
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .offset(y: -(container.size.height / 1.7))
                                        .blur(radius: 6)
                            )
                            
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                    }
            )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black.opacity(0.5), lineWidth: 3)
            )
                .animation(.linear(duration: 0.1))
                .shadow(color: Color.white.opacity(0.1), radius: 0, x: 0, y: 1)
    }
    
    func backgroundColor(for configuration: Self.Configuration) -> Color {
        switch style {
        case .default:
            return configuration.isPressed ? Color(red: 68/255, green: 74/255, blue: 92/255) : Color(red: 104/255, green: 113/255, blue: 139/255)
        case .cancel:
            return configuration.isPressed ? Color(red: 50/255, green: 128/255, blue: 228/255, opacity: 0.8) : Color(red: 18/255, green: 18/255, blue: 18/255, opacity: 0.1)
        case .destructive:
            return configuration.isPressed ? Color(red: 130/255, green: 28/255, blue: 18/255) : Color(red: 189/255, green: 40/255, blue: 28/255)
        }
    }
}
