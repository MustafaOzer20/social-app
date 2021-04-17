const functions = require("firebase-functions");

const admin = require('firebase-admin');
admin.initializeApp();

exports.recordCreated =  functions.firestore.document("followers/{userId}/user'sFollowers/{followersId}").onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const followersId = context.params.followersId;

    const postSnapshot =  await admin.firestore().collection("posts").doc(userId).collection("user'sPosts").get();

    postSnapshot.forEach((doc)=>{
        if(doc.exists){
            const postId = doc.id;
            const postData = doc.data();

            admin.firestore().collection("flows").doc(followersId).collection("user'sFlowPosts").doc(postId).set(postData);
        }
    });
});

exports.recordDelete =  functions.firestore.document("followers/{userId}/user'sFollowers/{followersId}").onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const followersId = context.params.followersId;

    const postSnapshot =  await admin.firestore().collection("flows").doc(followersId).collection("user'sFlowPosts").where("authorId", "==", userId).get();

    console.log(userId);
    console.log(followersId);

    postSnapshot.forEach((doc)=>{
        if(doc.exists){
            doc.ref.delete();
        }
    });
});

exports.newPostAdded = functions.firestore.document("posts/{followId}/user'sPosts/{postId}").onCreate(async (snapshot, context) => {
    const followId = context.params.followId;
    const postId = context.params.postId;
    const newPostData = snapshot.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followId).collection("user'sFollowers").get();

    followersSnapshot.forEach((doc)=>{
        const followersId = doc.id;
        admin.firestore().collection("flows").doc(followersId).collection("user'sFlowPosts").doc(postId).set(newPostData);
    });
});

exports.postUpdated = functions.firestore.document("posts/{followId}/user'sPosts/{postId}").onUpdate(async (change, context) => {
    const followId = context.params.followId;
    const postId = context.params.postId;
    const updatedPostData = change.after.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followId).collection("user'sFollowers").get();

    followersSnapshot.forEach((doc)=>{
        const followersId = doc.id;
        admin.firestore().collection("flows").doc(followersId).collection("user'sFlowPosts").doc(postId).update(updatedPostData);
    });
});

exports.postDeleted = functions.firestore.document("posts/{followId}/user'sPosts/{postId}").onDelete(async (snapshot, context) => {
    const followId = context.params.followId;
    const postId = context.params.postId;

    const followersSnapshot = await admin.firestore().collection("followers").doc(followId).collection("user'sFollowers").get();

    followersSnapshot.forEach((doc)=>{
        const followersId = doc.id;
        admin.firestore().collection("flows").doc(followersId).collection("user'sFlowPosts").doc(postId).delete();
    });
});

exports.notificationsCreated = functions.firestore.document("notifications/{userId}/user'sNotifications/{notifId}").onCreate(async(snapshot, context) => {
    const userId = context.params.userId;
    const notifId = context.params.notifId;
    const notifDoc = snapshot.data();

    const userData = await admin.firestore().collection("users").doc(doc.activityAuthorId).get();
    let title = userData.userName;
    let body;

    if(doc.activityType == "follow"){
        body = "seni takip etti";
    }
    else if(doc.activityType == "like"){
        body = "bir gönderini beğendi.";
    }else{
        body = "bir gönderine yorum yaptı.";
    }


    const message = {
        notification: { title: title, body: body },
        token: notifDoc.token(),
        data: { click_action: 'FLUTTER_NOTIFICATION_CLICK' }
    };

    return admin.messaging().send(message).then(response => {
        console.log("Successful Message Sent");
    }).catch(error => {
        console.log("Error Sending Message");
    });
    
});
