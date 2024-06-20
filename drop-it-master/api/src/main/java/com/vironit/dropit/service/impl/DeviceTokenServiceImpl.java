package com.vironit.dropit.service.impl;

import com.vironit.dropit.exception.NotFoundEntityException;
import com.vironit.dropit.model.DeviceToken;
import com.vironit.dropit.model.User;
import com.vironit.dropit.repository.DeviceTokenRepository;
import com.vironit.dropit.repository.UserRepository;
import com.vironit.dropit.service.DeviceTokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class DeviceTokenServiceImpl implements DeviceTokenService {
    @Autowired
    private DeviceTokenRepository deviceTokenRepository;
    @Autowired
    private UserRepository userRepository;

    @Override
    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public void subscribeUserOnNotifications(long userId, String token) {
        User user = userRepository.findById(userId).orElseThrow(() -> new NotFoundEntityException("No user with id = " + userId));
        DeviceToken deviceToken = deviceTokenRepository.findDeviceTokenByUser(user).orElse(null);
        if (deviceToken == null) {
            deviceToken = new DeviceToken()
                    .setToken(token)
                    .setUser(user);
        } else {
            deviceToken.setToken(token);
        }
        deviceTokenRepository.saveAndFlush(deviceToken);
    }
}
