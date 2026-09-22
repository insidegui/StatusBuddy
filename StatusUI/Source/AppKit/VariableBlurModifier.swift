import SwiftUI

extension View {
    func variableBlurBackdrop(edge: VerticalEdge, radius: Double = 3) -> some View {
        modifier(VariableBlurBackdropModifier(edge: edge, radius: radius))
    }
}

private struct VariableBlurBackdropModifier: ViewModifier {
    var edge: VerticalEdge
    var radius: Double

    func body(content: Content) -> some View {
        content
            .background {
                // Fade the filtered result as well as the scrolling content so the
                // backdrop cannot reintroduce the glass chrome at the outer edge.
                VariableBlurView(edge: edge, radius: radius)

                LinearGradient(stops: [.init(color: .white, location: 0.2), .init(color: .white.opacity(0), location: 1)], startPoint: edge == .top ? .top : .bottom, endPoint: edge == .top ? .bottom : .top)
                    .blendMode(.destinationOut)
            }
    }
}

private struct VariableBlurView: NSViewRepresentable {
    var edge: VerticalEdge
    var radius: Double

    typealias NSViewType = _LayerHost

    func makeNSView(context: Context) -> _LayerHost {
        _LayerHost(edge: edge, radius: radius)
    }

    func updateNSView(_ nsView: _LayerHost, context: Context) {
        nsView.edge = edge
        nsView.radius = radius
    }

    final class _LayerHost: NSView, CALayerDelegate {
        @Invalidating(.layout) var edge: VerticalEdge = .top
        @Invalidating(.layout) var radius: Double = 3

        init(edge: VerticalEdge, radius: Double) {
            self.edge = edge
            self.radius = radius

            super.init(frame: .zero)

            setup()
        }

        required init?(coder: NSCoder) {
            fatalError()
        }

        private lazy var requireLayer: CALayer = {
            if !wantsLayer { wantsLayer = true }
            return layer ?? makeBackingLayer()
        }()

        private lazy var topLayer = CALayer.load(assetName: "TopBlurMask")
        private lazy var bottomLayer = CALayer.load(assetName: "BottomBlurMask")

        private func setup() {
            requireLayer.delegate = self
        }

        func action(for layer: CALayer, forKey event: String) -> (any CAAction)? { NSNull() }

        override func layout() {
            super.layout()

            let assetLayer: CALayer
            switch edge {
            case .top:
                assetLayer = topLayer
                bottomLayer.removeFromSuperlayer()
            case .bottom:
                assetLayer = bottomLayer
                topLayer.removeFromSuperlayer()
            }

            if assetLayer.superlayer !== requireLayer {
                requireLayer.addSublayer(assetLayer)
            }

            assetLayer.apply {
                $0.delegate = self
                $0.frame = requireLayer.bounds
                if $0.name == "backdrop" {
                    $0.setValue(radius, forKeyPath: "filters.variableBlur.inputRadius")
                }
            }
        }
    }
}

private extension CALayer {
    static func load(assetName: NSDataAsset.Name, bundle: Bundle = .statusUI) -> CALayer {
        do {
            guard let asset = NSDataAsset(name: assetName, bundle: bundle) else {
                throw "Asset \(assetName) not found"
            }

            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: asset.data)
            unarchiver.requiresSecureCoding = false
            guard let raw = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
                throw "Root object missing."
            }
            guard let dict = raw as? [String: Any] else {
                throw "Root object not a dictionary."
            }
            guard let rawRootLayer = dict["rootLayer"] else {
                throw "Root dictionary missing rootLayer"
            }
            guard let rootLayer = rawRootLayer as? CALayer  else {
                throw "rootLayer not CALayer"
            }
            return rootLayer
        } catch {
            assertionFailure("Asset load: \(error)")
            return CALayer()
        }
    }

    func sublayer(_ name: String) -> CALayer? { sublayers?.first(where: { $0.name == name }) }

    func apply(_ block: (_ layer: CALayer) -> ()) {
        block(self)

        guard let sublayers else { return }

        for sublayer in sublayers { sublayer.apply(block) }

        if let mask { mask.apply(block) }
    }
}

extension String: @retroactive LocalizedError {
    public var errorDescription: String? { self }
    public var failureReason: String? { self }
}

#if DEBUG
#Preview {
    List {
        ForEach((1...200), id: \.self) { i in
            Text("Item #\(i)")
        }
    }
    .safeAreaInset(edge: .bottom) {
        Color.clear
            .frame(height: 54)
            .variableBlurBackdrop(edge: .bottom, radius: 12)
    }
    .compositingGroup()
}
#endif
