//
//  ViewController.swift
//  DocumentTest
//
//  Created by 鈴木健太 on 2017/02/22.
//  Copyright © 2017年 鈴木健太. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {

    var interactionController : UIDocumentInteractionController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPushTextButton() {
        if isOpenApp() {
            sendTextFile()
        } else {
            jumpStoreSite()
        }
    }
    
    @IBAction func onPushOpenButton() {
        if isOpenApp() {
            sendImageAndText()
        } else {
            jumpStoreSite()
        }
    }
    
    @IBAction func onPushOpenURL() {
        
        if isOpenApp() {
            openURL()
        } else {
            jumpStoreSite()
        }
    }
    
    func isOpenApp() -> Bool {
        //PROFがインストールされているか確認
        return UIApplication.shared.canOpenURL( URL(string:"prof://")! )
    }
    
    func jumpStoreSite() {
        //PROFのストアに飛ばす
        UIApplication.shared.open( URL(string: "https://app.adjust.com/ouu11h" )!, options: [:], completionHandler: nil)
    }
    
    //UIDocumentInteractionControllerを使用して画像とテキストを送る 片方だけでも可
    func sendImageAndText() {
        
        // 送る対象の画像
        let image = #imageLiteral(resourceName: "test")     //送りたい画像
        
        let data = UIImagePNGRepresentation(image)
        
        // ファイル一時保存してNSURLを取得
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.png") //ファイル名はなんでもか　ただし.png or .jpgのみ
        do {
            try data?.write(to: url!, options: Data.WritingOptions.atomicWrite)
        } catch {
            print("sssss")
        }
        
        interactionController = UIDocumentInteractionController(url: url!)
        interactionController?.delegate = self
        interactionController?.annotation = ["json" : "{\"text\": \"サンプルテキスト\",\"tagId\": \"2246607\"}"]
        interactionController?.uti = "public.png"
        
        if !interactionController.presentOpenInMenu(from: view.frame, in: view, animated: true) {
            print("ファイルに対応するアプリがありません")
        }
    }
    
    //UIDocumentInteractionControllerを使用してテキストを送る
    func sendTextFile() {
        
        // 作成するテキストファイルの名前
        let textFileName = "test.txt"       //拡張子が.txtならファイル名はなんでも可
        let initialText = "{\"text\": \"サンプルテキスト\",\"tagId\": \"2246607\"}"   //送りたいテキストをJSONにして送る
        
        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        let targetTextFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(textFileName)
        
        print("書き込むファイルのパス: \(targetTextFilePath?.description)")
        
        do {
            try initialText.write(to: targetTextFilePath!, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("failed to write: \(error)")
        }
        
        interactionController = UIDocumentInteractionController(url: targetTextFilePath!)
        interactionController?.delegate = self
        interactionController?.uti = "public.text"
        
        if !interactionController.presentOpenInMenu(from: view.frame, in: view, animated: true) {
            print("ファイルに対応するアプリがありません")
        }
    }
    
    //URLスキームを使用して画像とテキストを送る　片方だけでも可
    func openURL() {
        
        let image   = #imageLiteral(resourceName: "test")         //送りたい画像
        var text    = "PROF URL スキーマテスト"    //送りたいテキスト
        let tag:Int = 2246607   //タグのデフォルト値
        
        let imageData = UIImagePNGRepresentation(image)
        var imageBase64String: String = (imageData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters))!
        
        //パース時のミス回避のためURLエンコード
        imageBase64String = imageBase64String.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        //=だけ別対応
        imageBase64String = imageBase64String.replacingOccurrences(of: "=", with: "**")
        
        text = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        text = text.replacingOccurrences(of: "=", with: "**")
        
        let urlString = "prof://UIDocumantation/q?image=\(imageBase64String)&text=\(text)&tagId=\(tag)"
        let url = NSURL(string: urlString)
        UIApplication.shared.open(url as! URL, options: [:] ) { (finish: Bool) in }
    }
}
