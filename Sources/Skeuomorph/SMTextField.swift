import SwiftUI

public struct SkeuomorphTextFieldStyle: TextFieldStyle {
    
    public init() {}
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            
            Capsule()
                .fill(Color.white)
                .frame(height: 32)
            
            // Text Field container shadow - stays still
            Capsule()
                .stroke(Color.black, lineWidth: 0.5)
                .blur(radius: 0.5)
                .frame(height: 32)
                .mask(
                    Capsule()
                        .frame(width: 92, height: 32)
            )
                // Top inner shadow
                .overlay(
                    Capsule()
                        .stroke(Color.gray, lineWidth: 2)
                        .blur(radius: 2)
                        .frame(height: 32)
                        .offset(y: 1.5)
                        // Create a natural fall-off for the top shadow
                        .mask(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1),
                                                     Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                            )
                                .frame(height: 32)
                            
                    )
                        // Set blend mode to multiply so the inner shadow reflects what color is underneath it
                        .blendMode(.multiply)
            )
                .opacity(0.9)
            
            configuration.body
                .textFieldStyle(PlainTextFieldStyle())
                .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
        }
        .mask(
            Capsule()
                .fill(Color(red: 247/255, green: 247/255, blue: 247/255))
                .frame(height: 32)
        )
    }
}

#if DEBUG
struct SkeuomorphTextFieldStyle_Preview: PreviewProvider {
    
    @State private static var text = ""
    
    static var previews: some View {
        TextField("Hello", text: $text)
            .textFieldStyle(SkeuomorphTextFieldStyle())
    }
}
#endif
