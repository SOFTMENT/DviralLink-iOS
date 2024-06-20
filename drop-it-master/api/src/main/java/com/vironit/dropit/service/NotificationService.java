package com.vironit.dropit.service;

import com.vironit.dropit.model.User;

public interface NotificationService {
    void senNotificationToAllUsers(String name, User author);
}
