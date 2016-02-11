import Foundation
import UIKit

import RxSwift
import Action
import Motif
import RazzleDazzle
import Cartography
import FBSDKLoginKit

class SetupViewController: AnimatedPagingScrollViewController, UITextFieldDelegate {
    var theme: MTFTheme!
    
    private let titleLabel = UILabel()
    private let introLabel = UILabel()
    
    private let facebookInfoLabel = UILabel()
    private let facebookButton = FBSDKLoginButton()
    
    private let basicInfoLabel = UILabel()
    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let phoneNumberField = UITextField()
    
    private let socialInfoLabel = UILabel()
    private let twitterField = UITextField()
    private let snapchatField = UITextField()
    
    private let doneButton = UIButton()
    
    private var user: User = User()
    
    var onComplete: (User -> ())?
    
    /*
     * Pages:
     * 1. General intro
     * 2. Facebook login
     * 3. Name (default from Facebook)
     *    Phone Number (default from Facebook)
     * 4. Twitter
     *    Snapchat
     * 5. Done!
     */
    
    override func numberOfPages() -> Int {
        return 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackground()
        configureViews()
        configureBindings()
        
        let recognizer = UITapGestureRecognizer(target: self, action: "handleTaps:")
        contentView.addGestureRecognizer(recognizer)
    }
    
    private func configureBackground() {
        let backgroundColorAnimation = BackgroundColorAnimation(view: scrollView)
        backgroundColorAnimation[0] = theme.primaryColor
        backgroundColorAnimation[5] = theme.primaryLightColor
        animator.addAnimation(backgroundColorAnimation)
    }
    
    private func configureViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(introLabel)
        contentView.addSubview(facebookButton)
        contentView.addSubview(firstNameField)
        contentView.addSubview(lastNameField)
        contentView.addSubview(phoneNumberField)
        contentView.addSubview(twitterField)
        contentView.addSubview(snapchatField)
        contentView.addSubview(facebookInfoLabel)
        contentView.addSubview(basicInfoLabel)
        contentView.addSubview(socialInfoLabel)
        contentView.addSubview(doneButton)
        
