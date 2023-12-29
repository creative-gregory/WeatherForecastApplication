let params = [
    "q" : "(cityname)",
    "appid" : "150a90f84dd3cd9719117246e7e1b8a2"
]

AF.request("http://api.openweathermap.org/data/2.5/weather?", method: .get, parameters: params).responseJSON{ (response) in

}
