# Booking portal

This application emulates the process of booking a payment.

## Requirements

 - Docker https://docs.docker.com/engine/installation/
 - Docker Compose https://docs.docker.com/compose/install/

## Usage

To boot up the application for development run:

```
$ docker-compose build
$ docker-compose up
```

The application will be available at http://localhost:9292 If for any reason you need the port to be different to 9292, you can change the port mapping in docker-compose.yml. For example to expose the application on port 8080 change `- 9292:9292` to `- 8080:9292`.

Warning: Mind that all state stored within the docker container is lost when the container is removed. That means that everytime you run a new container the database gets regenerated.

The app has two interfaces, the web interface and the API.

### Web interface

Open on your browser

```
http://localhost:9292/payment
```

### API

```
$ curl http://localhost:9292/api
{"message":"Hello Developer"}

$ curl http://localhost:9292/api/bookings
{"bookings":[{"reference":"some reference","amount":10000,"amount_received":10000,"country_from":"ES","sender_full_name":"Name","sender_address":"Address","school":"School","currency_from":"USD","student_id":123456,"email":"some@example.com"}]}
```