        configureTitleLabel()
        configureIntro()
        configureFacebook()
        configureBasicInfoLabel()
        configureNameFields()
        configurePhoneNumberField()
        configureSocialFields()
        configureDoneButton()
    }
    
    private func configureTitleLabel() {
        titleLabel.text = "Intros"
        titleLabel.textColor = theme.accentColor
        titleLabel.font = UIFont.systemFontOfSize(50)
        titleLabel.sizeToFit()
        
        constrain(titleLabel, contentView) { titleLabel, contentView in
            titleLabel.top == contentView.top + 80
        }
        
        keepView(titleLabel, onPages: [0, 1])
        
        let titleLabelFadeAnimation = AlphaAnimation(view: titleLabel)
        titleLabelFadeAnimation[0] = 1
        titleLabelFadeAnimation[1] = 0
        animator.addAnimation(titleLabelFadeAnimation)
        
        let titleLabelHideAnimation = HideAnimation(view: titleLabel, hideAt: 1)
        animator.addAnimation(titleLabelHideAnimation)
    }
    
    private func configureIntro() {
        introLabel.text = "Words, Words, Words!"
        introLabel.lineBreakMode = .ByWordWrapping
        introLabel.numberOfLines = 0
        introLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        introLabel.textColor = theme.accentColor
        
        constrain(introLabel, contentView, scrollView) { introLabel, contentView, scrollView in
            introLabel.centerY == contentView.centerY
            introLabel.width == scrollView.width * 0.6
        }
        
        keepView(introLabel, onPage: 0)
    }
    
    private func configureFacebook() {
        facebookInfoLabel.text = "Let people know who you are on Facebook"
        facebookInfoLabel.lineBreakMode = .ByWordWrapping
        facebookInfoLabel.numberOfLines = 0
        facebookInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        theme.applyClass("Label", to: facebookInfoLabel)
        
        facebookButton.titleLabel?.font = UIFont.systemFontOfSize(20)
        
        constrain(facebookButton, facebookInfoLabel, contentView, scrollView) { facebookButton, facebookInfoLabel, contentView, scrollView in
            facebookInfoLabel.top == contentView.top + 100
            facebookInfoLabel.width == scrollView.width * 0.6
            
            facebookButton.centerY == contentView.centerY
            
            facebookButton.width == scrollView.width * 0.75
            facebookButton.height == 60
        }
        keepView(facebookButton, onPage: 1)
        keepView(facebookInfoLabel, onPage: 1)
        
        facebookButton.rx_login.subscribeNext { result in
            if (!result.isCancelled) {
                self.user.facebookId = result.token.userID
                self.loadNames()
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    private func configureBasicInfoLabel() {
        basicInfoLabel.text = "Tell us a bit about yourself"
        basicInfoLabel.lineBreakMode = .ByWordWrapping
        basicInfoLabel.numberOfLines = 0
        basicInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        theme.applyClass("Label", to: basicInfoLabel)
        
        constrain(basicInfoLabel, contentView, scrollView) { basicInfoLabel, contentView, scrollView in
            basicInfoLabel.top == contentView.top + 100
            basicInfoLabel.width == scrollView.width * 0.6
        }
        keepView(basicInfoLabel, onPage: 2)
    }
    
    private func configureNameFields() {
        firstNameField.placeholder = "First Name"
        lastNameField.placeholder = "Last Name"
        
        firstNameField.returnKeyType = .Done
        firstNameField.delegate = self
        lastNameField.returnKeyType = .Done
        lastNameField.delegate = self

        theme.applyClass("IntroTextField", to: firstNameField)
        theme.applyClass("IntroTextField", to: lastNameField)
        
        let height = firstNameField.sizeThatFits(firstNameField.frame.size).height + 10
        
        if let _ = FBSDKAccessToken.currentAccessToken() {
            loadNames()
        }
        
        constrain(firstNameField, lastNameField, basicInfoLabel, scrollView) { firstNameField, lastNameField, basicInfoLabel, scrollView in
            firstNameField.height == height
            lastNameField.height == height
            
            firstNameField.top == basicInfoLabel.bottom + 40
            lastNameField.top == firstNameField.bottom + 20
            
            firstNameField.width == scrollView.width * 0.75
            lastNameField.width == firstNameField.width
        }
        
        keepView(firstNameField, onPage: 2)
        keepView(lastNameField, onPage: 2)
    }
    
    private func configurePhoneNumberField() {
        phoneNumberField.placeholder = "Phone Number"
        phoneNumberField.keyboardType = .PhonePad
        phoneNumberField.delegate = self
        phoneNumberField.returnKeyType = .Done
        theme.applyClass("IntroTextField", to: phoneNumberField)
        
        constrain(lastNameField, phoneNumberField) { lastNameField, phoneNumberField in
            phoneNumberField.top == lastNameField.bottom + 20
            phoneNumberField.width == lastNameField.width
        }
        
        keepView(phoneNumberField, onPage: 2)
    }
    
    private func configureSocialFields() {
        socialInfoLabel.text = "Almost done! Just let us know what apps you want to share"
        socialInfoLabel.lineBreakMode = .ByWordWrapping
        socialInfoLabel.numberOfLines = 0
        socialInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        theme.applyClass("Label", to: socialInfoLabel)
        
//        let twitterView = UIImageView(image: UIImage(named: "twitter"))
//        twitterView.contentMode = .ScaleAspectFit
        
        theme.applyClass("IntroTextField", to: twitterField)
        twitterField.sizeToFit()
        let twitterIconContainer = UIView(frame: CGRectMake(0, 0, twitterField.frame.height + 5, twitterField.frame.height))
        twitterIconContainer.backgroundColor = UIColor.clearColor()
        
        let twitterIconView = UIImageView(frame: CGRectInset(twitterIconContainer.frame, 5, 5))
        twitterIconView.image = UIImage(named: "twitter")
        twitterIconView.contentMode = .ScaleAspectFit
        twitterIconContainer.addSubview(twitterIconView)
        
        twitterField.leftView = twitterIconContainer
        twitterField.leftViewMode = .Always
        twitterField.placeholder = "Twitter"
        twitterField.delegate = self
        twitterField.returnKeyType = .Done
        
        theme.applyClass("IntroTextField", to: snapchatField)
        snapchatField.sizeToFit()
        let snapchatIconContainer = UIView(frame: CGRectMake(0, 0, snapchatField.frame.height + 5, snapchatField.frame.height))
        snapchatIconContainer.backgroundColor = UIColor.clearColor()
        
        let snapchatIconView = UIImageView(frame: CGRectInset(snapchatIconContainer.frame, 5, 5))
        snapchatIconView.image = UIImage(named: "snap-ghost")
        snapchatIconView.contentMode = .ScaleAspectFit
        snapchatIconContainer.addSubview(snapchatIconView)
        
        snapchatField.leftView = snapchatIconContainer
        snapchatField.leftViewMode = .Always
        snapchatField.placeholder = "Snapchat"
        snapchatField.delegate = self
        snapchatField.returnKeyType = .Done
        
        constrain(twitterField, snapchatField, socialInfoLabel, contentView, scrollView) { twitterField, snapchatField, socialInfoLabel, contentView, scrollView in
            socialInfoLabel.top == contentView.top + 100
            socialInfoLabel.width == scrollView.width * 0.6
            
            snapchatField.width == scrollView.width * 0.75
            twitterField.width == snapchatField.width
            
            twitterField.top == socialInfoLabel.bottom + 100
            snapchatField.top == twitterField.bottom + 20
        }
        
        keepView(twitterField, onPage: 3)
        keepView(snapchatField, onPage: 3)
        keepView(socialInfoLabel, onPage: 3)
    }
    
    private func configureDoneButton() {
        doneButton.setTitle("Get Started!", forState: .Normal)
        theme.applyClass("DoneButton", to: doneButton)
        print(doneButton.tintColor)
        
        constrain(doneButton, contentView) { doneButton, contentView in
            doneButton.centerY == contentView.centerY
        }
        
        keepView(doneButton, onPage: 4)
    }
    
    private func configureBindings() {
        firstNameField.rx_text.bindNext { firstName in
            self.user.firstName = firstName
        }.addDisposableTo(rx_disposeBag)
        
        lastNameField.rx_text.bindNext { lastName in
            self.user.lastName = lastName
        }.addDisposableTo(rx_disposeBag)
        
        phoneNumberField.rx_text.bindNext { phoneNumber in
            self.user.phoneNumber = phoneNumber
        }.addDisposableTo(rx_disposeBag)
        
        twitterField.rx_text.bindNext { twitter in
            self.user.twitterHandle = twitter
        }.addDisposableTo(rx_disposeBag)
        
        snapchatField.rx_text.bindNext { snapchat in
            self.user.snapchatUsername = snapchat
        }.addDisposableTo(rx_disposeBag)
        
        doneButton.rx_action = CocoaAction {
            return Observable.create { observer in
                self.onComplete?(self.user)
                return NopDisposable.instance
            }
        }
    }
    
    private func loadNames() {
        Facebook.requestProfile(["first_name", "last_name"]).subscribeNext { response in
            let data = response as! [String: AnyObject]
            if self.firstNameField.text?.isEmpty ?? true {
                self.firstNameField.text = data["first_name"] as? String
            }
            if self.lastNameField.text?.isEmpty ?? true {
                self.lastNameField.text = data["last_name"] as? String
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    @IBAction
    func handleTaps(sender: AnyObject?) {
        if firstNameField.editing {
            firstNameField.endEditing(true)
        }
        
        if lastNameField.editing {
            lastNameField.endEditing(true)
        }
        
        if phoneNumberField.editing {
            phoneNumberField.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}