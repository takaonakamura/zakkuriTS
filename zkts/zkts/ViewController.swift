//
//  ViewController.swift
//  zkts
//
//  Created by 中村考男 on 2015/10/16.
//  Copyright © 2015年 tamagawa. All rights reserved.
//
//
//  FirstViewController.swift
//  EventKit01
//

import UIKit
import EventKit

class FirstViewController: UIViewController {
    
    var myEventStore: EKEventStore!
    var myEvents: NSArray!
    var myTargetCalendar: EKCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景を水色に設定.
        self.view.backgroundColor = UIColor.cyanColor()
        
        // EventStoreを生成する.
        myEventStore = EKEventStore()
        
        // ユーザーにカレンダーの使用の許可を求める.
        allowAuthorization()
        
        // Buttonを生成する.
        let myButton = UIButton(frame: CGRectMake(0, 0, 100, 100))
        myButton.setTitle("getEvent", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.backgroundColor = UIColor.redColor()
        myButton.layer.masksToBounds = true
        myButton.layer.cornerRadius = 50.0
        myButton.center = self.view.center
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Buttonをviewに追加.
        self.view.addSubview(myButton)
    }
    
    /*
    認証ステータスを取得.
    */
    func getAuthorization_status() -> Bool {
        
        // ステータスを取得.
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(<#T##EKEntityType#>)
        
        // ステータスを表示 許可されている場合のみtrueを返す.
        switch status {
        case EKAuthorizationStatus.NotDetermined:
            print("NotDetermined")
            return false
            
        case EKAuthorizationStatus.Denied:
            print("Denied")
            return false
            
        case EKAuthorizationStatus.Authorized:
            print("Authorized")
            return true
            
        case EKAuthorizationStatus.Restricted:
            print("Restricted")
            return false
            
        default:
            print("error")
            return false
        }
    }
    
    /*
    認証許可.
    */
    func allowAuthorization() {
        
        // 許可されていなかった場合、認証許可を求める.
        if getAuthorization_status() {
            return
        } else {
            
            // ユーザーに許可を求める.
            myEventStore.requestAccessToEntityType(EKEvent, completion: (granted , error) -> Void in)
                
                // 許可を得られなかった場合アラート発動.
                if granted {
                    return
                }
                else {
                    
                    // メインスレッド 画面制御. 非同期.
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // アラート生成.
                        let myAlert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // アラートアクション.
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    })
                }
            )
        }
    }
    
    /*
    Buttonが押されたときに呼ばれるメソッド.
    */
    func onClickMyButton(sender: UIButton) {
        print("onClickMyButton")
        
        // NSCalendarを生成.
        var myCalendar: NSCalendar = NSCalendar.currentCalendar()
        
        // ユーザのカレンダーを取得.
        var myEventCalendars = myEventStore.calendarsForEntityType(<#T##entityType: EKEntityType##EKEntityType#>)
        
        // 開始日(昨日)コンポーネントの生成.
        let oneDayAgoComponents: NSDateComponents = NSDateComponents()
        oneDayAgoComponents.day = -1
        
        // 昨日から今日までのNSDateを生成.
        let oneDayAgo: NSDate = myCalendar.dateByAddingComponents(oneDayAgoComponents,
            toDate: NSDate(),
            options: 0)!
        
        // 終了日(一年後)コンポーネントの生成.
        let oneYearFromNowComponents: NSDateComponents = NSDateComponents()
        oneYearFromNowComponents.year = 1
        
        // 今日から一年後までのNSDateを生成.
        let oneYearFromNow: NSDate = myCalendar.dateByAddingComponents(oneYearFromNowComponents,
            toDate: NSDate(),
            options: Nil)!
        
        // イベントストアのインスタンスメソッドで述語を生成.
        var predicate = NSPredicate()
        
        // ユーザーの全てのカレンダーからフェッチせよ.
        predicate = myEventStore.predicateForEventsWithStartDate(oneDayAgo,
            endDate: oneYearFromNow,
            calendars: nil)
        
        // 述語にマッチする全てのイベントをフェッチ.
        var events = myEventStore.eventsMatchingPredicate(predicate) as! [EKEvent]
        
        // 発見したイベントを格納する配列を生成.
        var eventItems = [String]()
        
        // イベントが見つかった.
        if !events.isEmpty {
            for i in events{
                print(i.title)
                print(i.startDate)
                print(i.endDate)
                
                // 配列に格納.
                eventItems += ["\(i.title): \(i.startDate)"]
            }
        }
        
        // 画面遷移.
        moveViewController(eventItems)
    }
    
    /*
    画面遷移メソッド.
    */
    func moveViewController(events: NSArray) {
        print("moveViewController")
        
        let myTableViewController = TableViewController()
        
        // TableViewに表示する内容として発見したイベントを入れた配列を渡す.
        myTableViewController.myItems = events
        
        // 画面遷移.
        self.navigationController?.pushViewController(myTableViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
