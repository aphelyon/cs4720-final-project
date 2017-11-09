//
//  ViewController.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/5/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
// Basically a Swift version of this https://github.com/bhallier/NetbadgeAuthenticator/blob/master/CavAdvantage/src/NetbadgeAuthenticator.java
//

import UIKit
import SwiftSoup
import Alamofire
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var webview: UIWebView!
    @IBAction func dismissAuthenticator(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    let url = "https://netbadge.virginia.edu/";
    var request = URLRequest(url : URL(string: "https://netbadge.virginia.edu/")!);
    func getPageContent(url: String, username: String, password: String) {
        Alamofire.request("https://netbadge.virginia.edu/").responseString { response in
            self.saveCookies(response: response)
            if let html = response.result.value {
                self.getFormParamas(gurl: url, html:html as! String, gusername : username, gpassword: password)
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
    
    func saveCookies(response: DataResponse<String>) {
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.response?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        UserDefaults.standard.set(cookieArray, forKey: "savedCookies")
        UserDefaults.standard.synchronize()
    }
    
    func loadCookies() {
        guard let cookieArray = UserDefaults.standard.array(forKey: "savedCookies") as? [[HTTPCookiePropertyKey: Any]] else { return }
        for cookieProperties in cookieArray {
            if let cookie = HTTPCookie(properties: cookieProperties) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    
    func sendPost(purl:String, postParams: String, pusername: String, ppassword: String) {
        let urlreq = URL(string: purl);
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
                }
        }
        
        task.resume()
    }
    
    func authenticate(url: String, username: String, password: String) {
        self.getPageContent(url: url, username: username, password: password);
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authenticate(url: url, username: "mhc6kp", password: "#notactuallymypassword");
       
        
        
        
        
        
        
        
        
        
        
        
        self.webview.loadRequest(self.request)
        let secondUrl = URL (string: "https://csg-web1.eservices.virginia.edu/login/sso.php")
        let requestObj = URLRequest(url: secondUrl!)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2) + .milliseconds(400), execute: {
        self.webview.loadRequest(requestObj)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2) + .milliseconds(500), execute: {
                let doc = self.webview.stringByEvaluatingJavaScript(from: "document.body.innerHTML")
                if let page = doc {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700), execute: {
                        
                        if page.contains("The CBORD Group, Inc.") {
                            let thirdUrl = URL (string: "https://csg-web1.eservices.virginia.edu/student/welcome.php")
                            let requestObj2 = URLRequest(url: thirdUrl!)
                            self.webview.loadRequest(requestObj2)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                                let doc = self.webview.stringByEvaluatingJavaScript(from: "document.body.innerHTML")
                                if let page = doc{
                                    print(page)
                                }
                                let storage = HTTPCookieStorage.shared
                                for cookie in storage.cookies! {
                                    storage.deleteCookie(cookie)
                                }
                            })

                        }
                    })
                }
            })
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func displayAlertWithTitle(title: String, message: String) {
        
    }

}

