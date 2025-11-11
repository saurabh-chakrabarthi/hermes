# Booking portal exercise

The "Booking portal" is an application with the purpose of
creating payment bookings. It consists on a payment form with the following structure:

![alt tag](https://user-images.githubusercontent.com/34654846/37901679-4a71cd5a-30f2-11e8-83f2-d18ec3f594aa.png)

When the form is submitted, the application creates a payment record with the provided information.

This application also has an API consisting of 2 endpoints that are detailed on the [Readme](server/README.md).

There's a second application, inside the ``client`` directory, that communicates with the "booking portal" application in order to accomplish the following:

When a payment is booked, this payment has to go through a "quality check", the purpose of this quality check is to assure that the payment meets some defined "quality" criteria, this criteria consists on the following rules:

* **InvalidEmail**: The payment has an invalid email.
* **DuplicatedPayment**: The user that booked the payment has already a payment in the system.
* **AmountThreshold**: The amount of the payment is bigger than 1.000.000$

The application shows if any of this "quality check" criteria are not met.

Besides "quality check", it also checks for "over" and "under" payments [1]:

* An **over-payment** happens when the user pays more than the tuition amount we introduced in the booking portal.
* An **under-payment** is just the opposite.

As a final step, we add to the amount some fees depending on the magnitude of the amount, this fees are:

* if the amount < 1000 USD: 5% fees
* if the amount > 1000 USD AND < 10000 USD: 3% fees
* if the amount > 10000 USD: 2% fees

Here you can see an example on how this information could be displayed:

![alt tag](https://user-images.githubusercontent.com/34654846/37902217-fe20f97e-30f3-11e8-9594-fe4d611344b0.png)
