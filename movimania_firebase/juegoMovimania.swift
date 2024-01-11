//
//  juegoMovimania.swift
//  movimania_firebase
//
//  Created by usuario on 26/12/23.
//

import UIKit
import AVFoundation


class juegoMovimania: UIViewController {
    
    var imagePathsArray: [String] = []
    var imageRandom: [String] = []
    var firstImage: [Any] = ["", NSNull()]
    var secondImage: [Any] = ["", NSNull()]
    var tiempoRestante: Int = 120
    var timer: Timer?
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var labelTiempo: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    @IBOutlet weak var button13: UIButton!
    @IBOutlet weak var button14: UIButton!
    @IBOutlet weak var button15: UIButton!
    @IBOutlet weak var button16: UIButton!
    
    @IBOutlet weak var newGameButton: UIButton!
    
    var reproductor: AVAudioPlayer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        newGameButton.isHidden = true
        preparedGame()
    }
    
    func preparedGame() {
            imagePathsArray = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg"]
            imageRandom = createRandomImageArray()
            firstImage = ["", NSNull()]
            secondImage = ["", NSNull()]
            score.text = "\(0)"
            tiempoRestante = 10

            let delay: TimeInterval = 1.0
            timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(realizarAccion), userInfo: nil, repeats: true)

            updateTiempoRestanteLabel()
        }

        @objc func realizarAccion() {
            tiempoRestante -= 1

            if tiempoRestante <= 0 {
                timer?.invalidate()
                timer = nil
                finishGame()
            }

            updateTiempoRestanteLabel()
        }

        func mostrarDialogoConfirmacion() {
            let alertController = UIAlertController(title: "¿Deseas guardar su puntuacion?", message: nil, preferredStyle: .alert)

            let continuarAction = UIAlertAction(title: "Sí", style: .default) { _ in
                let score = self.score.text
                UserDefaults.standard.set(score, forKey: "score")
                self.newGameButton.isHidden = false
                let segue = SaveGameScore(nibName: "SaveGameScore", bundle: nil)
                self.present(segue, animated: true, completion: nil)
            }

            let cancelarAction = UIAlertAction(title: "No", style: .cancel) { _ in
                self.navigationController?.popViewController(animated: true)
            }

            alertController.addAction(continuarAction)
            alertController.addAction(cancelarAction)

            present(alertController, animated: true, completion: nil)
        }

        func finishGame() {
            let buttonsArray = [button1, button2, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15, button16]

            for (i, button) in buttonsArray.enumerated() {
                button?.setBackgroundImage(UIImage(named: imageRandom[i]), for: .normal)
                button?.isEnabled = false
            }
            mostrarDialogoConfirmacion()
        }

        func newGame() {
            newGameButton.isHidden = true
            let buttonsArray = [button1, button2, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15, button16]

            for button in buttonsArray {
                button?.setBackgroundImage(UIImage(named: "cardFondo.jpeg"), for: .normal)
                button?.isEnabled = true
            }

            preparedGame()
        }

        func updateTiempoRestanteLabel() {
            let minutos = tiempoRestante / 60
            let segundos = tiempoRestante % 60

            let tiempoRestanteString = String(format: "%02ld:%02ld", minutos, segundos)
            labelTiempo.text = tiempoRestanteString
        }

        func shuffleArray(_ array: inout [String]) -> [String] {
            let count = array.count
            for i in 0..<count {
                let remainingCount = count - i
                let exchangeIndex = i + Int(arc4random_uniform(UInt32(remainingCount)))
                array.swapAt(i, exchangeIndex)
            }

            return array
        }

        func createRandomImageArray() -> [String] {
            var newArray = imagePathsArray
            newArray += imagePathsArray
            newArray = shuffleArray(&newArray)
            return newArray
        }

        func showImage(posicion: Int, button: UIButton) {
            let imageName = imageRandom[posicion - 1]

            if let image = UIImage(named: imageName) {
                button.setBackgroundImage(image, for: .normal)
                button.superview?.layoutIfNeeded()
                assignImage(imageName: imageName, toButton: button)
            }
        }

        func assignImage(imageName: String, toButton button: UIButton) {
            if firstImage[0] as! String == "" {
                firstImage[0] = imageName
                firstImage[1] = button
                (firstImage[1] as! UIButton).isEnabled = false
            } else {
                secondImage[0] = imageName
                secondImage[1] = button
                (secondImage[1] as! UIButton).isEnabled = false
                perform(#selector(validateCardsAfterDelay), with: nil, afterDelay: 0.2)
            }
        }

        @objc func validateCardsAfterDelay() {
            validateCard(firstImage: firstImage, secondImage: secondImage)
        }

        func validateCard(firstImage: [Any], secondImage: [Any]) {
            if firstImage[0] as! String == secondImage[0] as! String {
                (firstImage[1] as! UIButton).isEnabled = false
                (secondImage[1] as! UIButton).isEnabled = false

                if let path = Bundle.main.path(forResource: "aplausos", ofType: "mp3") {
                    let url = URL(fileURLWithPath: path)
                    reproductor = try? AVAudioPlayer(contentsOf: url)
                    reproductor.prepareToPlay()
                    reproductor.play()
                    perform(#selector(stopAudio), with: nil, afterDelay: 2.0)
                }

                let currentText = score.text!
                if let currentScore = Int(currentText) {
                    let updatedScore = currentScore + 1
                    score.text = "\(updatedScore)"
                    if updatedScore == 8 {
                        tiempoRestante = 1
                        mostrarDialogoConfirmacion()
                    }
                }
            } else {
                let image = UIImage(named: "cardFondo.jpeg")
                (firstImage[1] as! UIButton).setBackgroundImage(image, for: .normal)
                (secondImage[1] as! UIButton).setBackgroundImage(image, for: .normal)
                (firstImage[1] as! UIButton).isEnabled = true
                (secondImage[1] as! UIButton).isEnabled = true
            }

            self.firstImage[0] = ""
            self.firstImage[1] = NSNull()
            self.secondImage[0] = ""
            self.secondImage[1] = NSNull()
        }

        @objc func stopAudio() {
            reproductor.stop()
        }
    

    
    @IBAction func buttonPressed(_ sender: Any) {
            if let pressedButton = sender as? UIButton {
                var buttonNumber = 0
                switch pressedButton {
                case button1: buttonNumber = 1
                case button2: buttonNumber = 2
                case button3: buttonNumber = 3
                case button4: buttonNumber = 4
                case button5: buttonNumber = 5
                case button6: buttonNumber = 6
                case button7: buttonNumber = 7
                case button8: buttonNumber = 8
                case button9: buttonNumber = 9
                case button10: buttonNumber = 10
                case button11: buttonNumber = 11
                case button12: buttonNumber = 12
                case button13: buttonNumber = 13
                case button14: buttonNumber = 14
                case button15: buttonNumber = 15
                case button16: buttonNumber = 16
                default: break
                }
                showImage(posicion: buttonNumber, button: pressedButton)
            }
        }
    
    @IBAction func startNewGame(_ sender: Any) {
        newGame()
    }
}
