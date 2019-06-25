## Installation & Launching
```
bundle install
cd corva-test/
rails s
```

## Test
```
rspec .
```

## Try online
```
curl -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"timestamp":1493758596,"data":[{"title":"Part 1","values":[0, 3, 5, 6, 2, 9]},{"title":"Part 2","values":[6, 3, 1, 3, 9, 4]}]}' https://immense-sierra-60822.herokuapp.com/compute/1
```

## QUESTIONS

  1. Do we need to make sure request_id is unique?
  2. Do we need to store requests we are getting?
  3. Do we have strict restrictions for titles we are getting?
  4. Should we ignore entries in "data" param we are not currently expecting?
  5. How much we don't trust client? How much edge cases we should realistically handle?
  6. Do we need to check that first value in "data" array has corresponding title?
