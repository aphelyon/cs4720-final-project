//
//  LoginViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/8/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit
import SwiftSoup
import Alamofire
import KeychainSwift

class LoginViewController: UIViewController {
    
    var success = false;
    var keychain = KeychainSwift()
    
    @IBOutlet weak var pin: UITextField!
    
    @IBAction func unwindToHomeView(segue: UIStoryboardSegue) {
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (UIDevice.current.orientation.isPortrait) {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 10
            }
        }
        else {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 100
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (UIDevice.current.orientation.isPortrait) {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 10
            }
        }
        else {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 100
            }
        }
    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK",
                                           style: .default,
                                           handler: nil))
        
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func saveLogin(_ sender: Any) {
        authenticate(url: "https://netbadge.virginia.edu/", username: username.text!, password: password.text!)
        if (pin.text!.characters.count != 4) {
            self.displayAlertWithTitle(title: "Incorrect Pin Length",
                                  message: "Please enter a 4-digit pin")
            let storage = HTTPCookieStorage.shared
            for cookie in storage.cookies! {
                storage.deleteCookie(cookie)
            }
        }
            
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) + .milliseconds(400), execute: {
                if self.success {
                    self.displayAlertWithTitle(title: "Success",
                                          message: "Your NetBadge was Valid. \nLogin was successfully saved.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) + .milliseconds(500), execute: {
                        self.dismiss(animated: true, completion: nil)
                        let storage = HTTPCookieStorage.shared
                        for cookie in storage.cookies! {
                            storage.deleteCookie(cookie)
                        }
                        UserDefaults.standard.set(true, forKey: "loggedIn")
                        self.performSegue(withIdentifier: "saveLogin", sender: self)
                    })
                    self.keychain.set(self.username.text!, forKey: self.pin.text!)
                    self.keychain.set(self.password.text!, forKey: self.pin.text! + "x")
                }
                else {
                    self.displayAlertWithTitle(title: "Incorrect Password",
                                          message: "Login was not successful")
                    let storage = HTTPCookieStorage.shared
                    for cookie in storage.cookies! {
                        storage.deleteCookie(cookie)
                    }
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "saveLogin") {
            let destinationVC = segue.destination as! HomeViewController
            let targetController = destinationVC
            targetController.keychainHome = self.keychain;
        }
        
    }
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func dismissLogin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func getPageContent(url: String, username: String, password: String) {
        Alamofire.request("https://netbadge.virginia.edu/").responseString { response in
            if let html = response.result.value {
                self.getFormParamas(gurl: url, html:html, gusername : username, gpassword: password)
            }
        }
    }
    
    func basicAuthHeader(username: String, password: String) -> String? {
        let encodedUsernameAndPassword = ("\(username):\(password)")
            .data(using: .ascii)?
            .base64EncodedString()
        guard encodedUsernameAndPassword != nil else {
            return nil
        }
        return "Basic \(encodedUsernameAndPassword!)"
    }
    
    
    func getFormParamas(gurl: String, html: String, gusername: String, gpassword: String) -> Void {
        var paramList = [String]()
        let doc: Document = try! SwiftSoup.parse(html)
        let loginform: Element = try! (doc.getElementsByTag("form").get(1))
        let inputElements : Elements = try! (loginform.getElementsByTag("input"));
        for element in inputElements {
            let key = try! element.attr("name");
            var value = try! element.attr("value");
            
            if key == "user" {
                value = gusername;
            }
                
            else if key == "pass" {
                value = gpassword;
            }
                
            else if key == "reply" {
                value = "1login";
            }
            if value != "Log In" {
                paramList.append(key + "=" + value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!);
            }
            
        }
        
        var result = "";
        for param in paramList {
            if result.characters.count == 0 {
                result += param;
            }
            else {
                result += "&" + param;
            }
        }
        self.sendPost(purl:gurl, postParams: result, pusername: gusername, ppassword: gpassword);
    }
    
    
    func sendPost(purl:String, postParams: String, pusername: String, ppassword: String) {
        let urlreq = URL(string: purl);
        var request = URLRequest(url : urlreq!);
        request.httpBody = postParams.data(using: .utf8)
        request.httpMethod = "POST";
        request.httpBody = postParams.data(using: .utf8);
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                
            }
            
            let responseString = String(data: data, encoding: .utf8)
            if (responseString!.contains("Your NetBadge is valid")) {
                print("Your NetBadge is Valid");
                self.success = true;
            }
            else {
                self.success = false;
            }
            
        }
        
        task.resume()
    }
    
    func authenticate(url: String, username: String, password: String) {
        self.getPageContent(url: url, username: username, password: password);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
