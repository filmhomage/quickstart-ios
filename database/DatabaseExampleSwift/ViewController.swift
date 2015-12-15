//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase.Core
import FirebaseDatabase
/* Note that "import FirebaseDatabase" is included in BridgingHeader.h */

@objc(ViewController)
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

  // Instance variables
  var ref: Firebase!
  var messages: [FDataSnapshot]! = []
  private var _refHandle: FirebaseHandle!
  private var userInt: UInt32 = arc4random()

  // Outlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textField: UITextField!

  // UIView lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()

    self.ref = Firebase(url: FIRContext.sharedInstance().serviceInfo.databaseURL)

    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
  }
  
  override func viewWillAppear(animated: Bool) {
    self.messages.removeAll()
    // Listen for new messages in the Firebase database
    _refHandle = self.ref.childByAppendingPath("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
      self.messages.append(snapshot)
      self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    })
  }

  override func viewWillDisappear(animated: Bool) {
    self.ref.removeObserverWithHandle(_refHandle)
  }

  // UITableViewDataSource protocol methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // Dequeue cell
    let cell: UITableViewCell! = self.tableView .dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath)

    // Unpack message from Firebase DataSnapshot
    let messageSnapshot: FDataSnapshot! = self.messages[indexPath.row]
    let message = messageSnapshot.value as! Dictionary<String, String>
    let name = message["name"] as String!
    let text = message["text"] as String!
    cell!.textLabel?.text = name + " says " + text

    return cell!
  }

  // UITextViewDelegate protocol methods
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    // Push data to Firebase Database
    self.ref.childByAppendingPath("messages").childByAutoId().setValue(["name": "User\(self.userInt)", "text": textField.text as String!])
    textField.text = ""
    return true
  }
}
