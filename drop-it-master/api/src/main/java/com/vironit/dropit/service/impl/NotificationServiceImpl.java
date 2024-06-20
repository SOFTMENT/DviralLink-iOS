package com.vironit.dropit.service.impl;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.*;
import com.vironit.dropit.model.DeviceToken;
import com.vironit.dropit.model.User;
import com.vironit.dropit.repository.DeviceTokenRepository;
import com.vironit.dropit.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {
    @Autowired
    private DeviceTokenRepository deviceTokenRepository;

    private final String DEFAULT_BODY = " is going Viral now❗❗❗ Now It’s your TURN \uD83D\uDD25\uD83C\uDF7E";
    private final String DEFAULT_TITLE = "A new post was added to the Feed";

    @PostConstruct
    private void initializeFirebaseAdminSDK() throws IOException {
        FirebaseApp firebaseApp = null;
        List<FirebaseApp> firebaseApps = FirebaseApp.getApps();

        if (firebaseApps!=null && !firebaseApps.isEmpty()){
            for (FirebaseApp app : firebaseApps){
                if (app.getName().equals(FirebaseApp.DEFAULT_APP_NAME))
                    firebaseApp = app;
            }
        } else {
            FileInputStream serviceAccount =
                    new FileInputStream("api/src/main/resources/dropit-1621328832417-firebase-adminsdk-xwrti-5e8927b20a.json");
            GoogleCredentials googleCredentials = GoogleCredentials
                    .fromStream(serviceAccount);
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(googleCredentials)
                    .build();
            firebaseApp = FirebaseApp.initializeApp(options);
        }
    }

    @Override
    public void senNotificationToAllUsers(String name, User user) {
        List<DeviceToken> deviceTokens = deviceTokenRepository.findAllByUserNot(user);
        String body = name + this.DEFAULT_BODY;
        for (DeviceToken devicetoken : deviceTokens) {
            Message message = Message.builder()
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(this.DEFAULT_TITLE)
                            .setBody(body).build())
                    .setToken(devicetoken.getToken())
                    .setApnsConfig(ApnsConfig.builder()
                            .setAps(Aps.builder()
                                    .putCustomData("sound", "default")
                                    .build())
                            .build())
                    .build();
            try {
                FirebaseMessaging.getInstance().send(message);
            } catch (FirebaseMessagingException ignored) {

            }
        }
    }
}
