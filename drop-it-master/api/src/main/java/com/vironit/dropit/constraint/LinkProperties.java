package com.vironit.dropit.constraint;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@Data
@ConfigurationProperties(prefix = "link")
public class LinkProperties {

    private List<String> sources;

}