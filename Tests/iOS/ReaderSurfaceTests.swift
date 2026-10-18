import SwiftUI
import UIKit
import XCTest
@testable import XianxiaReader

final class ReaderSurfaceTests: XCTestCase {
    @MainActor func testRealWindowEdgesPaintWithoutChangingNavigatorOrInterceptingTouches() async throws {
        let navigator = UIViewController()
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 100, y: 200, width: 100, height: 60)
        navigator.view.addSubview(button)
        let host = UIHostingController(rootView: ReaderSurface(viewController: navigator, pageColor: .white))
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first { $0.isKeyWindow }
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = host; window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil; previous?.makeKey() }
        for _ in 0..<100 {
            window.layoutIfNeeded()
            if let cover = navigator.view.subviews.compactMap({ $0 as? ReaderSafeAreaCover }).first,
               cover.safeAreaInsets.top > 0, cover.bounds.height > 0 { break }
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        let cover = try XCTUnwrap(navigator.view.subviews.compactMap { $0 as? ReaderSafeAreaCover }.first)
        cover.layoutIfNeeded()
        let originalFrame = navigator.view.frame
        XCTAssertEqual(cover.frame, navigator.view.bounds)
        XCTAssertGreaterThan(cover.safeAreaInsets.top, 0)
        XCTAssertGreaterThan(cover.safeAreaInsets.bottom, 0)
        XCTAssertEqual(cover.safeAreaInsets, navigator.view.safeAreaInsets)
        XCTAssertFalse(cover.isUserInteractionEnabled)
        XCTAssertTrue(cover.accessibilityElementsHidden)
        XCTAssertTrue(navigator.view.hitTest(CGPoint(x: 150, y: 230), with: nil) === button)
        let top = CGPoint(x: cover.bounds.midX, y: cover.safeAreaInsets.top / 2)
        let bottom = CGPoint(x: cover.bounds.midX, y: cover.bounds.maxY - cover.safeAreaInsets.bottom / 2)
        let center = CGPoint(x: cover.bounds.midX, y: cover.bounds.midY)
        XCTAssertEqual(try pixel(in: cover, at: top), [255, 255, 255, 255])
        XCTAssertEqual(try pixel(in: cover, at: bottom), [255, 255, 255, 255])
        XCTAssertEqual(try pixel(in: cover, at: center), [0, 0, 0, 0])
        cover.pageColor = .black; cover.layoutIfNeeded()
        XCTAssertEqual(try pixel(in: cover, at: top), [0, 0, 0, 255])
        XCTAssertEqual(try pixel(in: cover, at: bottom), [0, 0, 0, 255])
        XCTAssertEqual(try pixel(in: cover, at: center), [0, 0, 0, 0])
        // The real engine appends its navigator after ReaderSurface is mounted.
        // Composite the parent, not just the cover, to catch hidden decorations.
        let lateContent = UIView(frame: navigator.view.bounds)
        lateContent.backgroundColor = .red
        lateContent.isUserInteractionEnabled = false
        lateContent.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigator.view.addSubview(lateContent)
        XCTAssertTrue(navigator.view.subviews.last === lateContent)
        let composited = try onscreenSnapshot(of: navigator.view)
        let attachment = XCTAttachment(image: UIImage(cgImage: composited))
        attachment.name = "reader-edges-late-mount-composited-build29"
        attachment.lifetime = .keepAlways; add(attachment)
        XCTAssertEqual(try pixel(in: composited, at: top), [0, 0, 0, 255])
        XCTAssertEqual(try pixel(in: composited, at: bottom), [0, 0, 0, 255])
        XCTAssertEqual(try pixel(in: composited, at: center), [255, 0, 0, 255])
        XCTAssertEqual(navigator.view.frame, originalFrame)
        XCTAssertTrue(navigator.view.hitTest(CGPoint(x: 150, y: 230), with: nil) === button)
        // UIKit recomputes insets and the transparent opening after layout changes.
        host.additionalSafeAreaInsets = UIEdgeInsets(top: 12, left: 18, bottom: 16, right: 20)
        window.layoutIfNeeded(); host.view.layoutIfNeeded(); navigator.view.layoutIfNeeded(); cover.layoutIfNeeded()
        XCTAssertEqual(cover.safeAreaInsets, navigator.view.safeAreaInsets)
        XCTAssertEqual(try pixel(in: cover, at: CGPoint(x: 5, y: cover.bounds.midY)), [0, 0, 0, 255])
        XCTAssertEqual(try pixel(in: cover, at: CGPoint(x: cover.bounds.maxX - 5, y: cover.bounds.midY)), [0, 0, 0, 255])
        XCTAssertEqual(try pixel(in: cover, at: center), [0, 0, 0, 0])
    }

    @MainActor private func onscreenSnapshot(of view: UIView) throws -> CGImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1; format.opaque = false
        var complete = false
        let image = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
            // Capture the visible UIKit composition, including z-position.
            // CALayer.render(in:) above is only for the isolated shape's pixels.
            complete = view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        XCTAssertTrue(complete, "UIKit must capture the complete visible hierarchy")
        return try XCTUnwrap(image.cgImage)
    }

    @MainActor private func pixel(in image: CGImage, at point: CGPoint) throws -> [UInt8] {
        let cropped = try XCTUnwrap(image.cropping(to: CGRect(x: point.x.rounded(.down),
            y: point.y.rounded(.down), width: 1, height: 1)))
        var bytes = [UInt8](repeating: 0, count: 4)
        try bytes.withUnsafeMutableBytes { storage in
            let context = try XCTUnwrap(CGContext(data: storage.baseAddress, width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue))
            context.draw(cropped, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return bytes
    }

    @MainActor private func pixel(in view: UIView, at point: CGPoint) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 4)
        try bytes.withUnsafeMutableBytes { storage in
            let context = try XCTUnwrap(CGContext(data: storage.baseAddress, width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue))
            context.translateBy(x: -point.x, y: -point.y)
            view.layer.render(in: context)
        }
        return bytes
    }
}
