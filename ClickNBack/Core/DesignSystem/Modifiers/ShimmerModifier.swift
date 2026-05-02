//

import SwiftUI

public struct ShimmerModifier: ViewModifier {
    @State private var shimmerOffset: CGFloat = -1

    let isAnimating: Bool

    public init(isAnimating: Bool) {
        self.isAnimating = isAnimating
    }

    public func body(content: Content) -> some View {
        let gradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0.0),
                .init(color: Color.white.opacity(0.15), location: 0.3),
                .init(color: Color.white.opacity(0.3), location: 0.5),
                .init(color: Color.white.opacity(0.15), location: 0.7),
                .init(color: .clear, location: 1.0),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        return content
            .overlay {
                gradient
                    .offset(x: shimmerOffset * 800)
                    .mask(
                        RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.large)
                    )
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 2.0).repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 1
                }
            }
    }
}
