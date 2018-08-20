/*
 Copyright 2018 New Vector Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

/// Protocol describing a router that wrap the root navigation of the application.
/// Routers are used to be passed between coordinators. They handles only `physical` navigation.
protocol RootRouterType: class {
    
    /// The root view controller currently presented
    var rootViewController: UIViewController? { get }        
    
    /// Update the root view controller
    ///
    /// - Parameter module: The new root view controller to set
    func setRootModule(_ module: Presentable)        
    
    /// Dismiss the root view controller
    ///
    /// - Parameters:
    ///     - animated: true to animate the transition.
    ///     - completion: the block executed after the view controller is dismissed.
    func dismissModule(animated: Bool, completion: (() -> Void)?)
}
