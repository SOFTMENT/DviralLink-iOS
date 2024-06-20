package com.vironit.dropit.service;

import com.vironit.dropit.model.User;

public interface DeviceTokenService {
    void subscribeUserOnNotifications(long userId, String deviceToken);
}
