//
//  ViewController.swift
//  BbatonIOSFramework
//
//  Created by Wony Cho on 2021/08/21.
//

import UIKit
import WebKit

public class BbatonViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    public var delegate: BbatonDelegate?
    
    @IBOutlet weak var bbatonWebView: WKWebView!
    public var clientId: String = ""
    public var clientSecret: String = ""
    public var redirectUrl: String = ""
    
    private var access_token: String = ""
    private var token_type: String = ""
    private var expires_in: String? = ""
    private var scope: String = ""
    
    private var adult_flag: String? = ""
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
//    private var API_PATH = "http://localhost:8081"
    private var API_PATH = "http://bbaton-dev-alb-1460319868.ap-northeast-2.elb.amazonaws.com:8081"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.viewWithTag(99)?.isHidden = true;
        bbatonWebView.uiDelegate = self
        bbatonWebView.navigationDelegate = self
        textView.isHidden = true
        progressBar.isHidden = true
        
        loadWebPage(url: API_PATH + "/oauth/authorize?client_id="+clientId+"&redirect_uri="+redirectUrl+"&response_type=code&scope=read_profile");
    }
    
    public func loadWebPage(url: String) {
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url: myUrl!)
        bbatonWebView.configuration.preferences.javaScriptEnabled = true
        bbatonWebView.load(myRequest);
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let webURL = webView.url?.absoluteString
        let reqURL = navigationAction.request.url?.absoluteString
        if (webURL?.starts(with: redirectUrl+"?code=") == true) {
            let code = webURL!.replacingOccurrences(of: redirectUrl+"?code=", with: "")
            requestToken(code: code)
        }
        decisionHandler(.allow)
    }
    
    public func requestToken(code: String) {
        bbatonWebView.isHidden = true
        textView.isHidden = false
        progressBar.isHidden = false
        progressBar.setProgress(0.0, animated: true)
        
        print("REQUEST TOKEN ::", code)
        let credentials = clientId + ":" + clientSecret
        let encoded = credentials.data(using: String.Encoding.utf8)?.base64EncodedString()
        print("ENCODED ::", encoded!)
        post(code: code, encoded: encoded!)
    }
    
    public func requestUserInfo() {
        print("ACCESS TOKEN ::", self.access_token)
        print("TOKEN_TYPE ::", self.token_type)
        let authorization = self.token_type + " " + self.access_token
        progressBar.setProgress(0.6, animated: true)
        get(authorization: authorization)
    }
    
    func get(authorization: String) {
        //create the url with NSURL
        let urlString = self.API_PATH + "/v1/user/me"
        print("URL :: ", urlString);
        let url = URL(string: urlString)! //change the url

        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        progressBar.setProgress(0.8, animated: true)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { [self] data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    self.adult_flag = json["adult_flag"] as? String
                    
                    
                    delegate?.sendUserData(adult_flag: self.adult_flag)
                }
            } catch let error {
                print(error.localizedDescription)
            }
       })
        progressBar.setProgress(1.0, animated: true)
        task.resume()
        self.dismiss(animated: true) {
            
        }
    }
    
    
    func post(code: String, encoded: String) {
        // 1. 전송할 값 준비
        let grant_type = "authorization_code"
        let redirect_uri = self.redirectUrl
        let code = code
        let param="grant_type=\(grant_type)&redirect_uri=\(redirect_uri)&code=\(code)"
        let paramData = param.data(using: .utf8)
            
            // 2. URL 객체 정의
        let url = URL(string: API_PATH + "/oauth/token")
            
            // 3. URLRequest 객체를 정의하고 요청 내용을 담는다.
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = paramData
            
        // 4. http 메시지의 헤더를 설정
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic " + encoded, forHTTPHeaderField: "Authorization")
        progressBar.setProgress(0.3, animated: true)
        
        // 5. URLSession 객체를 통해 전송 및 응답값 처리
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // 서버가 응답 없거나 통신이 실패했을때
            if let e = error {
                NSLog("An error has occerred: \(e.localizedDescription)")
                return
            }
            // 응답이 있을때 응답 처리 로직
            // (1) 메인 스레드에서 비동기로 처리되도록 한다
            DispatchQueue.main.async() {
                do {
                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    guard let jsonObject = object else { return }
                    
                    // (2) JSON 결과값을 추출한다.
                    self.access_token = jsonObject["access_token"] as! String
                    self.token_type = jsonObject["token_type"] as! String
                    self.expires_in = jsonObject["expires_in"] as? String
                    self.scope = jsonObject["scope"] as! String
                    self.progressBar.setProgress(0.5, animated: true)
                    
                    self.requestUserInfo()
                } catch let e as NSError {
                    print("An error has occured while parsing JSON Obejt : \(e.localizedDescription)")
                }
            }
        }
            
        // 6. POST 전송
        task.resume()
    }
    
    
}

