//
//  ViewController.swift
//  BbatonAppDemo
//
//  Created by Wony Cho on 2021/08/21.
//

import UIKit
import BbatonIOSFramework

class TestViewController: UIViewController, BbatonDelegate {
    func sendUserData(adult_flag: String?, user_id: String?) {
        DispatchQueue.main.async {
            self.textView.text = "ADULT_FLAG :: " + adult_flag! + " USER_ID :: " + user_id!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func toBbatonLogin(_ sender: Any) {
        let s = UIStoryboard(
            name: "Bbaton", bundle: Bundle(for: BbatonViewController.self)
        )
        
        let vc: BbatonViewController = s.instantiateViewController(withIdentifier: "BbatonViewController") as! BbatonViewController
        vc.clientId = "JDJhJDA0JE9naE5jNVBGUFNBbXM1VGlRQlJiMC5kWDkwMTg5OUtZb05obkMy";
        vc.clientSecret = "Tm43d0VLNXNyLlFjOE9X";
        vc.redirectUrl = "http://doublt.rdr.com/oauth/callback";
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBOutlet weak var textView: UITextView!
    
}
