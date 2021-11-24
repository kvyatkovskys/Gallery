#if os(iOS)

import UIKit

extension UIViewController {

  func g_addChildController(_ controller: UIViewController) {
    addChild(controller)
    view.addSubview(controller.view)
    controller.didMove(toParent: self)

    controller.view.g_pinEdges()
  }

  func g_removeFromParentController() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}

extension UIApplication {
    
  var activeWindow: UIWindow? {
    UIApplication.shared.windows.first(where: { $0.isKeyWindow })
  }
    
  var statusBarHeight: CGFloat {
    if #available(iOS 13.0, *) {
        return activeWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 24
    } else {
        return statusBarFrame.height
    }
  }
    
}

#endif
