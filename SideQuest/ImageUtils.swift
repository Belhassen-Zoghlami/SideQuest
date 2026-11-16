import UIKit

enum ImageUtils: Sendable {
    private static let cache = NSCache<NSString, UIImage>()

    static func compress(_ data: Data, maxDimension: CGFloat = 900, quality: CGFloat = 0.65) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let longestSide = max(image.size.width, image.size.height)
        guard longestSide > 0 else { return nil }

        let scale = min(1, maxDimension / longestSide)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized.jpegData(compressionQuality: quality)
    }

    private static var avatarsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("avatars", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private static var eventImagesDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("event_images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    @discardableResult
    static func saveEventImageLocally(data: Data, eventId: String) -> String {
        let filename = "event_\(eventId).jpg"
        let fileURL = eventImagesDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL, options: .atomic)
            let identifier = "local://event_images/\(filename)"
            if let img = UIImage(data: data) {
                cache.setObject(img, forKey: identifier as NSString)
            }
            return identifier
        } catch {
            print("Failed to save event image locally: \(error)")
            return ""
        }
    }

    @discardableResult
    static func saveLocally(data: Data, filename: String) -> String {
        let fileURL = avatarsDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL, options: .atomic)
            let identifier = "local://\(filename)"
            if let img = UIImage(data: data) {
                cache.setObject(img, forKey: identifier as NSString)
            }
            return identifier
        } catch {
            print("Failed to save image locally: \(error)")
            return ""
        }
    }

    static func loadLocalImage(_ identifier: String) -> UIImage? {
        guard !identifier.isEmpty else { return nil }
        if let cached = cache.object(forKey: identifier as NSString) {
            return cached
        }

        var filePath: String?
        if identifier.hasPrefix("local://event_images/") {
            let filename = String(identifier.dropFirst("local://event_images/".count))
            filePath = eventImagesDirectory.appendingPathComponent(filename).path
        } else if identifier.hasPrefix("local://") {
            let filename = String(identifier.dropFirst("local://".count))
            let fileURL = avatarsDirectory.appendingPathComponent(filename)
            filePath = fileURL.path
        } else if identifier.hasPrefix("file://"), let url = URL(string: identifier) {
            filePath = url.path
        }

        if let path = filePath, FileManager.default.fileExists(atPath: path),
           let img = UIImage(contentsOfFile: path) {
            cache.setObject(img, forKey: identifier as NSString)
            return img
        }
        return nil
    }
}
