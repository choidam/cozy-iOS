import Foundation
import UIKit
import NMapsMap

class DetailViewController: UIViewController, StoryboardBased {
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commonView: CommonView!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var detailNaverMapView: NMFMapView!
    
    // Constraint from the top of the CommonView to the top of the MaskView
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    // Height constraint for the CommonView
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        //지도 커스텀
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
        
        detailNaverMapView.mapType = .basic
        
        marker.mapView = detailNaverMapView
        
        
        
    }

    @IBAction func closePressed(_ sender: Any) {
        
        
        
        
        //self.scrollView.scrollToTop()
        self.setTabBarHidden(false)
        self.navigationController?.popViewController(animated: true)
        
    }

    func asCard(_ value: Bool) {
        if value {
            // Round the corners
            self.maskView.layer.cornerRadius = 10
        } else {
            // Round the corners
            self.maskView.layer.cornerRadius = 0
        }
    }
}

extension DetailViewController: Animatable {
    var containerView: UIView? {
        return self.view
    }

    var childView: UIView? {
        return self.commonView
    }

    func presentingView(
        sizeAnimator: UIViewPropertyAnimator,
        positionAnimator: UIViewPropertyAnimator,
        fromFrame: CGRect,
        toFrame: CGRect
    ) {
        // Make the common view the same size as the initial frame
        self.heightConstraint.constant = fromFrame.height

        // Show the close button
        self.closeButton.alpha = 1

        // Make the view look like a card
        self.asCard(true)

        // Redraw the view to update the previous changes
        self.view.layoutIfNeeded()

        // Push the content of the common view down to stay within the safe area insets
        

//        let safeAreaTop =
//            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? .zero
        
        let safeAreaTop = self.view.window?.safeAreaInsets.top ?? .zero
        print("safeAreaTop 값: \(safeAreaTop)")
        
        self.commonView.topConstraintValue = safeAreaTop + 16

        // Animate the common view to a height of 500 points
        self.heightConstraint.constant = 405
        sizeAnimator.addAnimations {
            self.view.layoutIfNeeded()
        }

        // Animate the view to not look like a card
        positionAnimator.addAnimations {
            self.asCard(false)
        }
    }

    func dismissingView(
        sizeAnimator: UIViewPropertyAnimator,
        positionAnimator: UIViewPropertyAnimator,
        fromFrame: CGRect,
        toFrame: CGRect
    ) {
        // If the user has scrolled down in the content, force the common view to go to the top of the screen.
        self.topConstraint.isActive = true

        // If the top card is completely off screen, we move it to be JUST off screen.
        // This makes for a cleaner looking animation.
        if scrollView.contentOffset.y > commonView.frame.height {
            self.topConstraint.constant = -commonView.frame.height
            self.view.layoutIfNeeded()

            // Still want to animate the common view getting pinned to the top of the view
            self.topConstraint.constant = 0
        }

        // Common view does not need to worry about the safe area anymore. Just restore the original value.
        self.commonView.topConstraintValue = 16

        // Animate the height of the common view to be the same size as the TO frame.
        // Also animate hiding the close button
        self.heightConstraint.constant = toFrame.height
        sizeAnimator.addAnimations {
            self.closeButton.alpha = 0
            self.view.layoutIfNeeded()
        }

        // Animate the view to look like a card
        positionAnimator.addAnimations {
            self.asCard(true)
        }
    }
}



extension UIScrollView {
    
    func scrollToTop() {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: false)
    }
}
