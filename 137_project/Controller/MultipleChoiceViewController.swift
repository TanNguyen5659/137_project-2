//
//  MultipleChoiceViewController.swift
//  Quiz Game
//
//  Created by Tan Nguyen on 11/30/20.
//

import UIKit

class MultipleChoiceViewController: UIViewController {
    private let contentView = UIView()
    private var contentViewConstraints: [NSLayoutConstraint]!
    
    private let questionView = UIView()
    private var questionViewConstraints: [NSLayoutConstraint]!
    
    private let answerView = UIView()
    private var answerViewConstraints: [NSLayoutConstraint]!
    
    private let countdownView = UIView()
    private var countdownViewConstraints: [NSLayoutConstraint]!
    
    private let questionLabel = RoundedLabel()
    private var questionLabelConstraints: [NSLayoutConstraint]!
    private let questionButton = RoundedButton()
    private var questionButtonConstraints: [NSLayoutConstraint]!
    
    private var answerButtons = [RoundedButton]()
    private var answerButtonsConstraints: [NSLayoutConstraint]!
    
    private let progressView = UIProgressView()
    private var progressViewConstraints: [NSLayoutConstraint]!
    
    private let backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
    private let foregroundColor = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
    
    private let quizLoader = QuizLoader()
    private var questionArray = [MultipleChoiceQuestion]()
    private var questionIndex = 0
    private var currentQuestion: MultipleChoiceQuestion!
    
    private var timer = Timer()
    private var score = 0
    private var highscore = UserDefaults.standard.integer(forKey: multipleChoiceHighscoreIdentifier)
    
