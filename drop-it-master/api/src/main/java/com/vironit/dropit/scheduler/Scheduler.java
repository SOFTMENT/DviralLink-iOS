package com.vironit.dropit.scheduler;

import com.vironit.dropit.service.impl.PostServiceImpl;
import com.vironit.dropit.service.impl.UserServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@EnableScheduling
@RequiredArgsConstructor
public class Scheduler {

    private final UserServiceImpl userService;
    private final PostServiceImpl postService;

    @Scheduled(fixedDelay = 60 * 60 * 1000)
    public void deleteExpiredKeysAndUsers() {
        userService.deleteExpiredKeys();
    }

    @Scheduled(fixedDelay = 12 * 60 * 60 * 1000)
    public void deleteOldPosts() {
        postService.deleteOldPosts();
    }
}