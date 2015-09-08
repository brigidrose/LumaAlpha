
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


Parse.Cloud.afterSave("Story", function(request) {
    if (request.object.existed()==false){
		var senderObject = request.object.get('sender');
		var forCharmObject = request.object.get('forCharm');
		var receiverObject = forCharmObject.get('owner');
		var notificationMessage = senderObject.get('firstName') + " " + senderObject.get('firstName')
			if (notificationType == "comment" || notificationType == "like"){
				var activityObject = request.object.get('activity');
				var query = new Parse.Query("Activity");
				query.include("challenge");
				query.get(activityObject.id, {
					success: function(activityObjectReal) {
						// The object was retrieved successfully.
						var challengeObject = activityObjectReal.get("challenge");
						actionString = challengeObject.get("action");
						console.log("string is " + actionString);
						var userQuery = new Parse.Query("_User");
						userQuery.get(senderObject.id, {
							success: function(senderObjectReal) {
								// The object was retrieved successfully.
								senderAlias = senderObjectReal.get("username");
								var notificationTypeActionString = "";
								if (notificationType == "comment") {
									notificationTypeActionString = " commented on ";
								} else if (notificationType == "like") {
									notificationTypeActionString = " liked ";
								}
								var notificationText = senderAlias + notificationTypeActionString + "your activity " + "\"" + actionString + ".\"";
								var receiverPushQuery = new Parse.Query(Parse.Installation);
								receiverPushQuery.equalTo('deviceType', 'ios');
								receiverPushQuery.equalTo('currentUser', receiverObject);
								Parse.Push.send({
									where: receiverPushQuery, // Set our Installation query
									data: {
										alert: notificationText
									}
								}, {
									success: function() {
										console.log("success!")
											// Push was successful
										console.log(receiverPushQuery);
									},
									error: function(error) {
										throw "Got an error " + error.code + " : " + error.message;
									}
								});
							},
							error: function(object, error) {
								// The object was not retrieved successfully.
								// error is a Parse.Error with an error code and message.
								console.log("failed user query ");

							}
						});
					},
					error: function(object, error) {
						// The object was not retrieved successfully.
						// error is a Parse.Error with an error code and message.

					}
				});
			}
			else if (notificationType == "followRequestApproved"){
				var userQuery = new Parse.Query("_User");
				userQuery.get(senderObject.id, {
					success: function(senderObjectReal) {
						// The object was retrieved successfully.
						senderAlias = senderObjectReal.get("username");

						var receiverNotificationText = senderAlias + " approved your follow request.";
						var receiverPushQuery = new Parse.Query(Parse.Installation);
						receiverPushQuery.equalTo('deviceType', 'ios');
						receiverPushQuery.equalTo('currentUser', receiverObject);
						Parse.Push.send({
							where: receiverPushQuery, // Set our Installation query
							data: {
								alert: receiverNotificationText
							}
						}, {
							success: function() {
								console.log("success!")
									// Push was successful
								console.log(receiverPushQuery);
							},
							error: function(error) {
								throw "Got an error " + error.code + " : " + error.message;
							}
						});
					},
					error: function(object, error){
					
					}
				});
			}
			else if (notificationType == "followRequestSent"){
				var userQuery = new Parse.Query("_User");
				userQuery.get(senderObject.id, {
					success: function(senderObjectReal) {
						// The object was retrieved successfully.
						senderAlias = senderObjectReal.get("username");

						var receiverNotificationText = senderAlias + " sent you a follow request.";
						var receiverPushQuery = new Parse.Query(Parse.Installation);
						receiverPushQuery.equalTo('deviceType', 'ios');
						receiverPushQuery.equalTo('currentUser', receiverObject);
						Parse.Push.send({
							where: receiverPushQuery, // Set our Installation query
							data: {
								alert: receiverNotificationText
							}
						}, {
							success: function() {
								console.log("success!")
									// Push was successful
								console.log(receiverPushQuery);
							},
							error: function(error) {
								throw "Got an error " + error.code + " : " + error.message;
							}
						});
					},
					error: function(object, error){
					
					}
				});
			}
        }
    }
});