    private var quizAlertView: QuizAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        layoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    func layoutView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        questionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(questionView)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionView.addSubview(questionLabel)
        questionLabel.backgroundColor = foregroundColor
        questionLabel.textColor = UIColor.white
        questionLabel.font = UIFont.boldSystemFont(ofSize: 30)
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 4
        questionLabel.adjustsFontSizeToFitWidth = true
        questionButton.translatesAutoresizingMaskIntoConstraints = false
        questionView.addSubview(questionButton)
        questionButton.addTarget(self, action: #selector(questionsButtonHandler), for: .touchUpInside)
        questionButton.isEnabled = false
        
        answerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(answerView)
        for _ in 0...3 {
            let button = RoundedButton()
            answerButtons.append(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            answerView.addSubview(button)
            button.addTarget(self, action: #selector(answerButtonsHandler), for: .touchUpInside)
        }
        
        countdownView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countdownView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        countdownView.addSubview(progressView)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 10)
        
        contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        questionViewConstraints = [
            questionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
            questionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
            questionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
            questionView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4)
        ]
        
        questionLabelConstraints = [
            questionLabel.topAnchor.constraint(equalTo: questionView.topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: questionView.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: questionView.trailingAnchor),
            questionLabel.bottomAnchor.constraint(equalTo: questionView.bottomAnchor)
        ]
        
        questionButtonConstraints = [
            questionButton.topAnchor.constraint(equalTo: questionView.topAnchor),
            questionButton.leadingAnchor.constraint(equalTo: questionView.leadingAnchor),
            questionButton.trailingAnchor.constraint(equalTo: questionView.trailingAnchor),
            questionButton.bottomAnchor.constraint(equalTo: questionView.bottomAnchor)
        ]
        
        answerViewConstraints = [
            answerView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 20.0),
            answerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
            answerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
            answerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4)
        ]
        
        answerButtonsConstraints = [
            answerButtons[0].leadingAnchor.constraint(equalTo: answerView.leadingAnchor),
            answerButtons[0].trailingAnchor.constraint(equalTo: answerButtons[1].leadingAnchor, constant: -8.0),
            answerButtons[0].topAnchor.constraint(equalTo: answerView.topAnchor),
            answerButtons[0].bottomAnchor.constraint(equalTo: answerButtons[2].topAnchor, constant: -8.0),
            answerButtons[1].trailingAnchor.constraint(equalTo: answerView.trailingAnchor),
            answerButtons[1].topAnchor.constraint(equalTo: answerView.topAnchor),
            answerButtons[1].bottomAnchor.constraint(equalTo: answerButtons[3].topAnchor, constant: -8.0),
            answerButtons[2].leadingAnchor.constraint(equalTo: answerView.leadingAnchor),
            answerButtons[2].trailingAnchor.constraint(equalTo: answerButtons[3].leadingAnchor, constant: -8.0),
            answerButtons[2].bottomAnchor.constraint(equalTo: answerView.bottomAnchor),
            answerButtons[3].trailingAnchor.constraint(equalTo: answerView.trailingAnchor),
            answerButtons[3].bottomAnchor.constraint(equalTo: answerView.bottomAnchor)
        ]
        
        for index in 1..<answerButtons.count {
            answerButtonsConstraints.append(answerButtons[index].heightAnchor.constraint(equalTo: answerButtons[index-1].heightAnchor))
            answerButtonsConstraints.append(answerButtons[index].widthAnchor.constraint(equalTo: answerButtons[index-1].widthAnchor))
        }
        
        countdownViewConstraints = [
            countdownView.topAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 20.0),
            countdownView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
            countdownView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
            countdownView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0)
        ]
        
        progressViewConstraints = [
            progressView.leadingAnchor.constraint(equalTo: countdownView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: countdownView.trailingAnchor),
            progressView.centerYAnchor.constraint(equalTo: countdownView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(contentViewConstraints)
        NSLayoutConstraint.activate(questionViewConstraints)
        NSLayoutConstraint.activate(questionLabelConstraints)
        NSLayoutConstraint.activate(questionButtonConstraints)
        NSLayoutConstraint.activate(answerViewConstraints)
        NSLayoutConstraint.activate(answerButtonsConstraints)
        NSLayoutConstraint.activate(countdownViewConstraints)
        NSLayoutConstraint.activate(progressViewConstraints)
        
        loadQuestions()
    }
    
    func loadQuestions() {
        do {
            questionArray = try quizLoader.loadMultipleChoiceQuiz(forQuiz: "MultipleChoice")
            loadNextQuestion()
        } catch  {
            switch error {
            case LoaderError.dictionaryFailed:
                print("Could not load dictionary")
            case LoaderError.pathFailed:
                print("Could not find valid file at the path")
            default:
                print("Error")
            }
        }
    }
    
    func loadNextQuestion() {
        currentQuestion = questionArray[questionIndex]
        setTitlesForButtons()
    }
    
    func setTitlesForButtons() {
        for (index,button) in answerButtons.enumerated() {
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.setTitle(currentQuestion.answers[index], for: .normal)
            button.isEnabled = true
            button.backgroundColor = foregroundColor
        }
        questionLabel.text = currentQuestion.question
        startTimer()
    }
    
    func startTimer() {
        progressView.progressTintColor = flatGreen
        progressView.trackTintColor = UIColor.clear
        progressView.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgressView() {
        progressView.progress -= 0.01/30
        if progressView.progress <= 0 {
            //Time's up
            outOfTime()
        } else if progressView.progress <= 0.2 {
            progressView.progressTintColor = flatRed
        } else if progressView.progress <= 0.5 {
            progressView.progressTintColor = flatOrange
        }
    }
    
    func outOfTime() {
        timer.invalidate()
        showAlert(forReason: 0)
        for button in answerButtons {
            button.isEnabled = false
        }
    }
    
    @objc func questionsButtonHandler() {
        questionButton.isEnabled = false
        questionIndex += 1
        questionIndex < questionArray.count ? loadNextQuestion() : showAlert(forReason: 2)
    }
    
    @objc func answerButtonsHandler(_ sender: RoundedButton){
        timer.invalidate()
        if sender.titleLabel?.text == currentQuestion.correctAnswer {
            score += 1
            questionLabel.text = "Tap to continue"
            questionButton.isEnabled = true
        } else {
            sender.backgroundColor = flatRed
            showAlert(forReason: 1)
        }
        for button in answerButtons {
            button.isEnabled = false
            if button.titleLabel?.text == currentQuestion.correctAnswer {
                button.backgroundColor = flatGreen
            }
        }
    }
    
    func showAlert(forReason reason: Int) {
        switch reason {
        case 0:
            quizAlertView = QuizAlertView(withTitle: "You lost", andMessage: "Need to answer quicker", colors: [backgroundColor, foregroundColor])
        case 1:
            quizAlertView = QuizAlertView(withTitle: "You lost", andMessage: "Wrong answer", colors: [backgroundColor, foregroundColor])
        case 2:
            quizAlertView = QuizAlertView(withTitle: "You won", andMessage: "you have answered all questions", colors: [backgroundColor, foregroundColor])
        default:
            break
        }
        
        if let qav = quizAlertView {
            quizAlertView?.closeButton.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
            createQuizAlertView(withAlert: qav)
        }
    }
    
    func createQuizAlertView(withAlert alert: QuizAlertView) {
        alert.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alert)
        
        alert.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        alert.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        alert.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        alert.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc func closeAlert() {
        if score > highscore {
            highscore = score
            UserDefaults.standard.setValue(highscore, forKey: multipleChoiceHighscoreIdentifier)
        }
        UserDefaults.standard.set(score, forKey: multipleChoiceRecentscoreIdentifier)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            timer.invalidate()
        }
    }
    
    }
    
    
    
    


