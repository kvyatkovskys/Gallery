#if os(iOS)

import UIKit
import Photos

public protocol CartDelegate: class {
  func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool)
  func cart(_ cart: Cart, didAdd video: Video, newlyTaken: Bool)
  func cart(_ cart: Cart, didRemove image: Image)
  func cart(_ cart: Cart, didRemove video: Video)
  func cartDidReload(_ cart: Cart)
}

extension CartDelegate {
  func cart(_ cart: Cart, didRemove video: Video) {}
  func cart(_ cart: Cart, didAdd video: Video, newlyTaken: Bool) {}
}

/// Cart holds selected images and videos information
public class Cart {

  public var images: [Image] = []
  public var videos: [Video] = []
    
  var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
  var video: Video? {
    return videos.last
  }
    
  // MARK: - Initialization

  init() {

  }

  // MARK: - Delegate

  public func add(delegate: CartDelegate) {
    delegates.add(delegate)
  }

  // MARK: - Logic

  public func add(_ image: Image, newlyTaken: Bool = false) {
    guard !images.contains(image) else { return }

    images.append(image)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didAdd: image, newlyTaken: newlyTaken)
    }
  }

  public func add(_ video: Video, newlyTaken: Bool = false) {
    guard !videos.contains(video) else { return }

    videos.append(video)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didAdd: video, newlyTaken: newlyTaken)
    }
  }
    
  public func remove(_ image: Image) {
    guard let index = images.firstIndex(of: image) else { return }

    images.remove(at: index)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didRemove: image)
    }
  }
    
  public func remove(_ video: Video) {
    guard let index = videos.firstIndex(of: video) else { return }

    videos.remove(at: index)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didRemove: video)
    }
  }

  public func reload(_ images: [Image]) {
    self.images = images

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cartDidReload(self)
    }
  }

  // MARK: - Reset

  public func reset() {
    videos.removeAll()
    images.removeAll()
    delegates.removeAllObjects()
  }
}

#endif
