
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
// Parse.Cloud.define("hello", function(request, response) {
  // response.success("Hello world!");
// });

var Stripe = require("stripe");
Stripe.initialize("sk_test_Dk7KmW7c0h1cJzXFbrbEatY1");

var parseCustomer = Parse.Object.extend("Customer")

Parse.Cloud.define("create_customer", function(request, response) {
	var username = request.params.username
	var email = request.params.email
	console.log(request.params.user)
	console.log(request.params.username)
	Stripe.Customers.create({
		description: username,
		email: email,
		source: request.params.token
	}).then(function(customer) {
		console.log(customer)
		var newCustomer = new parseCustomer();
		newCustomer.set("username", username);
		newCustomer.set("user", request.user)
		newCustomer.set("email", email)
		newCustomer.set("stripe_id", customer.id);

		console.log(newCustomer)

		newCustomer.save();
		request.user.save();

		response.success("Customer created successfully")
	}, function(err, customer) {
		console.log(err);
		response.error(err);
	});
});

Parse.Cloud.define("get_customer", function(request, response) {
	var user = request.user
	var Customer = Parse.Object.extend("Customer")
	var query = new Parse.Query(Customer);
	query.equalTo("user", user);
	query.find({
		success: function(results) {
			if (results.length > 0) {
				var stripeCustomer = results[0]
				var stripe_id = stripeCustomer.get("stripe_id")
				Stripe.Customers.retrieve(stripe_id, {
					success: function(customer) {
						var data = customer.sources.data[0]
						response.success({ "customer_id": customer.id, "default_source": customer.default_source, "brand": data.brand, "last4": data.last4 })
					},
					error: function(err, customer) {
						console.log(err)
						response.error(err)
					}
				});
			} else {
				response.error("No customer exists.");
			}
		},
		error: function(error) {
			console.log(error)
			response.error(error);
		}
	});
});

Parse.Cloud.define("charge_customer", function(request, response) {
	var user = request.user
	var customerID = request.params.customerID
	var source = request.params.source
	var packageID = request.params.packageID

	var Package = Parse.Object.extend("Package")
	var query = new Parse.Query(Package);
	query.equalTo("objectId", packageID);
	query.find({
		success: function(results) {
			if (results.length > 0) {
				var dormyPackage = results[0]
				var cost = dormyPackage.get("price")
				Stripe.Charges.create({
					amount: cost*100,
					currency: "usd",
					capture: false,
					customer: customerID,
					source: source
				}, {
					success: function(charge) {
						var status = charge.status
						response.success({"status": status, "charge": charge.id})
					},
					error: function(err, charge) {
						console.log(err)
						response.error(err)
					}
				})
			}
		},
		error: function(error) {
			console.log(error)
			response.error(error)
		}
	});
});

Parse.Cloud.define("capture_charge", function(request, response) {
	var jobID = request.params.jobID
	console.log("this is cloud code");
	var Job = Parse.Object.extend("Job");
	var query = new Parse.Query(Job);
	query.equalTo("objectId", jobID);
	query.include("charge");
	query.find({
		success: function(results) {
			console.log("Results");
			console.log(results.length > 0);
			console.log(results);
			if (results.length > 0) {
				var job = results[0]
				var charge = job.get('charge');
				var chargeID = charge.get('charge_id');
				var stripeSecretKey = "sk_test_Dk7KmW7c0h1cJzXFbrbEatY1"
				var captureURL  = "https://"+stripeSecretKey+":@api.stripe.com/v1/charges/"+chargeID+"/capture";

				Parse.Cloud.httpRequest({
                    url: captureURL,
                    method: 'POST',
                    success: function(httpResponse) {
                        console.log(httpResponse.text);
                        var data = httpResponse.data
                        response.success({data: data});
                    },
                    error: function(httpResponse) {
                        console.log('Request failed with response code ' + httpResponse.status);
                        console.log(httpResponse.text);
                        var data = httpResponse.data
                        response.error({data: data});
                    }
                });
				/*
				Stripe.Charges.capture(chargeID, {
					success: function(charge) {
						var status = charge.status
						response.success(status)
					},
					error: function(err, charge) {
						console.log(err)
						response.error(err)
					}
				});
				*/
			} else {
				response.error("No such job found");
			}
		},
		error: function(error) {
			console.log(error);
			response.error(error);
		}
	})
})



