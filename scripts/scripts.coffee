ejs = require('ejs')
fs = require('fs')
request = require('request')
Conversation = require('hubot-conversation')
hubotGeocode = require('hubot-geocode')
needle = require('needle')




module.exports = (robot) ->

  # TFM
  robot.respond /help/i, (res) ->
    htmlContent = fs.readFileSync(__dirname + '/views/helpTemplate.ejs', 'utf8');
    htmlRenderized = ejs.render(htmlContent, {filename: 'helpTemplate.ejs'})

    res.send(htmlRenderized);

  # TFM
  robot.respond /Test/i, (res) ->
    msgData = {
      text: "Latest changes"
      attachments: [
        {
          fallback: "Comparing",
          title: "Comparing"
          title_link: "https://www.google.com"
          text: "HelloText"
          mrkdwn_in: ["text"]
        }
      ]
    }

    # post the message
    res.send msgData
  # TFM
  switchBoard = new Conversation(robot)
  robot.hear /Im hungry for (.*)/i, (msg) ->
    dialog = switchBoard.startDialog(msg)
    captureGroup = msg.match[1]
    cat = captureGroup.toLowerCase()

    msg.reply 'Awesome! Where are you? (e.g. 10 East 21st St, New York, NY)'
    console.log(msg.message.user.real_name)
    console.log(msg.message.user.name)
    console.log(msg.message.user.tz)
    console.log(msg.message.user.profile.image_512)
    console.log(msg.message.user.profile.email)
    # console.log(msg.message)

    dialog.addChoice /(.+)/i, (res) ->
      loc = {}
      captureGroup2 = res.match[1]
      cat2 = captureGroup2
      address = cat2.replace(/[ ]/gi, "+")
      console.log(address)

      robot.http("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}A&key=AIzaSyBv3gZj2m5yBmsvx8r5umZBO67Ih4R96bQ")
        .get() (err, httpRes, body) ->
          
          responseData2 = JSON.parse body
          console.log(responseData2)
          loc.lat = responseData2.results[0].geometry.location.lat
          loc.long = responseData2.results[0].geometry.location.lng
          loc.realLat = String(loc.lat)
          loc.realLong = String(loc.long)

          console.log(loc.lat)
          console.log(loc.long)
          console.log(typeof(loc.lat))
          console.log(typeof(loc.long))

          console.log(loc.realLat)
          console.log(loc.realLong)
          console.log(typeof(loc.realLat))
          console.log(typeof(loc.realLong))
          console.log(loc)
          robot.http("https://developers.zomato.com/api/v2.1/search?q=#{cat}&count=5&lat=#{loc.realLat}&lon=#{loc.realLong}&radius=500&sort=rating")
            .header('user-key', "4a80bf5c076f368ad4ef9c22d846ee13")
            .header('Accept', "application/json")
            .get() (err, httpRes, body) ->
              responseData = JSON.parse body
              if responseData.results_found isnt 0
                labels = ["1", "2", "3", "4", "5"]
                newArr = responseData.restaurants.map (x,y,z) ->
                  "&markers=" + "label:" + labels[y] + "%7C" + x.restaurant.location.address 
                console.log(newArr)
                addressString = newArr.toString()
                console.log(addressString)
                addressString = addressString.replace(/[ ]/gi, "+")
                console.log(addressString)
                mapUrl = "http://maps.google.com/maps/api/staticmap?center=#{address}&zoom=15.5&size=512x512&maptype=roadmap#{addressString}&markers=color:green%7C#{address}&sensor=false&format=png&key=AIzaSyBSuS8_clfr2PmZw8UpNZasQ-6M9AP7N3w"
                data = JSON.parse body
                data.search = cat
                
                res.send "So you\'re looking for #{data.search} eh? Here's the top 5 places I found near you!!"
                counter = 1
                for i in data.restaurants
                  msgData = {
                    attachments: [
                      {
                        color: "#36a64f"
                        author_name: i.restaurant.name
                        author_link: i.restaurant.url
                        title: "Menu"
                        title_link: i.restaurant.menu_url
                        thumb_url: i.restaurant.thumb || "http://cdn.mysitemyway.com/etc-mysitemyway/icons/legacy-previews/icons-256/glossy-black-3d-buttons-icons-food-beverage/056798-glossy-black-3d-button-icon-food-beverage-knife-fork3.png"
                        fields: [
                          {
                            title: "Rating"
                            value: i.restaurant.user_rating.aggregate_rating + "/5.0"
                            short: true
                          }
                          {
                            title: "Price Rating"
                            value: i.restaurant.price_range + "/5"
                            short: true
                          }
                          {
                            title: "Avg price for 2"
                            value: "$" + i.restaurant.average_cost_for_two
                          }
                          {
                            title: "Address"
                            value: i.restaurant.location.address
                          }
                        ]
                      }
                      {
                        title: counter
                        color: "#db0012"
                      }
                    ]
                  } 
                  res.send msgData
                  counter = counter + 1
                msgData2 = {
                  attachments: [
                    color: "#db0012"
                    image_url: mapUrl
                    text: "Here are their locations relative to you! p.s. Click to make the map bigger!"
                  ]
                }
                res.send msgData2
                console.log(data)
                postData = JSON.stringify({
                  name: msg.message.user.real_name
                  user_name: msg.message.user.name
                  tz: msg.message.user.tz
                  image: msg.message.user.profile.image_512
                  email: msg.message.user.profile.email
                  search: data.search
                  location: responseData2.results[0].formatted_address
                })

                console.log(postData)
                robot.http("http://localhost:3001/entries")
                  .header('Content-Type', 'application/json')
                  .post(postData) (err, response, body) ->

                    console.log(body)
                    result = JSON.parse(body)
              else
                console.log(responseData)
                res.send("Im sorry, there were no #{cat} places near you ;( Try searching for something else!")
  return

  # TFM
  switchBoardTwo = new Conversation(robot)
  robot.hear /Im poor but I want (.&)/i, (msg) ->
    dialog = switchBoardTwho.startDialog(msg)
    captureGroup = msg.match[1]
    cat = captureGroup.toLowerCase()

    msg.reply 'On a budget? Awesome! Where are you? (e.g. 10 East 21st St, New York, NY)'
    dialog.addChoice /(.-)/i, (res) ->
      loc = {}
      captureGroup2 = res.match[1]
      cat2 = captureGroup2
      address = cat2.replace(/[ ]/gi, "+")
      console.log(address)

      robot.http("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}A&key=AIzaSyBv3gZj2m5yBmsvx8r5umZBO67Ih4R96bQ")
        .get() (err, httpRes, body) ->
          
          responseData2 = JSON.parse body
          # h/t https://stackoverflow.com/questions/8660659/render-ejs-file-in-node-js
          console.log(responseData2)
          loc.lat = responseData2.results[0].geometry.location.lat
          loc.long = responseData2.results[0].geometry.location.lng
          loc.realLat = String(loc.lat)
          loc.realLong = String(loc.long)

          console.log(loc.lat)
          console.log(loc.long)
          console.log(typeof(loc.lat))
          console.log(typeof(loc.long))

          console.log(loc.realLat)
          console.log(loc.realLong)
          console.log(typeof(loc.realLat))
          console.log(typeof(loc.realLong))
          console.log(loc)
          robot.http("https://developers.zomato.com/api/v2.1/search?q=#{cat}&count=5&lat=#{loc.realLat}&lon=#{loc.realLong}&radius=500&sort=cost&order=asc")
            .header('user-key', "4a80bf5c076f368ad4ef9c22d846ee13")
            .header('Accept', "application/json")
            .get() (err, httpRes, body) ->
              responseData = JSON.parse body
              if responseData.results_found isnt 0
                labels = ["1", "2", "3", "4", "5"]
                newArr = responseData.restaurants.map (x,y,z) ->
                  "&markers=" + "label:" + labels[y] + "%7C" + x.restaurant.location.address 
                console.log(newArr)
                addressString = newArr.toString()
                console.log(addressString)
                addressString = addressString.replace(/[ ]/gi, "+")
                console.log(addressString)
                mapUrl = "http://maps.google.com/maps/api/staticmap?center=#{address}&zoom=15.5&size=512x512&maptype=roadmap#{addressString}&markers=color:green%7C#{address}&sensor=false&format=png&key=AIzaSyBSuS8_clfr2PmZw8UpNZasQ-6M9AP7N3w"
                data = JSON.parse body
                data.search = cat
                
                res.send "So you\'re looking for #{data.search} eh? Here's the top 5 places I found near you!!"
                counter = 1
                for i in data.restaurants
                  msgData = {
                    attachments: [
                      {
                        color: "#36a64f"
                        author_name: i.restaurant.name
                        author_link: i.restaurant.url
                        title: "Menu"
                        title_link: i.restaurant.menu_url
                        thumb_url: i.restaurant.thumb || "http://cdn.mysitemyway.com/etc-mysitemyway/icons/legacy-previews/icons-256/glossy-black-3d-buttons-icons-food-beverage/056798-glossy-black-3d-button-icon-food-beverage-knife-fork3.png"
                        fields: [
                          {
                            title: "Rating"
                            value: i.restaurant.user_rating.aggregate_rating + "/5.0"
                            short: true
                          }
                          {
                            title: "Price Rating"
                            value: i.restaurant.price_range + "/5"
                            short: true
                          }
                          {
                            title: "Avg price for 2"
                            value: "$" + i.restaurant.average_cost_for_two
                          }
                          {
                            title: "Address"
                            value: i.restaurant.location.address
                          }
                        ]
                      }
                      {
                        title: counter
                        color: "#db0012"
                      }
                    ]
                  } 
                  res.send msgData
                  counter = counter + 1
                msgData2 = {
                  attachments: [
                    color: "#db0012"
                    image_url: mapUrl
                    text: "Here are their locations relative to you! p.s. Click to make the map bigger!"
                  ]
                }
                res.send msgData2
                console.log(data)
              else
                console.log(responseData)
                res.send("Im sorry, there were no #{cat} places near you ;( Try searching for something else!")
  return
