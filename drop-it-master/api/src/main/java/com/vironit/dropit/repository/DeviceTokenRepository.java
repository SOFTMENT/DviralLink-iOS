package com.vironit.dropit.repository;

import com.vironit.dropit.model.DeviceToken;
import com.vironit.dropit.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Long> {
    Optional<DeviceToken> findDeviceTokenByUser(User user);
    List<DeviceToken> findAllByUserNot(User user);
}
