meteor-voyager
==============

## A server monitoring and reactive load package for meteor

## Dashboard at http://voyagerjs.com

Created at the 2014 Meteor Summer Hackathon by
Roshan Jobanputra, Harrison Harnisch, and Colin DuRant


### Getting Started

Add the Voyager package to your meteor app
```javascript
  mrt add voyager
```

Create an app on your VoyagerJS.com dashboard


In your server side code, add a line to initialize Voyager:
```javascript
  voyager = new Voyager('http://voyagerjs.com', 'apikey');
  // get your api key from your voyagerjs.com dashboard
```


Submit logs using:
```javascript
  voyager.log(level, message, data);
  // 'level' can be one of 'debug', 'info', 'warn', 'error', 'critical'
  // 'message' is any string
  // 'data' is any object
```


Add thresholds to trigger load events on your VoyagerJS.com app config dashboard.

You can name the triggered events anything you want, and multiple thresholds can trigger the same events.

Event of a certain name and direction will be triggered at most once every 5 minutes.


Setup load event handlers in your app using

```javascript
  voyager.on('event_name', function(eventId, eventData) {

    // Do your magic here
    // Update subs/etc to make your app respond to this event

    // eventData is an object like so = {
    //   direction: 'over' or 'under',
    //   currentValue: val
    // }

    voyager.eventCompleted(eventId); // mark the event as completed
  });
```

Add your YO! username to the app config dashboard

You'll get yo's for every triggered event and on server disconnect!