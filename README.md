# Booking portal

The "Booking portal" is an application with the purpose of
creating payment bookings. It consists on a payment form with the following structure:

<img width="1090" height="640" alt="image" src="https://github.com/user-attachments/assets/e3ad504a-1032-46c4-9d12-a682c1593409" />


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

<img width="1324" height="491" alt="image" src="https://github.com/user-attachments/assets/c104bbaf-e399-41af-8c89-aaf1562726f6" />

