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

class ViewController: UIViewController {
    let url = "https://netbadge.virginia.edu/";
    
    
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
            Alamofire.request(request).responseJSON { response in
                if let
                    headerFields = response.response?.allHeaderFields as? [String: String],
                    let URL = response.request?.url
                {
                    self.saveCookies(response: response)
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                    
                }
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
    
    
    func saveCookies(response: DataResponse<Any>) {
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.response?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authenticate(url: url, username: "mhc6kp", password: "#notmypassword");
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.loadCookies();
            Alamofire.request("https://netbadge.virginia.edu/").responseString { response in
                if let html = response.result.value {
                    print(html)
                }
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func displayAlertWithTitle(title: String, message: String) {
        
    }

}

