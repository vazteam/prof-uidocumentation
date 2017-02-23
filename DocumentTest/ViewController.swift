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
        UIApplication.shared.open( URL(string: "https://itunes.apple.com/jp/app/prof-3shi-jiande-xiaoerusns/id1076211312?mt=8" )!, options: [:], completionHandler: nil)
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
        interactionController?.annotation = ["json" : "{\"text\": \"asdefafadaqfrqefsdcadsfsrgsfsf\",\"tag_id\": \"dhsuhwufhusdhu\"}"]
        interactionController?.uti = "public.png"
        
        if !interactionController.presentOpenInMenu(from: view.frame, in: view, animated: true) {
            print("ファイルに対応するアプリがありません")
        }
    }
    
    //UIDocumentInteractionControllerを使用してテキストを送る
    func sendTextFile() {
        
        // 作成するテキストファイルの名前
        let textFileName = "test.txt"       //拡張子が.txtならファイル名はなんでも可
        let initialText = "{\"text\": \"asdefafadaqfrqefsdcadsfsrgsfsf\",\"tag_id\": \"dhsuhwufhusdhu\"}"   //送りたいテキストをJSONにして送る　tag_idはPROFでは現在未実装
        
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
        
        let image = #imageLiteral(resourceName: "test")         //送りたい画像
        let text = "sssssss"    //送りたいテキスト
        
        let imageData = UIImagePNGRepresentation(image)
        var imageBase64String: String = (imageData?.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed))!
        
        //パース時のミス回避のため
        imageBase64String = imageBase64String.replacingOccurrences(of: "=", with: "@@")
        
        let url = NSURL(string: "prof://UIDocumantation/q?image=\(imageBase64String)&text=\(text)")
        UIApplication.shared.open(url as! URL, options: [:] ) { (finish: Bool) in }
    }
}
