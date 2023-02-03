//
//  LaunchViewController.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/2/23.
//

import UIKit
import SwiftUI


class LaunchViewController: UIViewController {
    
    @IBOutlet weak var myUIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create instance from your `SwiftUI` view
        let mySwiftUIView = LaunchScreen()

        // Use the extension
        self.host(component: AnyView(mySwiftUIView), into: myUIView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    /// component: View created by SwiftUI
    /// targetView: The UIView that will host the component
    func host(component: AnyView, into targetView: UIView) {
        let controller = UIHostingController(rootView: component)
        self.addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        targetView.addSubview(controller.view)
        controller.didMove(toParent: self)

        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: targetView.widthAnchor, multiplier: 1),
            controller.view.heightAnchor.constraint(equalTo: targetView.heightAnchor, multiplier: 1),
            controller.view.centerXAnchor.constraint(equalTo: targetView.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: targetView.centerYAnchor)
        ])
    }
}
