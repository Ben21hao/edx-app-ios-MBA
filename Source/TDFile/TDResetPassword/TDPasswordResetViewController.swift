//
//  TDPasswordResetViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/3/29.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDPasswordResetViewController: UIViewController, UITextFieldDelegate {

    var originView = TDPasswordResetView()
    var newView = TDPasswordResetView()
    var repeatView = TDPasswordResetView()
    var handinButton = SpinnerButton()
    var warmLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Strings.passwordResetTitle
        initView()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let enable = judgeEnable(textField, shouldChangeCharactersIn: range, replacementString: string)
        handinButton.backgroundColor = UIColor(hexString: enable ? "#0279bc" : "#d3d3d3")
        handinButton.isUserInteractionEnabled = enable ? true : false
        return true
    }
    
    func judgeEnable(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var oringinString : String = originView.inputTextFeld.text ?? ""
        var newString : String = newView.inputTextFeld.text ?? ""
        var repeatString : String = repeatView.inputTextFeld.text ?? ""
        
        let increase = range.length == 0
        
        if textField.isEqual(originView.inputTextFeld) {
            oringinString = oringinString + string
            if !increase {
                oringinString = String(oringinString.prefix(range.location))
            }
        }
        else if textField.isEqual(newView.inputTextFeld) {
            newString = newString + string
            if !increase {
                newString = String(newString.prefix(range.location))
            }
        }
        else {
            repeatString = repeatString + string
            if !increase {
                repeatString = String(repeatString.prefix(range.location))
            }
        }
        print("------>>\(oringinString)")
        
        guard oringinString.isEmpty == false else {
            return false
        }
        
        guard newString.isEmpty == false else {
            return false
        }
        
        guard repeatString.isEmpty == false else {
            return false
        }
        
        guard newString.count > 5 && repeatString.count > 5 else {
            return false
        }
        
        return true
    }
    
    @objc func handinButtonAction() {
        viewResignFirstResponder()
        
        if newView.inputTextFeld.text != repeatView.inputTextFeld.text  {
            self.view.makeToast(Strings.newPasswordNomatch, duration: 0.8, position: CSToastPositionCenter)
            return
        }
        
        //TODO:访问重置密码接口
        handinButton.showProgress = true
        SVProgressHUD.show(withStatus: Strings.submintingText)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        
        let oringinString : String = originView.inputTextFeld.text ?? ""
        let newString : String = newView.inputTextFeld.text ?? ""
        let repeatString : String = repeatView.inputTextFeld.text ?? ""
        
        let dic = NSMutableDictionary()
        dic.setValue(oringinString, forKey: "old_password")
        dic.setValue(newString, forKey: "new_password1")
        dic.setValue(repeatString, forKey: "new_password2")
        
        let body: NSString = dic.oex_stringByUsingFormEncoding() as NSString
        let configuration : URLSessionConfiguration  = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = configuration.defaultHTTPHeaders() as? [AnyHashable : Any]
        
        let request : NSMutableURLRequest = NSMutableURLRequest(url:URL(string: (OEXConfig.shared().apiHostURL()?.absoluteString)! + APP_PASSWORD_RESET)!)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: String.Encoding.utf8.rawValue)
        
        let authValue = OEXAuthentication.authHeaderForApiAccess()
        request.setValue(authValue, forHTTPHeaderField: "Authorization")
        
        let session: URLSession = URLSession(configuration: configuration)
        let task : URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.handinButton.showProgress = false
                SVProgressHUD.dismiss()
            }
            
            if error == nil {
                let httpResp : HTTPURLResponse = response as! HTTPURLResponse
                if httpResp.statusCode == 200 {
                    do {
                        let responDic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]
                        
                        let code : Int = responDic?["code"] as! Int
                        self.showMessage(code: code)
                        
                        if code == 200 {
                            self.showMessage(code: httpResp.statusCode)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 , execute:{
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                    catch {
                        
                    }
                }
            }
            else {
                DispatchQueue.main.sync {
                    self.view.makeToast(Strings.passwordResetFailed, duration: 0.8, position: CSToastPositionCenter)
                    print("出错了")
                }
            }
        }
        task.resume()
    }
    
    func showMessage(code: Int) {
        DispatchQueue.main.sync {
            switch code {
            case 200:
                self.view.makeToast(Strings.passwordModified, duration: 0.8, position: CSToastPositionCenter)
            case 201:
                self.view.makeToast(Strings.newPasswordNomatch, duration: 0.8, position: CSToastPositionCenter)
            case 202:
                self.view.makeToast(Strings.newPasswordSimilar, duration: 0.8, position: CSToastPositionCenter)
            case 203:
                self.view.makeToast(Strings.oldpasswordIncorrect, duration: 0.8, position: CSToastPositionCenter)
                
            default:
                self.view.makeToast(Strings.passwordResetFailed, duration: 0.8, position: CSToastPositionCenter)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewResignFirstResponder()
    }
    
    func viewResignFirstResponder() {
        originView.inputTextFeld.resignFirstResponder()
        newView.inputTextFeld.resignFirstResponder()
        repeatView.inputTextFeld.resignFirstResponder()
    }
    
    //MARK: UI
    func initView() {
        view.backgroundColor = UIColor.white
        handinButton.backgroundColor = UIColor(hexString: "#d3d3d3")
        handinButton.layer.cornerRadius = 4.0
        handinButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        handinButton.setTitle(Strings.submitText, for: .normal)
        handinButton.addTarget(self, action: #selector(handinButtonAction), for: .touchUpInside)
        handinButton.isUserInteractionEnabled = false
        
        let titleStyle = OEXTextStyle(weight: .normal, size: .base, color : OEXStyles.shared().neutralDark())
        originView.titleLabel.attributedText = titleStyle.attributedString(withText: Strings.oldPassword)
        newView.titleLabel.attributedText = titleStyle.attributedString(withText: Strings.newPassword)
        repeatView.titleLabel.attributedText = titleStyle.attributedString(withText: Strings.confirmPassword)
        
        let warmStyle = OEXTextStyle(weight: .normal, size: .small, color : OEXStyles.shared().neutralDark())
        warmLabel.attributedText = warmStyle.attributedString(withText: Strings.leastSixCharacter)
        
        originView.inputTextFeld.delegate = self
        newView.inputTextFeld.delegate = self
        repeatView.inputTextFeld.delegate = self
        
        view.addSubview(originView)
        view.addSubview(newView)
        view.addSubview(repeatView)
        view.addSubview(handinButton)
        view.addSubview(warmLabel)
        
        originView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(view).offset(StandardHorizontalMargin)
            make.height.equalTo(74.0)
        }
        
        newView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(originView.snp.bottom)
            make.height.equalTo(74.0)
        }
        
        repeatView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(newView.snp.bottom)
            make.height.equalTo(74.0)
        }
        
        handinButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset((-32))
            make.top.equalTo(repeatView.snp.bottom).offset(35)
            make.height.equalTo(41)
        }
        
        warmLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(32)
            make.top.equalTo(repeatView.snp.bottom).offset(5)
        }
    }

}