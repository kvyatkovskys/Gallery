#if os(iOS)

import UIKit
import AVFoundation

public enum GalleryMediaType {
    case image(Image), video(Video)
}

public protocol GalleryControllerDelegate: class {

  func galleryController(_ controller: GalleryController, didSelectImages images: [Image])
  func galleryController(_ controller: GalleryController, didSelectVideos videos: [Video])
  func galleryController(_ controller: GalleryController, didSelectMedias medias: [GalleryMediaType])
  func galleryController(_ controller: GalleryController, requestLightbox images: [Image])
  func galleryControllerDidCancel(_ controller: GalleryController)
    
}

open class GalleryController: UIViewController, PermissionControllerDelegate {

  public weak var delegate: GalleryControllerDelegate?

  public let cart = Cart()

  // MARK: - Init

  public required init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Life cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    if let pagesController = makePagesController() {
      g_addChildController(pagesController)
    } else {
      let permissionController = makePermissionController()
      g_addChildController(permissionController)
    }
  }

  open override var prefersStatusBarHidden : Bool {
    return Config.showStatusBar
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController(cart: cart)
    controller.title = "Gallery.Images.Title".g_localize(fallback: "PHOTOS")

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController(cart: cart)
    controller.title = "Gallery.Camera.Title".g_localize(fallback: "CAMERA")

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController(cart: cart)
    controller.title = "Gallery.Videos.Title".g_localize(fallback: "VIDEOS")

    return controller
  }

  func makePagesController() -> PagesController? {
    guard Permission.Photos.status == .authorized else {
      return nil
    }

    let useCamera = Permission.Camera.needsPermission && Permission.Camera.status == .authorized

    let tabsToShow = Config.tabsToShow.compactMap { $0 != .cameraTab ? $0 : (useCamera ? $0 : nil) }

    let controllers: [UIViewController] = tabsToShow.compactMap { tab in
      if tab == .imageTab {
        return makeImagesController()
      } else if tab == .cameraTab {
        return makeCameraController()
      } else if tab == .videoTab {
        return makeVideosController()
      } else {
        return nil
      }
    }

    guard !controllers.isEmpty else {
      return nil
    }

    let controller = PagesController(controllers: controllers)
    controller.selectedIndex = tabsToShow.firstIndex(of: Config.initialTab ?? .cameraTab) ?? 0

    return controller
  }

  func makePermissionController() -> PermissionController {
    let controller = PermissionController()
    controller.delegate = self

    return controller
  }

  // MARK: - Setup

  func setup() {
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryControllerDidCancel(strongSelf)
      }
    }

    EventHub.shared.doneWithImages = { [weak self] in
      if let strongSelf = self {
        if Config.isEnabledToSaveAllTabs {
          let medias = strongSelf.cart.images.compactMap({ GalleryMediaType.image($0) })
            + strongSelf.cart.videos.compactMap({ GalleryMediaType.video($0) })
          strongSelf.delegate?.galleryController(strongSelf, didSelectMedias: medias)
        } else {
          strongSelf.delegate?.galleryController(strongSelf, didSelectImages: strongSelf.cart.images)
        }
      }
    }

    EventHub.shared.doneWithVideos = { [weak self] in
      if let strongSelf = self {
        if Config.isEnabledToSaveAllTabs {
            let medias = strongSelf.cart.images.compactMap({ GalleryMediaType.image($0) })
              + strongSelf.cart.videos.compactMap({ GalleryMediaType.video($0) })
            strongSelf.delegate?.galleryController(strongSelf, didSelectMedias: medias)
        } else {
            strongSelf.delegate?.galleryController(strongSelf, didSelectVideos: strongSelf.cart.videos)
        }
      }
    }

    EventHub.shared.stackViewTouched = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryController(strongSelf, requestLightbox: strongSelf.cart.images)
      }
    }
  }

  // MARK: - PermissionControllerDelegate

  func permissionControllerDidFinish(_ controller: PermissionController) {
    if let pagesController = makePagesController() {
      g_addChildController(pagesController)
      controller.g_removeFromParentController()
    }
  }
}

#endif
